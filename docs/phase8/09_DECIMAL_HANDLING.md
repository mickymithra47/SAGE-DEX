# 09 — Decimal Precision & Zero Floating-Point Arithmetic

## 1. The Strict BigInt Invariant
- **Rule**: Standard JavaScript `Number` (IEEE-754 double precision) must NEVER be used for token math or calldata amounts.
- **Implementation**: All values are parsed to exact `bigint` via string manipulation (`parseUnits` / `formatUnits`).
- Guarantees 0-wei precision loss across 6, 8, and 18-decimal assets.
