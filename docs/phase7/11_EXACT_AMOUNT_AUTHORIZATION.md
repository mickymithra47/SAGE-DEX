# 11 — Exact-Amount Signature Authorization

## 1. Cryptographic Amount Invariant
- The requested transfer amount must never exceed the permitted amount signed by the user:
  `require(transferDetails.requestedAmount <= permitDetails.permitted.amount, "InsufficientAllowance");`
- If a user authorizes 100 USDC, an attempt to transfer 100.000001 USDC reverts immediately.
