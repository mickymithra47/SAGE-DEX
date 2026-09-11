# 13 — Core Swap Engine & Optimistic Execution Architecture

## 1. The Core Swap Execution Pipeline
The `SagePair.swap()` method is the financial engine of the DEX:

```
TRADER / ROUTER
 │
 ├── 1. Pre-transfers input tokens to Pair (or initiates flash borrow)
 │
 └── 2. Invokes pair.swap(amount0Out, amount1Out, to, data)
      │
      ├── [Phase 1: Validation]
      │     Validates requested output > 0 and output < current reserve
      │
      ├── [Phase 2: Optimistic Transfer]
      │     Transfers output tokens to `to` BEFORE checking payment!
      │
      ├── [Phase 3: Flash Swap Callback]
      │     If data.length > 0, invokes ISageCallee(to).sageCall()
      │
      ├── [Phase 4: Balance Delta Inspection]
      │     Reads physical balances: balance0 and balance1
      │     Computes actual input: amount0In and amount1In
      │
      ├── [Phase 5: Invariant Verification]
      │     Validates (1000*bal0 - 3*a0In) * (1000*bal1 - 3*a1In) >= 1000^2 * r0 * r1
      │
      ├── [Phase 6: State Update]
      │     Updates reserves and cumulative price accumulators
      └── Emits Swap(...)
```

---

## 2. Why Optimistic Transfers Enable Flash Swaps
By transferring output tokens to the recipient *first* and verifying payment *after* an optional callback:
1. Traders can execute **Flash Swaps**: borrow arbitrary pool assets without upfront collateral, execute multi-DEX liquidations or arbitrage, and repay the loan + fee in the same transaction.
2. If the borrower fails to return sufficient funds, the final invariant check reverts, rolling back the entire transaction atomically.
