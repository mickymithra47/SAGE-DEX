# 32 — Event Identity & Nonce Disambiguation

## 1. Multi-Event Transactions
- A single atomic transaction (e.g. multi-hop swap or flash swap) may emit multiple `Swap`, `Sync`, or `Transfer` events.
- Disambiguated strictly by EVM `logIndex` within the transaction receipt.
