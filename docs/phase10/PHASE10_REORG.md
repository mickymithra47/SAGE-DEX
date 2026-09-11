# Phase 10 — Blockchain Reorganization Handling

## 1. Reorg Detection & Rollback Flow
1. Verify `newBlock.parentHash == previousIndexedBlock.blockHash`.
2. On mismatch, search backwards for common ancestor block $K$.
3. Execute `rollbackBlocksAbove(chainId, K)`.
4. Ingest and replay new canonical branch.
