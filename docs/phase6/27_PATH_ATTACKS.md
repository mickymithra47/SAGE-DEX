# 27 — Path Manipulation & Cyclic Route Attack Analysis

## 1. Path Attacks Analyzed
- **Path of Length 1 ($[A]$)**: Reverts with `InvalidPath()`.
- **Cyclic Route ($[A, B, A]$)**: Evaluated as two legitimate sequential swaps across the same pool. Fees compound ($0.997^2$), making cyclic arbitrage unprofitable unless mispriced by an external party.
- **Self-Loop ($[A, A]$)**: `getPair(A, A)` returns `address(0)` because factory prohibits identical tokens; reverts with `PairNotFound()`.
