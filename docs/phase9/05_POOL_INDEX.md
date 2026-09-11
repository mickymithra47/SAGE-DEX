# 05 — Liquidity Pool (Pair) Entity & Lifecycle Modeling

## 1. Relational Pool Schema
- **Immutable Fields**: `chainId`, `address`, `factory`, `token0`, `token1`, `createdAtBlock`, `createdAtTimestamp`, `createdTxHash`.
- **Dynamic Fields**: `reserve0`, `reserve1`, `totalSupply`, `volume24h`, `fees24h`.

---

## 2. Order Invariance
- Lookup queries for `(tokenA, tokenB)` and `(tokenB, tokenA)` resolve to the exact same canonical pool record.
