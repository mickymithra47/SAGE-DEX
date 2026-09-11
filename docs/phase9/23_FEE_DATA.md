# 23 — Protocol Fee Accumulation & Yield Accounting

## 1. Fee Formulation (0.30% Fee Tier)
$$\text{Swap Fee} = \left\lfloor \frac{\text{amountIn} \cdot 3}{1000} \right\rfloor$$

- Accrues directly to liquidity providers via invariant growth in the constant product curve:
  $$k_1 = (R_0 + \Delta x) \cdot (R_1 - \Delta y) > k_0$$
- Indexed historical fee totals reflect exact accumulated LP yield.
