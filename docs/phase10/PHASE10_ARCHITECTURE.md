# Phase 10 — Architecture Specification

## 1. System Topology

```
                 BLOCKCHAIN (EVM Node / RPC)
                      │
              ┌───────┴───────┐
              │               │
            STATE           EVENTS
        (getReserves)    (PairCreated, Swap, Mint, Burn, Sync)
              │               │
              └───────┬───────┘
                      ▼
                   INDEXER
                      │
          ┌───────────┼───────────┐
          │           │           │
        POOLS       SWAPS        LPs
          │           │           │
          └───────────┼───────────┘
                      ▼
                 POSTGRESQL
                      │
                ┌─────┴─────┐
                │           │
               API         CACHE
                │           │
                └─────┬─────┘
                      │
              ┌───────┴───────┐
              │               │
          FRONTEND           AI
              │               │
              └───────┬───────┘
                      ▼
              TRANSACTION FLOW
                      │
                      ▼
                 USER WALLET
                      │
                    SIGN
                      │
                      ▼
                   ROUTER
                      │
                      ▼
                    AMM
```

---

## 2. Core Separation Invariant
- The indexing layer is strictly a derived read model.
- Hierarchy: `BLOCKCHAIN > INDEXER > DATABASE > CACHE > FRONTEND/AI`.
