# 30 — Minimum Deposits & Dust Balance Accounting

## 1. Initial Deposit Minimums
- **Requirement**: Initial deposit must yield $\sqrt{a_0 \cdot a_1} > 1000$ shares.
- **Rationale**: 1,000 shares are burned to `address(0)` to prevent share inflation. Deposits yielding $\le 1000$ revert with `InsufficientLiquidityMinted()`.

---

## 2. Dust Balance Behavior
- **Zero-Share Mint**: Deposits so small that $\min\left(\frac{a_0 \cdot S}{R_0}, \frac{a_1 \cdot S}{R_1}\right) = 0$ revert with `InsufficientLiquidityMinted()`, preventing micro-dust asset traps.
- **Dust Redemptions**: Redemptions yielding $0$ tokens return $0$ tokens without reverting if `liquidity > 0`, ensuring users can always clear non-zero share balances.
