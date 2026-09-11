# AUDIT_API.md
# SAGE PROTOCOL — GRAPHQL & REST API AUDIT
**Scope**: `indexer/src/api/resolvers.ts`, `docs/phase9/33_API_ARCHITECTURE.md`, `docs/phase9/34_GRAPHQL_SCHEMA.md`  

---

## 1. API Architecture Overview

The Sage protocol exposes a read-only query API supporting:
- **REST Endpoints**: `/api/v1/pools`, `/api/v1/pools/:address/stats`, `/api/v1/swaps`, `/api/v1/health`
- **GraphQL Schema**: `Query { pools, pool, swaps, userSwaps, userPositions, candles, poolStats, freshness }`

---

## 2. API Security & Integrity Analysis

### 2.1 Read-Only Isolation
- The API layer communicates exclusively with the read model (`SageDatabase`).
- There are no write endpoints capable of altering database records or submitting on-chain transactions.

### 2.2 Address Normalization & Injection Defense
- Resolvers normalize all incoming Ethereum addresses via `.toLowerCase()`.
- Address casing variations (`0xAbCd...` vs `0xabcd...`) resolve to the same underlying record without key mismatch.

---

## 3. Findings & Serialization Issues

### [MEDIUM] Native `BigInt` Return Types in Resolvers Break JSON / GraphQL Serialization
- **Location**: `indexer/src/api/resolvers.ts#L17-L48`
- **Issue**:
Methods such as `getPools()`, `getPool()`, `getSwaps()`, and `getUserPositions()` return records where `reserve0`, `reserve1`, `amountIn`, `amountOut`, `lpBalance`, `timestamp`, and `blockNumber` are typed as native TypeScript `bigint`.
- When standard Express / Fastify `res.json()` or Apollo Server GraphQL resolvers attempt to serialize these objects, Node.js throws:
  `TypeError: Do not know how to serialize a BigInt`
- **Impact**: API endpoints crash at runtime if `JSON.stringify()` is called on raw resolver outputs without custom BigInt serialization.
- **Remediation**:
  1. Return all financial amounts and timestamps as decimal strings (`string`) in the API resolver layer.
  2. Or configure a global JSON serializer:
  ```typescript
  (BigInt.prototype as any).toJSON = function () { return this.toString(); };
  ```
