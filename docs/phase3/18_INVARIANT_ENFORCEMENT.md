# 18 — Invariant Enforcement & Invariant Inequality Verification

## 1. Post-Swap Invariant Inequality
In an active swap, trading fees (0.3%) must grow the effective product of reserves. The exact mathematical condition verified on-chain is:

$$\left(1000 \cdot \text{balance0} - 3 \cdot \Delta x_{\text{in}}\right) \cdot \left(1000 \cdot \text{balance1} - 3 \cdot \Delta y_{\text{in}}\right) \ge 1000^2 \cdot \text{reserve0} \cdot \text{reserve1}$$

---

## 2. Invariant Code Implementation
```solidity
uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);

if (balance0Adjusted * balance1Adjusted < uint256(_reserve0) * _reserve1 * (1000 ** 2)) {
    revert KInvariantViolation();
}
```

### Why Multiply by $1000^2$?
- Avoids floating-point arithmetic.
- Accurately checks that net inputs satisfy constant product while retaining exactly $3 / 1000$ (30 bps) inside the pool reserves.
