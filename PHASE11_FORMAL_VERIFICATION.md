# Phase 11 — Formal Verification & Mathematical Invariant Proofs

## 1. AMM Core Proof
$$\forall (\Delta x > 0, \Delta y = \text{getAmountOut}(\Delta x, R_0, R_1)):$$
$$(R_0 + \Delta x)(R_1 - \Delta y) \ge R_0 R_1$$

### Proof:
$$\text{getAmountOut}(\Delta x, R_0, R_1) = \left\lfloor \frac{\Delta x \cdot 997 \cdot R_1}{R_0 \cdot 1000 + \Delta x \cdot 997} \right\rfloor$$
$$(R_0 \cdot 1000 + \Delta x \cdot 997)(R_1 - \Delta y) = R_0 R_1 \cdot 1000 + \Delta x \cdot 997 \cdot R_1 - (R_0 \cdot 1000 + \Delta x \cdot 997) \Delta y$$
$$\ge R_0 R_1 \cdot 1000$$

Thus, the invariant $k$ is monotonically non-decreasing for all legitimate swaps.
