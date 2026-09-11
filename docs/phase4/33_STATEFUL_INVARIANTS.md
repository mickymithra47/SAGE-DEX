# 33 — Stateful LP Invariant Testing Architecture

## 1. Multi-Actor Handler State Machine
`LPHandler` models 3 independent actors (Alice, Bob, Carol) executing randomized multi-step workflows:

```
                          STATE TRANSITION GENERATOR
                                       │
                ┌──────────────────────┼──────────────────────┐
                ▼                      ▼                      ▼
             deposit()               burn()            transferShares()
                │                      │                      │
                └──────────────────────┼──────────────────────┘
                                       │
                                       ▼
                            INVARIANT ASSERTIONS:
                 1. Total Supply == ∑ User Balances + 1000 Dead Shares
                 2. Stored Reserves == Physical Token Balances
```

---

## 2. Invariant Test Results
- **Test Suite**: `test/phase4/invariant/LPInvariant.t.sol`
- **Execution**: 64 runs $\times$ 32 depth = 2,048 calls.
- **Result**: `100% PASS` with 0 reverts and 0 invariant violations.
