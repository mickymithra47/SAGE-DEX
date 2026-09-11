# 23 — Mempool Front-Running & Signature Submission Analysis

## 1. What a Front-Runner Can Do
- If a third party submits a user's signed transaction to the router:
  - The swap executes exactly as specified by the user.
  - The output tokens are delivered directly to the user's recipient address (`to`).
  - The submitter pays the gas cost.

---

## 2. What a Front-Runner CANNOT Do
- Cannot redirect input tokens to themselves (blocked by `spender` and `to` binding).
- Cannot alter slippage limits (`amountOutMin` check in router).
- Cannot extract unauthorized funds from the user's wallet.
