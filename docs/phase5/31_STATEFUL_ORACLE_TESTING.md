# 31 — Stateful Invariant Oracle Testing

## 1. Handler State Machine Model
`OracleHandler` executes randomized sequences of swaps, time warps ($\Delta t \in [10s, 3600s]$), and oracle updates across **2,048 state transitions**:

```
                       RANDOMIZED ORACLE STATE MACHINE
                                      │
                     ┌────────────────┴────────────────┐
                     ▼                                 ▼
                  swap0()                    advanceTimeAndUpdate()
                     │                                 │
                     └────────────────┬────────────────┘
                                      │
                                      ▼
                           INVARIANT VERIFICATION:
                Cumulative price accumulators monotonically non-decreasing
```

---

## 2. Invariant Results
- Executed 64 runs $\times$ 32 depth = 2,048 calls.
- `100% PASS` with 0 state corruption errors.
