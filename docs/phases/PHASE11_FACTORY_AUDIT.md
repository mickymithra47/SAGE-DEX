# Phase 11 — Factory & Pair Creation Security Audit

## 1. CREATE2 Determinism & Ordering
- Factory mandates `token0 < token1` strictly by hexadecimal numerical comparison.
- Duplicate pair creation with reversed parameters `(B, A)` reverts with `PairExists`.
- Pair address is derived deterministically from `keccak256(abi.encodePacked(token0, token1))`.
