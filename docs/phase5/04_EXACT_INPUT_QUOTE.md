# 04 — Exact-Input Quoting & Floor Rounding

## 1. Exact-Input Swap Formulation
Given gross input $\Delta x$, reserve $x$, and reserve $y$:

$$\Delta y = \left\lfloor \frac{997 \cdot \Delta x \cdot y}{1000 \cdot x + 997 \cdot \Delta x} \right\rfloor$$

---

## 2. Implementation & Gas Independence
- `SagePricingLibrary.getAmountOut` is `pure` and executes with 0 storage writes or external calls.
- Truncation via integer division guarantees that the quoted output never exceeds what the pool can safely disburse while preserving the $k$-invariant.
