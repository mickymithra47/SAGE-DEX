# 21 — Quote vs Execution Consistency: Mathematical Parity

## 1. Zero-Divergence Axiom
$$\text{Quote}(\text{state}, \Delta x) \equiv \text{Execution}(\text{state}, \Delta x)$$

- Because `SageRouter` directly relies on `SagePricingLibrary.getAmountsOut` and `SagePricingLibrary.getAmountsIn`, which replicate `SagePair.swap()` integer logic, the quote and execution formulas are mathematically identical down to the exact wei.
