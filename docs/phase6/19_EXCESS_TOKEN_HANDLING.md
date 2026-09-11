# 19 — Excess Token Handling & Zero-Retention Invariant

## 1. Exact-Input vs Exact-Output Pull Models
- **Exact-Input**: Router transfers exactly `amountIn = amounts[0]` from user to pool.
- **Exact-Output**: Router computes exact `requiredIn = amounts[0] <= amountInMax` and pulls only that exact amount from the user.
- **Result**: No excess ERC-20 tokens are ever pulled from the user, ensuring zero trapped tokens.
