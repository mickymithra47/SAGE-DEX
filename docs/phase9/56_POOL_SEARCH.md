# 56 — Pool Search & Bi-Directional Pair Resolution

## 1. Bi-Directional Normalization
- Queries for `tokenA` and `tokenB` normalize tokens into canonical numerical order:
  $$\text{token0} = \min(\text{tokenA}, \text{tokenB}), \quad \text{token1} = \max(\text{tokenA}, \text{tokenB})$$
- Resolves the same pair address regardless of user token input ordering.
