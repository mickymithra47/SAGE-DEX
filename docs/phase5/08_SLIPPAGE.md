# 08 — Price Impact vs Slippage: Conceptual Separation

## 1. The Core Distinction

```
┌─────────────────────────┬────────────────────────────────────────────────────────────────────────────┐
│ Concept                 │ Definition & Nature                                                        │
├─────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
│ Price Impact            │ Deterministic AMM curve effect caused by trade size relative to pool depth.│
│ Slippage                │ Stochastic price movement between quote generation and on-chain execution. │
└─────────────────────────┴────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Slippage Boundary Calculations
- **Minimum Output Calculation (Exact Input)**:
  $$\text{minAmountOut} = \left\lfloor \frac{\text{amountOut} \times (10,000 - \text{slippageToleranceBps})}{10,000} \right\rfloor$$
- **Maximum Input Calculation (Exact Output)**:
  $$\text{maxAmountIn} = \left\lfloor \frac{\text{amountIn} \times (10,000 + \text{slippageToleranceBps})}{10,000} \right\rfloor$$
