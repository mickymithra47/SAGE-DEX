# 09 — Quote vs Execution Lifecycle & Authority

## 1. Information vs Authority Model

```
OFF-CHAIN QUOTE (Informational)
       │
       ▼
USER EXPECTATION (Slippage Limits Chosen)
       │
       ▼
SUBMITTED TRANSACTION (minAmountOut Enforced)
       │
       ▼
ON-CHAIN POOL EXECUTION (Authoritative Source of Truth)
       │
       ▼
ACTUAL TOKENS DISBURSED
```

---

## 2. Invariant Guarantee
- An off-chain quote cannot bind the pool to an outdated price.
- The pool evaluates the exact state of `reserve0` and `reserve1` at the instant the transaction executes.
- If preceding trades move the price beyond the user's slippage limit, the transaction reverts atomically.
