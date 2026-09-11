# 41 — Phase 4 Complete System Architecture Map

## Full Protocol Component Topology

```
                                      TOKEN0          TOKEN1
                                        │               │
                                        └──────┬────────┘
                                               │
                                            AMM POOL
                                               │
                                   ┌───────────┼───────────┐
                                   │           │           │
                                RESERVES      SWAPS       FEES
                                   │                       │
                                   └───────────┬───────────┘
                                               │
                                          LP ACCOUNTING
                                               │
                                      ┌────────┴────────┐
                                      │                 │
                                  LP SHARES         LP OWNERSHIP
                                      │                 │
                               ┌──────┼──────┐          │
                               │      │      │          │
                              LP A   LP B   LP C       CLAIM
                                                       │
                                                TOKEN0 + TOKEN1
```
