# 01 — Frontend Architecture & Layer Separation

## 1. Modular Web3 Topology

```
                              AKIRA WEB APPLICATION
                                        │
           ┌────────────────────────────┼────────────────────────────┐
           ▼                            ▼                            ▼
      WALLET LAYER                 QUOTE LAYER                  TOKEN REGISTRY
  (Wagmi / Injected)          (Viem / On-Chain Reads)         (Metadata & Balances)
           │                            │                            │
           └────────────────────────────┼────────────────────────────┘
                                        ▼
                               TRANSACTION BUILDER
                                        │
                                        ▼
                                SIMULATION LAYER
                                        │
                                        ▼
                               WALLET SIGN / SUBMIT
                                        │
                                        ▼
                             TRANSACTION STATE MACHINE
                       (IDLE -> QUOTING -> APPROVAL -> ...)
                                        │
                                        ▼
                                    EVM RPC
                                        │
                                        ▼
                              AKIRA PERMIT ROUTER
                                        │
                                        ▼
                                   AKIRA PAIR
```

---

## 2. Core Separation Principle
- The UI layer strictly handles user inputs, presentation, and wallet requests.
- The blockchain smart contracts retain sovereign authority over reserves, pricing, invariants ($x \cdot y = k$), and authorizations.
