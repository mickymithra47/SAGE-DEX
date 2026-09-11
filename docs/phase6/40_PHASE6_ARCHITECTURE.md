# 40 — Phase 6 Complete System Architecture Map

## Full Protocol Topology Post-Phase 6

```
                         FACTORY
                            │
                            ▼
                           PAIR
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
          RESERVES         SWAP        LP ENGINE
                            │
                            ▼
                      PRICING ENGINE
                            │
                ┌───────────┼───────────┐
                ▼           ▼           ▼
             SPOT        QUOTES       TWAP
                │
                ▼
             ROUTER
                │
        ┌───────┼────────┐
        ▼       ▼        ▼
    SINGLE    MULTI    NATIVE
     HOP       HOP      TOKEN
        │       │        │
        └───────┼────────┘
                ▼
             TOKENS
                │
                ▼
             USER
```
