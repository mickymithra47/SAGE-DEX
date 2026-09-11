# 38 — Cache Layer & Invalidation Mechanics

## 1. Multi-Tier Cache Invalidation
- **Token Metadata**: In-memory / Redis cache with indefinite TTL (immutable metadata).
- **Pool 24h Stats**: Cached with 10-second TTL.
- **Cache Authority**: The cache is purely an acceleration mechanism. Reorg events trigger immediate cache flushes.
