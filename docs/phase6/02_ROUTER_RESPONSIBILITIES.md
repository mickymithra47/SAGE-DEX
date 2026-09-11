# 02 — Router Responsibilities vs Out-of-Scope Boundaries

## 1. What the Router Owns

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Responsibility                        │ Description                                            │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ User Entry Point                      │ Public methods for executing swaps with safe defaults. │
│ Deadline Enforcement                  │ Reverting transactions if block.timestamp > deadline.  │
│ Slippage Enforcement                  │ Ensuring amountOut >= amountOutMin & in <= amountInMax.│
│ Sequential Multi-Hop Routing          │ Directing output of Pair N directly into Pair N+1.     │
│ Native ETH Handling                   │ Wrapping ETH -> WETH and unwrapping WETH -> ETH.       │
│ Recipient Safety                      │ Validating to != address(0) & to != address(this).     │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 2. Strict Exclusions (What the Router Must NOT Do)
- Must NOT act as an AMM pricing authority.
- Must NOT store or hold persistent token/ETH balances.
- Must NOT implement cross-DEX aggregation or off-chain order books.
- Must NOT implement arbitrary bytecode dispatchers (No Universal Router).
