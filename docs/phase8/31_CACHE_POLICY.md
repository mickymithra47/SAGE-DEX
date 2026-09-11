# 31 — Caching Policies & Memory Lifecycle

## 1. Multi-Tier Cache Invalidation
- **Static Metadata (Token Symbol, Decimals)**: Cached in memory indefinitely per session.
- **Semi-Static (Factory Pairs)**: Cached for 5 minutes.
- **Dynamic (Reserves, Allowances, Quotes)**: Freshly fetched on block updates or user interactions.
