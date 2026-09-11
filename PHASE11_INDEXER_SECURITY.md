# Phase 11 — Indexer Integrity & Reorg Security

## 1. Indexer Security Invariants
- **Non-Authoritative Read Layer**: The indexer is strictly a derived read model.
- **Atomic Reorg Rollback**: When a block reorganization occurs, non-canonical logs are purged atomically back to the common ancestor block.
- **Deterministic Event Primary Keys**: Keyed by `(chainId, txHash, logIndex)` to ensure strict idempotency.
