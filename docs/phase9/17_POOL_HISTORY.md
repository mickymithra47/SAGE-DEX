# 17 — Pool Activity History & Transaction Streams

## 1. Pool Activity Queries
- Query parameters: `poolAddress`, `chainId`, `limit`, `cursor`.
- Delivers sequential swap, mint, and burn records sorted deterministically by `(blockNumber DESC, logIndex DESC)`.
