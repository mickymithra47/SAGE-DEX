# 38 — Phase 5 Complete System Architecture Map

## Full Protocol Topology Post-Phase 5

```
                                      FACTORY
                                         │
                                         ▼
                                        PAIR
                                         │
                   ┌─────────────────────┼─────────────────────┐
                   │                     │                     │
                   ▼                     ▼                     ▼
                RESERVES                SWAP               LP ENGINE
             (Slot 3 Packed)       (0.30% Fee)            (Fungible)
                   │                     │                     │
                   └─────────────────────┼─────────────────────┘
                                         │
                                         ▼
                                  PRICING ENGINE
                                         │
                       ┌─────────────────┼─────────────────┐
                       │                 │                 │
                       ▼                 ▼                 ▼
                  SPOT PRICE         QUOTER ENGINE     PRICE IMPACT
                  (1e18 WAD)             │               (1-10000 BPS)
                                         ├── Exact-Input
                                         ├── Exact-Output
                                         └── Multi-Hop
                                         │
                                         ▼
                                   ORACLE ENGINE
                                         │
                               ┌─────────┴─────────┐
                               ▼                   ▼
                          CUMULATIVE PRICE       TWAP
                          (UQ112x112 Bits)    (Sliding Lookback)
                               │                   │
                               └─────────┬─────────┘
                                         ▼
                                  ORACLE READ API
```
