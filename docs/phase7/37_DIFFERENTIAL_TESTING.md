# 37 — Differential Testing: Standard Approval vs Signature Flows

## 1. Execution Parity Verification
- **Test Setup**: Two identical pool states $(10,000 : 20,000)$ with two identical trade sizes (10 TKNA).
- **Execution 1**: Standard ERC-20 `approve()` + `swapExactTokensForTokens()`.
- **Execution 2**: EIP-2612 `permit()` + `swapExactTokensForTokensWithPermit()`.
- **Execution 3**: `Permit2.permitTransferFrom()` + `swapExactTokensForTokensWithPermit2()`.
- **Result**: Output token amounts received by trader are mathematically identical down to the exact wei across all three methods.
