# 01 — Pricing, Quoting & Oracle System Architecture

## 1. The Core Sovereign Principle
**THE AMM CONTRACT IS THE SOVEREIGN SOURCE OF TRUTH.**
Off-chain quoting and pricing contracts must reproduce on-chain pool execution mathematics down to the exact integer wei without drift or floating-point approximations.

```
                 FACTORY
                    │
                    ▼
                   PAIR
                    │
       ┌────────────┼────────────┐
       │            │            │
       ▼            ▼            ▼
    RESERVES       SWAP       LP ENGINE
       │            │            │
       └────────────┼────────────┘
                    │
                    ▼
             PRICING ENGINE
                    │
          ┌─────────┼─────────┐
          │         │         │
          ▼         ▼         ▼
       SPOT      QUOTES     IMPACT
       PRICE      │
                  ├── Exact Input
                  ├── Exact Output
                  └── Multi-hop
                    │
                    ▼
              ORACLE ENGINE
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
     CUMULATIVE PRICE       TWAP
          │                   │
          └─────────┬─────────┘
                    ▼
             ORACLE READ API
```
