# 01 — Swap Execution & Router System Architecture

## 1. System Execution Topology

```
                         USER
                           │
                           ▼
                      AKIRA ROUTER
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
       SINGLE-HOP      MULTI-HOP     NATIVE ETH
          SWAP           SWAP       WRAP/UNWRAP
             │             │             │
             └─────────────┼─────────────┘
                           │
                           ▼
                    AMM PAIR(S)
             (Sovereign Invariant Authority)
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
      TOKEN TRANSFERS             RESERVE UPDATES
             │                           │
             └─────────────┬─────────────┘
                           ▼
                    FINAL SETTLEMENT
```

---

## 2. The Core Sovereign Authority Rule
- The `SageRouter` is strictly a **stateless execution coordinator**.
- The `SagePair` is the **sovereign authority** for token reserves, invariant ($x \cdot y = k$) enforcement, and fee deduction.
- The Router does NOT alter or recalculate the AMM invariant.
