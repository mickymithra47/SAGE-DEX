# 24 — Decimal Normalization Mathematics & Pure Helpers

## 1. Normalization Implementation
`SagePricingLibrary.normalizeDecimals`:

```solidity
function normalizeDecimals(
    uint256 amount,
    uint8 fromDecimals,
    uint8 toDecimals
) internal pure returns (uint256 normalizedAmount) {
    if (fromDecimals == toDecimals) return amount;
    if (fromDecimals < toDecimals) {
        normalizedAmount = amount * (10 ** (toDecimals - fromDecimals));
    } else {
        normalizedAmount = amount / (10 ** (fromDecimals - toDecimals));
    }
}
```

---

## 2. Gas & Security
- Executed purely in mathematical helpers without making external `token.decimals()` view calls inside the core swap path.
