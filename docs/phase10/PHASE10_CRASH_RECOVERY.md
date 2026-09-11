# Phase 10 — Crash Recovery & Atomic Idempotency

## 1. Crash Verification
- Uncommitted transactions are dropped upon process failure.
- Restart resumes from the last committed block cursor.
- Deterministic primary keys `(chainId, txHash, logIndex)` ensure re-processed blocks produce 0 duplicate records.
