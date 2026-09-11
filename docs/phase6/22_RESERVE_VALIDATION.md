# 22 — Reserve State Transitions & Invariant Integrity

## 1. Reserve Lifecycle Across Swaps
For each pool involved in a swap:
- **Pre-Swap**: Reserves $(R_0, R_1)$ in packed storage slot 3.
- **Token Inflow**: Input tokens received from trader or preceding pool.
- **Execution**: `SagePair.swap(amount0Out, amount1Out, to, data)` verifies:
  $$(R_0^{\text{new}} \cdot 1000 - \Delta x_0 \cdot 3) \times (R_1^{\text{new}} \cdot 1000 - \Delta x_1 \cdot 3) \ge R_0 \cdot R_1 \cdot 1000^2$$
- **Post-Swap**: Reserves updated to actual token balances minus uncollected fees.
