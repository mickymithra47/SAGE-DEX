# 30 — Stateless Property Fuzz Testing Suite

## 1. Fuzz Testing Architecture
Foundry's property-based fuzzer executes hundreds of randomized test runs to verify mathematical inequalities across arbitrary bounds.

---

## 2. Tested Fuzz Properties

```
┌───────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Fuzz Test Function                    │ Invariant Property Under Random Inputs                      │
├───────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ testFuzz_AMM_AmountOutBoundedByReserve│ getAmountOut is strictly < reserveOut for any amountIn.     │
│ testFuzz_AMM_AmountInRoundTrip        │ getAmountIn followed by getAmountOut yields >= expected out.│
│ testFuzz_Math_SqrtInvariance          │ floor(sqrt(y))^2 <= y < (floor(sqrt(y)) + 1)^2.             │
└───────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
```
