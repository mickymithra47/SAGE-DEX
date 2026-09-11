# 27 — Pricing Engine Rounding Policy & Directional Directives

## Master Rounding Policy

```
┌───────────────────────────────────────┬────────────────────┬────────────────────────────────────────────────────────┐
│ Pricing Primitive                     │ Rounding Direction │ Security Justification                                 │
├───────────────────────────────────────┼────────────────────┼────────────────────────────────────────────────────────┤
│ Exact-Input Output (getAmountOut)     │ Floor (Truncate)   │ Prevents promising more tokens than execution produces.│
│ Exact-Output Input (getAmountIn)      │ Ceil (Round UP)    │ Guarantees required input fulfills swap invariant.     │
│ Spot Price (getSpotPriceWad)          │ Floor (Truncate)   │ Standard integer precision truncation.                 │
│ Price Impact (calculatePriceImpactBps)│ Floor (Truncate)   │ Conservative basis point representation.               │
│ Minimum Output (getMinimumOutputAmount│ Floor (Truncate)   │ Guarantees slippage limit is strictly respected.       │
│ Maximum Input (getMaximumInputAmount) │ Floor (Truncate)   │ Standard ceiling-safe slippage bounding.               │
└───────────────────────────────────────┴────────────────────┴────────────────────────────────────────────────────────┘
```
