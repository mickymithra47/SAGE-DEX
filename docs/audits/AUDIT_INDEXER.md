# AUDIT_INDEXER.md
# SAGE PROTOCOL — INDEXING, EVENT DECODING & REORG ENGINE AUDIT
**Scope**: `indexer/src/decoders/`, `indexer/src/engine/`, `indexer/src/observability/`  

---

## 1. Indexer Architecture & Data Flow

The Indexer ingests on-chain EVM logs and reconstructs relational models:
```
EVM Log Streams -> Decoders -> BlockIngestor -> ReorgHandler -> Database -> Resolvers
```

### Inspected Decoders:
1. `factoryDecoder.ts`: Decodes `PairCreated(token0, token1, pair, length)`
2. `pairDecoder.ts`: Decodes `Swap`, `Mint`, `Burn`, `Sync` events
3. `erc20Decoder.ts`: Decodes `Transfer(from, to, value)` for LP position tracking
4. `swapInterpreter.ts`: Maps raw uint256 `amount0In`/`amount1In` to structured `tokenIn`, `tokenOut`, `amountIn`, `amountOut`

---

## 2. Ingestion & Reorg Analysis

### 2.1 Block Ingestion & Idempotency
- Blocks are ingested sequentially via `BlockIngestor.processBlock()`.
- Idempotency is enforced on `swaps`, `mints`, `burns`, `syncs`, and `transfers` using unique primary keys `(chainId, txHash, logIndex)`.
- Duplicate event emissions in the same block or retried blocks are rejected without corrupting state.

---

### 2.2 Reorg Detection & Rollback
In `reorgHandler.ts`:
- Verifies that incoming block `parentHash` matches the stored canonical block `blockHash` at `blockNumber - 1`.
- If a hash mismatch is detected, it triggers `db.rollbackBlocksAbove(chainId, forkBlockNumber)`.

---

## 3. Findings & Vulnerabilities

### [HIGH] Reorg Rollback Fails to Revert `lpPositions`
- **Location**: `indexer/src/db/database.ts#L324-L349`
- **Vulnerability**:
```typescript
public rollbackBlocksAbove(chainId: bigint, targetBlockNumber: bigint): number {
  let rolledBackCount = 0;
  // 1. Remove blocks
  for (const [key, block] of this.blocks.entries()) {
    if (block.chainId === chainId && block.blockNumber > targetBlockNumber) {
      this.blocks.delete(key);
      rolledBackCount++;
    }
  }
  // 2. Remove swaps, mints, burns
  this.swaps = this.swaps.filter((s) => !(s.chainId === chainId && s.blockNumber > targetBlockNumber));
  this.mints = this.mints.filter((m) => !(m.chainId === chainId && m.blockNumber > targetBlockNumber));
  this.burns = this.burns.filter((b) => !(b.chainId === chainId && b.blockNumber > targetBlockNumber));
  // 3. Clean candles...
  return rolledBackCount;
}
```
- **Analysis**:
  - `this.lpPositions` is **never restored or rolled back** during a reorg!
  - If a user minted LP tokens on a reorged fork (blocks $> targetBlockNumber$), their `lpPositions` balance remains permanently updated in the database even after the blocks and mint events are deleted.
- **Impact**: Database returns stale / inflated LP token balances for users after an on-chain reorg event.
- **Remediation**: Reconstruct `lpPositions` by replaying non-reorged mint, burn, and LP transfer events or record block-versioned balance delta history in the database.

---

## 4. Observability & Metrics
- `metrics.ts` tracks `blocksProcessedTotal`, `eventsProcessedTotal`, `reorgsTotal`, `indexerLagBlocks`.
- `reconciliationJob.ts` executes on-chain `Pair.getReserves()` reconciliation checks against stored database reserves, correctly flagging delta discrepancies.
