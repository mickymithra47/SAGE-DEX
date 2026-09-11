# 19 — Token Spending Authorization vs Trade Intent

## 1. Clear Conceptual Boundary

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Spending Authorization (Phase 7)      │ Trade Intent Systems (Excluded)                        │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Authorizes token pull for execution   │ Off-chain trade intent / limit orders                  │
│ Strict execution via Sage Router     │ Dutch auctions / solver networks / fillers             │
│ On-chain deterministic routing        │ Off-chain smart order routing (SOR)                    │
│ Constant-product math (x * y = k)     │ Intent settlement protocols (UniswapX, CoW Swap)       │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
