# Phase 10 — PostgreSQL Database & Schema Architecture

## 1. Relational Schema & Constraints
- Uses `NUMERIC` types for large token quantities (`bigint`).
- Strict unique constraints on `(chainId, txHash, logIndex)` prevent duplicate event records.
- Foreign keys bind pools to canonical token registry records.
