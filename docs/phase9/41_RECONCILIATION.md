# 41 — Blockchain vs Database State Reconciliation

## 1. Reconciliation Workflow
```
   INDEXER DATABASE (reserves)       ON-CHAIN SMART CONTRACT (getReserves())
                │                                    │
                └─────────────────┬──────────────────┘
                                  ▼
                         RECONCILIATION JOB
                                  │
                          ┌───────┴───────┐
                          │               │
                          ▼               ▼
                      MATCH (0 delta)  MISMATCH (delta > 0)
                          │               │
                          ▼               ▼
                      LOG HEALTH      ALERT & RECORD DISCREPANCY
```

- Mismatches trigger high-priority alerts without blind data overwrites.
