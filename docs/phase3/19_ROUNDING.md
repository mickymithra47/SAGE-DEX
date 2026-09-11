# 19 — Financial Rounding Directions & Precision Loss Defenses

## 1. Master Rounding Matrix for AMM Financial Primitives

```
┌───────────────────────────────────────┬────────────────────┬────────────────────────────────────────────────────────┐
│ Operation                             │ Rounding Direction │ Security Justification                                 │
├───────────────────────────────────────┼────────────────────┼────────────────────────────────────────────────────────┤
│ Swap Output (getAmountOut)            │ Round DOWN (Floor) │ Prevents pool over-disbursement; preserves k-invariant.│
│ Exact-Output Input (getAmountIn)      │ Round UP (Ceil)    │ Guarantees user deposits >= required invariant delta.  │
│ Liquidity Minting (LP Shares)         │ Round DOWN (Floor) │ Prevents inflation of share equity claims.             │
│ Liquidity Burning (Asset Redemption)  │ Round DOWN (Floor) │ Prevents withdrawing more assets than pool equity.     │
│ Protocol / LP Trading Fee             │ Round UP (Ceil)    │ Ensures full 0.3% fee is retained by reserves.         │
└───────────────────────────────────────┴────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 2. Integer Division Rule: Multiply Before Dividing
In EVM arithmetic:
$$(\text{amount} \cdot \text{reserve}) / \text{total}$$
must **ALWAYS** compute the numerator product before performing division to prevent premature precision loss and truncation to zero.
