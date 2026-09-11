# 26 — Atomic Permit + Swap Execution & Revert Semantics

## 1. Unified Atomicity Guarantee
In both `swapExactTokensForTokensWithPermit` and `swapExactTokensForTokensWithPermit2`:
- If the signature is valid, tokens are transferred.
- If the swap subsequently breaches `amountOutMin` or recipient rejects ETH:
  - **The entire transaction reverts.**
  - In Permit2, the nonce consumption also rolls back, leaving the signature potentially valid until expiration.
  - In EIP-2612 on-chain permit, the permit approval state write is rolled back atomically.
