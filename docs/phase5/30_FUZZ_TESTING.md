# 30 — Stateless Property Fuzz Testing Suite

## 1. Fuzzing Scope & Property Assertions
Foundry's property-based fuzzer executes 256 randomized runs per property across extreme value ranges ($1 \text{ wei} \to 10^{30} \text{ tokens}$):

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Fuzz Test Function                    │ Invariant Property Under Random Inputs                 │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ testFuzz_Pricing_AmountOutBounded     │ getAmountOut is strictly < reserveOut for all amountIn.│
│ testFuzz_Pricing_PriceImpactBounded   │ Price impact is strictly <= 10,000 basis points.       │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
