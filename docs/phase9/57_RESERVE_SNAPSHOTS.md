# 57 — Periodic Reserve Snapshots & Liquidity Depth

## 1. Snapshot Sampling
- Records pool reserve states at hourly block boundaries.
- Stores: `poolAddress`, `blockNumber`, `timestamp`, `reserve0`, `reserve1`, `price0`, `price1`.
- Powers long-term liquidity depth and historical TVL trend visualizations.
