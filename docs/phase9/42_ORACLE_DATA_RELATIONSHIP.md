# 42 — Indexer Data vs Phase 5 On-Chain TWAP Oracle

## 1. Clear Separation of Roles
- **Phase 5 Oracle**: On-chain UQ112x112 cumulative price accumulators used by smart contracts for manipulation-resistant settlement.
- **Phase 9 Indexer**: Off-chain historical candle charts and UI display data.
- The indexer does NOT replace or override the on-chain oracle.
