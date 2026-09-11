# 30 — Relational Database Schema & Constraint Modeling

## 1. Schema Tables Overview
- `blocks`: Chain headers, hash, parent hash, and canonical status.
- `tokens`: Checksummed address, symbol, name, decimals.
- `pools`: Token0, token1, factory, creation block, dynamic reserves.
- `swaps`, `mints`, `burns`, `syncs`: Event ledgers keyed by `(chainId, txHash, logIndex)`.
- `lp_positions`: Materialized LP balances per user and pool.
- `candles`: Multi-timeframe OHLCV aggregated buckets.
