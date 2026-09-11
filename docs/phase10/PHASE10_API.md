# Phase 10 — API & Query Interface Specification

## 1. REST / GraphQL Read Resolvers
- `getPools(chainId)`
- `getPool(chainId, address)`
- `getSwaps(chainId, poolAddress, limit, cursor)`
- `getUserSwaps(chainId, userAddress, limit)`
- `getUserPositions(chainId, userAddress)`
- `getCandles(chainId, poolAddress, interval, limit)`
- `getIndexerStatus(chainId)`
