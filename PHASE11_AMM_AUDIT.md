# Phase 11 — AMM Mathematical Invariant & Swap Audit

## 1. AMM Core Math Verification
- **Constant Product Invariant**:
  $$(R_0 \cdot 1000 + \Delta x \cdot 997)(R_1 \cdot 1000 - \Delta y \cdot 1000) \ge R_0 R_1 \cdot 1000^2$$
- **Rounding Direction**:
  - `getAmountOut`: Rounds DOWN in favor of pool reserves.
  - `getAmountIn`: Rounds UP in favor of pool reserves.
  - LP Mint / Burn: Rounds DOWN in favor of remaining LP holders.
- **Zero-Input Exploit Resistance**:
  - Direct calls to `pair.swap()` with 0 input tokens and $>0$ output tokens revert with `InsufficientInputAmount` / invariant failure.
