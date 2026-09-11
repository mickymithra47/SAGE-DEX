# 39 — Read Functions & On-Chain Position Queries

## 1. Core vs Accounting Viewer Read Methods

```
┌───────────────────────────────────────┬──────────────────────┬────────────────────────────────────────────────────────┐
│ Function Signature                    │ Location             │ Description                                            │
├───────────────────────────────────────┼──────────────────────┼────────────────────────────────────────────────────────┤
│ getReserves()                         │ SagePair            │ Returns (reserve0, reserve1, blockTimestampLast).      │
│ totalSupply()                         │ SagePair (ERC-20)   │ Returns total circulating LP shares (+ 1000 dead).     │
│ balanceOf(user)                       │ SagePair (ERC-20)   │ Returns LP shares held by user.                        │
│ getPosition(pair, user)               │ Accounting Engine    │ Returns comprehensive PositionView struct.             │
│ quoteAddLiquidity(pair, d0, d1)       │ Accounting Engine    │ Calculates optimal deposits & expected shares.         │
│ quoteRemoveLiquidity(pair, user, burn)│ Accounting Engine    │ Calculates tokens returned & remaining LP metrics.     │
└───────────────────────────────────────┴──────────────────────┴────────────────────────────────────────────────────────┘
```
