# Phase 10 — Swap Index & Interpretation

## 1. Directional Mapping
- `amount0In > 0 && amount1Out > 0` $\implies$ `token0 -> token1`.
- `amount1In > 0 && amount0Out > 0` $\implies$ `token1 -> token0`.
- Amounts mapped directly to exact `bigint` without floating-point truncation.
