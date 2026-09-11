# Phase 10 — Pool Indexing & Discovery

## 1. Pool Ingestion Mechanics
- Monitored from `SageFactory.sol`.
- Pairs stored canonically with `token0 < token1`.
- Bi-directional resolution guarantees identical lookup results for `(A, B)` and `(B, A)`.
