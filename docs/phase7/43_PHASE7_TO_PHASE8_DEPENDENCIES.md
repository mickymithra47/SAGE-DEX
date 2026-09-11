# 43 — Phase 7 to Phase 8 Dependency Report (Frontend & Wallet Integration)

## 1. Phase 7 Accomplishments & Stabilized Surface
- `Permit2`: Canonical contract supporting `permit`, `permitTransferFrom`, `permitWitnessTransferFrom`, and bitmap nonces.
- `SagePermitRouter`:
  - `swapExactTokensForTokensWithPermit`
  - `swapExactTokensForTokensWithPermit2`
  - Standard Phase 6 swap methods (`swapExactTokensForTokens`, `swapTokensForExactTokens`, `swapExactETHForTokens`, etc.)

---

## 2. Interface Handoff for Phase 8 (Frontend & Wallet Integration)

### 1. Calldata & Signature Requirements
- **EIP-712 Typed Data for Permit2**:
  - Domain: `name: "Permit2", chainId: <current_chain_id>, verifyingContract: <permit2_address>`
  - Types: `PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)`
  - Parameter values: User wallet address, Token address, amount, router address as spender, random/sequential nonce, deadline timestamp.

### 2. Transaction Flow Selection
1. **Flow A (Standard ERC-20 Approval)**:
   - Check `token.allowance(user, router) >= amountIn`.
   - If insufficient: Send `token.approve(router, amountIn)`.
   - Send `router.swapExactTokensForTokens(...)`.
2. **Flow B (EIP-2612 Permit)**:
   - Sign EIP-2612 permit typed data.
   - Send `router.swapExactTokensForTokensWithPermit(..., v, r, s)`.
3. **Flow C (Permit2 Signature Transfer — Recommended)**:
   - One-time unlimited approval: `token.approve(permit2, type(uint256).max)`.
   - For all subsequent swaps: Sign EIP-712 Permit2 payload off-chain.
   - Send `router.swapExactTokensForTokensWithPermit2(..., permitDetails, signature)`.

---

## 3. What Phase 8 Must NOT Modify
- Core AMM pool mathematics ($x \cdot y = k$).
- Constant-product pair reserve state transitions.
- Pricing and quoting math in `SagePricingLibrary`.
- Permit2 internal verification and bitmap logic.
