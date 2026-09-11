# Phase 12 — Rollback Procedures & Incident Response

## 1. Subsystem Rollback Procedures
- **Web Frontend**: Roll back static CDN asset bundle to previous stable Git commit hash.
- **API & Indexer**: Re-deploy previous container image and execute `rollbackBlocksAbove(chainId, targetBlock)` if reorg unwinding is needed.
- **Smart Contracts**: Smart contracts are immutable. In the event of a catastrophic issue, trading is paused via frontend parameter disabling and LP withdrawal is executed directly through verified pair contracts.
