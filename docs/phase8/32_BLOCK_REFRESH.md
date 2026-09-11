# 32 — Block-Based Auto-Refresh & Head Subscription

## 1. Head Polling
- Listens to `publicClient.watchBlockNumber`.
- Triggers background re-evaluation of spot prices, user allowances, and open position values without blocking UI interaction.
