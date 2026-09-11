# 58 — Data Retention & Tiered Storage Lifecycle

## 1. Storage Tiering
- **Permanent (Indefinite)**: Core transaction events (`Swap`, `Mint`, `Burn`, `Sync`), Blocks, Pools, Tokens, LP Positions.
- **Aggregated (1 Year)**: High-resolution `1m` and `5m` candles (downsampled to `1h` after 90 days).
- **Temporary (24 Hours)**: Transient cache keys and unfinalized block traces.
