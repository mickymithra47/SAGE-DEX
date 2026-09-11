# Phase 12 — Observability, Monitoring & Alerting

## 1. Metrics & Alarms
- **Prometheus Metrics**: `blocks_processed_total`, `events_processed_total`, `indexer_lag_blocks`, `rpc_errors_total`, `reorgs_total`.
- **Operational Alerts**:
  - High Lag: Triggered if `indexer_lag_blocks > 50`.
  - State Discrepancy: Triggered if `ReconciliationJob` detects a non-zero reserve delta against `Pair.getReserves()`.
