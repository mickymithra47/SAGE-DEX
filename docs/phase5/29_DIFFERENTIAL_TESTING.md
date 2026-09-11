# 29 — Differential Testing & Cross-Platform Parity

## 1. Differential Model Validation
To guarantee zero discrepancy between off-chain calculation and on-chain EVM execution:
- A pure reference model was tested across identical input parameters:

```python
def get_amount_out_reference(amount_in, reserve_in, reserve_out):
    amount_in_with_fee = amount_in * 997
    numerator = amount_in_with_fee * reserve_out
    denominator = (reserve_in * 1000) + amount_in_with_fee
    return numerator // denominator
```

---

## 2. Parity Confirmation
In `Project11_DifferentialTester` and unit tests:
- `SagePricingLibrary.getAmountOut` produces outputs identical to the reference model down to exact integer wei across 10,000 randomized iterations.
