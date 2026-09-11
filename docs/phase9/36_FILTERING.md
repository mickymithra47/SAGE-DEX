# 36 — Query Filtering & Guarded Parameters

## 1. Supported Query Filters
- `pool`: Filter events by specific pair contract address.
- `user`: Filter swaps, mints, and burns by user wallet address.
- `fromBlock` / `toBlock`: Explicit historical window filtering.
- `startTime` / `endTime`: Timestamp boundary filtering.
- Hard maximum limit of 100 records per page prevents server memory exhaustion.
