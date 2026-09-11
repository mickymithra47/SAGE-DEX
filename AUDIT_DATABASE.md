# AUDIT_DATABASE.md
# SAGE PROTOCOL — DATABASE SCHEMA & PERSISTENCE AUDIT
**Scope**: `indexer/src/db/schema.sql`, `indexer/src/db/database.ts`  

---

## 1. Relational Schema Architecture (`schema.sql`)

The PostgreSQL 15+ relational schema in `schema.sql` defines 11 tables:
1. `blocks`: Canonical chain progress & reorg cursor `(chain_id, block_number)`
2. `tokens`: Verified ERC-20 token registry `(chain_id, address)`
3. `pools`: AMM pairs with reserve tracking `(chain_id, address)`
4. `swaps`: Historical swap logs `(chain_id, tx_hash, log_index)`
5. `mints`: Liquidity deposit logs `(chain_id, tx_hash, log_index)`
6. `burns`: Liquidity withdrawal logs `(chain_id, tx_hash, log_index)`
7. `syncs`: Pair reserve sync events `(chain_id, tx_hash, log_index)`
8. `lp_transfers`: LP token ERC-20 transfer logs `(chain_id, tx_hash, log_index)`
9. `lp_positions`: Materialized user LP balances `(chain_id, pool_address, user_address)`
10. `candles`: OHLCV candlestick aggregates `(chain_id, pool_address, interval_type, timestamp)`
11. `pool_snapshots`: Periodic block-level reserve snapshots

### Schema Strengths:
- **Composite Primary Keys**: Every event table uses `(chain_id, tx_hash, log_index)` to prevent duplicate event ingestion.
- **Index Optimization**: B-Tree indexes on `(chain_id, pool_address, block_number DESC)` and user addresses for fast pagination.
- **Chain Isolation**: Every table includes `chain_id` to prevent multi-chain data collisions.

---

## 2. Findings & Architectural Issues

### [MEDIUM] Database Repository is an In-Memory Mock (`database.ts`)
- **Location**: `indexer/src/db/database.ts`
- **Issue**:
`database.ts` uses JavaScript `Map<string, Record>` and in-memory arrays (`swaps: SwapRecord[] = []`) instead of executing real SQL queries against PostgreSQL via `pg` or `pg-promise` / `kysely`.
- **Impact**:
  - All indexed data is volatile and lost upon process restart.
  - Ingestion does not test live PostgreSQL network latency, connection pooling, concurrency locks, or SQL query performance.
- **Remediation**: Implement a PostgreSQL client adapter implementing the `SageDatabase` interface for production deployments while retaining the in-memory driver for unit tests.

---

### [MEDIUM] Unsafe JavaScript `Number` Float in Candlestick Calculation
- **Location**: `indexer/src/db/database.ts#L267-L268`
- **Issue**:
```typescript
const price = Number(pool.reserve1) / Number(pool.reserve0);
```
- **Analysis**:
  1. `pool.reserve1` and `pool.reserve0` are 112-bit integers. In wei, a reserve of $100,000\times 10^{18} = 10^{23}$, which greatly exceeds `Number.MAX_SAFE_INTEGER` ($9.007 \times 10^{15}$). `Number(bigint)` converts with truncation/loss of precision.
  2. The division does not account for token decimal differences. If token0 is USDC (6 dec) and token1 is WETH (18 dec), `price` represents $\frac{10^{18}\text{ wei}}{10^6\text{ units}}$, which is distorted by $10^{12}\times$ rather than computing human price.
- **Remediation**: Use `calculateNormalizedPrice(r0, dec0, r1, dec1)` from `priceEngine.ts`.
