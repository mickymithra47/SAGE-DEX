# 10 — Balance Checking & Client-Side Pre-Flight Validation

## 1. Solvency Pre-Flight Check
Before permitting transaction submission:
$$\text{walletBalance} \ge \text{amountIn}$$

- If balance is insufficient, the action button switches to `Insufficient [Token] Balance` and disables submission.
- Prevents users from wasting gas on transactions guaranteed to revert on-chain.
