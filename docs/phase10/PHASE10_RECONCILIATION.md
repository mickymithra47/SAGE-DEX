# Phase 10 — State Reconciliation & Consistency Monitoring

## 1. Periodic Comparator
- Queries on-chain `SagePair.getReserves()`.
- Compares against database `reserve0` and `reserve1`.
- Inconsistencies trigger structured anomaly alerts without automated state corruption.
