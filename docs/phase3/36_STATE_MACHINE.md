# 36 — Core Contract State Machine & Lifecycle Transitions

## Pool State Machine Transitions

```
                    ┌─────────────────────────┐
                    │       UNCREATED         │
                    └────────────┬────────────┘
                                 │
                                 │ Factory.createPair()
                                 ▼
                    ┌─────────────────────────┐
                    │         CREATED         │
                    └────────────┬────────────┘
                                 │
                                 │ Pair.initialize()
                                 ▼
                    ┌─────────────────────────┐
                    │       INITIALIZED       │
                    │   (Reserves: 0, 0)      │
                    └────────────┬────────────┘
                                 │
                                 │ Pair.mint() [First Liquidity + 1000 Lock]
                                 ▼
                    ┌─────────────────────────┐
                    │         ACTIVE          │
                    │   (Reserves: r0, r1)    │
                    └────────────┬────────────┘
                                 │
            ┌────────────────────┼────────────────────┐
            ▼                    ▼                    ▼
       Pair.swap()          Pair.mint()          Pair.burn()
   (Swaps & Fee Yield)   (Additional LP)     (Redeem Liquidity)
```
