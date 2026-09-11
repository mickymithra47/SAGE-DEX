# 46 — Crash Recovery & Transactional Resumption

## 1. Crash Invariants
- **Crash before DB commit**: No partial records inserted; restart re-queries the pending block.
- **Crash after DB commit, before cursor update**: Idempotent upserts ensure re-processing the block creates 0 duplicates.
- Zero state corruption on hard process kills.
