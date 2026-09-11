# 36 — Local Transaction Tracker & Persistence

## 1. Storage Topology
- Stores executed transactions in browser `localStorage` keyed by `account_chainId`.
- Records: `hash`, `timestamp`, `type` (Swap / Add / Remove / Approve), `tokens`, `amounts`, `status`.
- Zero external backend tracker dependency.
