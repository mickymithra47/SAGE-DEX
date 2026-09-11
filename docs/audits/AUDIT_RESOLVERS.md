# AUDIT_RESOLVERS.md
# SAGE PROTOCOL — RESOLVER ENGINE & ANALYTICS AUDIT
**Scope**: `indexer/src/api/resolvers.ts`, `indexer/src/engine/volumeAnalytics.ts`, `indexer/src/db/database.ts`  

---

## 1. Deep Dive: `getPoolStats()` Implementation

### 1.1 Implementation Analysis
In `resolvers.ts`:
```typescript
public getPoolStats(chainId: bigint, poolAddress: string, currentTimestamp: bigint) {
  const pool = this.db.getPool(chainId, poolAddress);
  if (!pool) return null;

  const swaps = this.db.getPoolSwaps(chainId, poolAddress, 10000);
  const volume = calculate24hVolumeAndFees(swaps, currentTimestamp);

  return {
    poolAddress: pool.address,
    token0: pool.token0,
    token1: pool.token1,
    reserve0: pool.reserve0.toString(),
    reserve1: pool.reserve1.toString(),
    volume24hToken0: volume.volumeToken0.toString(),
    volume24hToken1: volume.volumeToken1.toString(),
    fees24hToken0: volume.feesToken0.toString(),
    fees24hToken1: volume.feesToken1.toString(),
    swapCount24h: volume.swapCount
  };
}
```

### 1.2 Performance & Scalability Bottleneck
- **Issue**:
  1. `getPoolStats` fetches up to 10,000 swaps (`limit: 10000`) into memory.
  2. In `database.ts`, `getSwaps()` sorts the entire unbounded `this.swaps` array by block number on every request before slicing.
  3. `calculate24hVolumeAndFees` then iterates linearly over all fetched swaps.
- **Complexity**: $O(M \log M + N)$ where $M$ is total swaps in the database.
- **Scalability Limit**: As trading volume increases past hundreds of thousands of swaps, this endpoint will cause CPU spikes and memory exhaustion.
- **Remediation**:
  - In PostgreSQL, replace with an indexed SQL aggregation query:
    ```sql
    SELECT 
      COALESCE(SUM(amount0_in + amount0_out), 0) AS volume0,
      COALESCE(SUM(amount1_in + amount1_out), 0) AS volume1,
      COUNT(*) AS swap_count
    FROM swaps
    WHERE chain_id = $1 AND pool_address = $2 AND timestamp >= $3;
    ```
  - In-memory: Maintain a pre-aggregated 24h rolling bucket cache.

---

## 2. Deep Dive: `getFreshness()` Implementation

### 2.1 Implementation Analysis
In `resolvers.ts`:
```typescript
public getFreshness(chainId: bigint, currentChainBlock: bigint) {
  const latest = this.db.getLatestBlock(chainId);
  const latestIndexedBlock = latest ? latest.blockNumber : 0n;
  const lag = currentChainBlock > latestIndexedBlock ? currentChainBlock - latestIndexedBlock : 0n;
  const lagNumber = lag <= BigInt(Number.MAX_SAFE_INTEGER) ? Number(lag) : Number.MAX_SAFE_INTEGER;

  return {
    latestIndexedBlock: latestIndexedBlock.toString(),
    latestChainBlock: currentChainBlock.toString(),
    indexingLagBlocks: lagNumber,
    isHealthy: lag <= 5n
  };
}
```

### 2.2 Correctness & Edge Cases
- **Lag Calculation**: Correctly avoids underflow using ternary conditional check `currentChainBlock > latestIndexedBlock`.
- **BigInt Safety**: Converts `lag` to `Number` only after capping at `Number.MAX_SAFE_INTEGER`, preventing overflow.
- **Health Threshold**: Configured to `lag <= 5n` (under 1 minute of lag on Ethereum 12s blocks).
- **Return Types**: Returns `string` for large block numbers, avoiding BigInt JSON serialization errors.

---

## 3. Investigation of Resolver Error

### 3.1 Error Context
A recent resolver error reported typing mismatches between database records and API return types.
### 3.2 Audit Findings
- In `database.ts`, `PoolRecord.reserve0` is `bigint`.
- In `resolvers.ts`, `getPool()` and `getPools()` return raw `PoolRecord` containing `bigint`.
- But `getPoolStats()` converts reserves to `.toString()`.
- This inconsistent typing (some endpoints returning `bigint`, others returning `string`) leads to frontend deserialization runtime errors unless normalized.
- **Remediation**: Standardize API DTO types so all `bigint` fields are stringified before leaving the resolver layer.
