# 43 — Phase 6 to Phase 7 Dependency Report & Permit2 Architecture

## 1. Phase 6 Accomplishments & Stabilized Surface
- `SageRouter`:
  - `swapExactTokensForTokens`
  - `swapTokensForExactTokens`
  - `swapExactETHForTokens`, `swapTokensForExactETH`
  - `swapExactTokensForETH`, `swapETHForExactTokens`
  - `_swap` sequential execution loop.
  - Zero trapped funds guarantee.

---

## 2. Current Approval Architecture
- The user currently signs an on-chain `ERC20.approve(router, amount)` transaction prior to executing swaps.
- Standard approval limits:
  - **Exact Approval**: User approves only `amounts[0]`. Highly secure, but requires an approval transaction before every swap.
  - **Unlimited Approval (`type(uint256).max`)**: Single approval, saves gas on subsequent swaps, but grants the router authorization to pull tokens until revoked.

---

## 3. What Phase 7 Will Build (Token Approvals, Permit2 & User Safety)
1. **EIP-2612 Permit Integration**:
   - Gasless approvals via off-chain signatures (`permit(owner, spender, value, deadline, v, r, s)`).
2. **Permit2 Architecture**:
   - Signature-based token allowance transfers without requiring repetitive on-chain `approve()` calls.
   - Nonce management, replay protection, and expiration timestamps.
3. **What Phase 7 Must NOT Modify**:
   - `SagePair.sol` core constant-product invariant.
   - `SagePricingLibrary.sol` pricing calculations.
   - Core router execution logic in `SageRouter.sol`.
