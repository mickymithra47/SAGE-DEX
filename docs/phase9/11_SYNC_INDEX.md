# 11 — Sync Event Ingestion & Reserve Reconciliation

## 1. Event Signature
```solidity
event Sync(uint112 reserve0, uint112 reserve1);
```
- Topic: `0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1`

---

## 2. Reserve Snapshot Update
- Immediately updates `pool.reserve0` and `pool.reserve1` in the database.
- Provides point-in-time reserve state for exact price calculations.
