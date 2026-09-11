# 24 — Block Ingestion & Cursor Checkpointing

## 1. Block Header Tracking
- Records: `chainId`, `blockNumber`, `blockHash`, `parentHash`, `timestamp`, `isCanonical`.
- The database maintains an active cursor pointing to the highest canonical block indexed.
- Backfill resumes from the latest verified block header without re-scanning genesis.
