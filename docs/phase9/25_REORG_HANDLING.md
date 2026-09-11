# 25 — Blockchain Reorganization Detection & Rollback Engine

## 1. Reorg Detection Mechanism
```
Incoming Block N (Parent: P_new)
          │
          ▼
Compare with Indexed Block N-1 (Hash: H_old)
          │
  ┌───────┴───────┐
  │               │
  ▼               ▼
P_new == H_old  P_new != H_old
(Linear Chain)   (REORGANIZATION DETECTED)
                  │
                  ▼
         Find Common Ancestor (Block K)
                  │
                  ▼
         Rollback Blocks K+1 ... N-1
                  │
                  ▼
         Replay New Canonical Chain
```

---

## 2. Atomic Rollback Guarantees
- Swaps, Mints, Burns, and Syncs associated with orphaned blocks are purged atomically in a single transactional rollback.
- LP positions and candlestick data are recalculated from the common ancestor.
