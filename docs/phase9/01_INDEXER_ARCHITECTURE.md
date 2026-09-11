# 01 — Indexer Architecture & Data Flow

## 1. Master System Topology

```
                     BLOCKCHAIN (EVM Node / RPC)
                                 │
                  ┌──────────────┴──────────────┐
                  │                             │
                  ▼                             ▼
            CONTRACT STATE                   EVENTS
          (Reserves/Balances)      (PairCreated, Swap, Mint, Burn, Sync)
                  │                             │
                  └──────────────┬──────────────┘
                                 ▼
                         AKIRA EVENT INGESTOR
                     (Adaptive Batch Block Poller)
                                 │
       ┌─────────────────────────┼─────────────────────────┐
       ▼                         ▼                         ▼
   POOL & TOKEN INDEX      SWAP & VOLUME INDEX      LP POSITION INDEX
       │                         │                         │
       └─────────────────────────┼─────────────────────────┘
                                 ▼
                       DATABASE / REORG ENGINE
                 (PostgreSQL Schema / SQLite Engine)
                                 │
                 ┌───────────────┴───────────────┐
                 ▼                               ▼
          GRAPHQL / REST API            RECONCILIATION JOB
         (Cursor Pagination)        (On-Chain vs DB Comparator)
                 │                               │
                 ▼                               ▼
         FRONTEND / ANALYTICS             HEALTH & ALERTS
```

---

## 2. Core Responsibilities
- **Discovery**: Automatically detects new liquidity pools created on `SageFactory`.
- **Historical Reconstruction**: Ingests and interprets all swaps, mints, burns, and syncs.
- **Analytics**: Derives 24-hour rolling volume, protocol swap fees, and multi-timeframe OHLCV candlesticks.
- **Reorg-Aware**: Automatically unwinds invalid state if a chain reorganization occurs.
