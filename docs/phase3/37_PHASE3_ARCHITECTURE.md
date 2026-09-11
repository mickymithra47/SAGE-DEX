# 37 — Phase 3 Complete System Architecture Map

## Full Protocol Component Map

```
                                      AKIRA FACTORY
                                            │
                           ┌────────────────┴────────────────┐
                           │ CREATE2 Deterministic Deployment│
                           ▼                                 ▼
                     AKIRA PAIR (A/B)                  AKIRA PAIR (C/D)
                           │
       ┌───────────────────┼───────────────────┐
       ▼                   ▼                   ▼
    Reserves           Swap Engine         LP Tokens
  (Slot 3 Packed)   (Optimistic / Delta)  (SageERC20)
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                           ▼
                    INVARIANT CHECK
              (1000*x - 3*Δx)(1000*y - 3*Δy) >= 1000^2 * x0 * y0
```
