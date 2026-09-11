# 13 — Quote Staleness & Freshness Tracking

## 1. Staleness Invalidation Rules
- Quotes older than 15 seconds or from prior block heights are flagged as stale.
- The UI highlights stale quotes with a pulsing refresh icon and requires re-verification before transaction execution.
