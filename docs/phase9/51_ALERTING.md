# 51 — Operational Alerting & Anomaly Triggers

## 1. High-Priority Alert Triggers
- **Lag > 50 blocks**: Indexer process stalled or severely degraded.
- **Reconciliation Mismatch**: DB reserve differs from on-chain `Pair.getReserves()`.
- **Reorg Depth > 10 blocks**: Deep reorganization on the underlying chain.
