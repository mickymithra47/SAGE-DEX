# Phase 12 — Operations & Maintenance Runbook

## 1. Daily Operations Runbook
1. Check Indexer health status: `curl http://localhost:4000/api/v1/health`.
2. Inspect Prometheus metrics for zero RPC errors and low block lag.
3. Review on-chain state reconciliation reports.
4. Verify frontend quote response times (< 100ms).
