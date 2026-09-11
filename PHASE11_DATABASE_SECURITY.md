# Phase 11 — Database Security & Data Conservation

## 1. Storage Integrity
- Exact `NUMERIC` types used for financial quantities.
- Unique constraints enforce that identical event topics from the same transaction and log index cannot create duplicate entries.
- Reorgs execute rollback via single atomic database transactions.
