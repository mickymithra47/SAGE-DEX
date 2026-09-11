# 06 — Token Discovery & Metadata Resilience

## 1. Metadata Ingestion
- Fetches `symbol()`, `name()`, and `decimals()` via `eth_call`.
- Where metadata reverts or is missing (non-standard ERC-20), the indexer preserves the blockchain address as canonical identity without fabricating names.
