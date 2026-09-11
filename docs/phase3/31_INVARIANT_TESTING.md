# 31 — Stateful Invariant Testing Architecture

## 1. Handler-Based Invariant Model
Using `PairHandler`, Foundry executes **2,048 multi-actor randomized stateful calls** per invariant run across `addLiquidity`, `swap0For1`, and `swap1For0`:

```
                    RANDOM CALL GENERATOR
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
   addLiquidity()         swap0For1()          swap1For0()
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
                   INVARIANT VALIDATION:
                   1. Constant Product k > 0
                   2. Stored Reserves == Physical Balances
                   3. LP Token Supply Conservation
```

---

## 2. Invariant Verification Results
- **Runs**: 64 runs $\times$ 32 depth = 2,048 random stateful calls.
- **Reverts**: 0 reverts.
- **Result**: `100% PASS` across all properties.
