# 28 — Live Indexing & Head Subscription Mechanics

## 1. Head Follower Loop
1. Polls new blocks via `eth_blockNumber` / `newHeads` subscription.
2. Ingests latest block and associated contract logs.
3. Checks parent hash consistency.
4. Commits events and updates latest indexed block pointer.
