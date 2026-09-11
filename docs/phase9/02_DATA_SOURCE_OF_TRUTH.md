# 02 — Data Authority & Source of Truth Hierarchy

## 1. Absolute Authority Hierarchy

```
   ┌──────────────────────────────────────────────┐
   │ 1. EVM BLOCKCHAIN (Canonical On-Chain State) │  <-- 100% Authoritative
   └──────────────────────┬───────────────────────┘
                          │
                          ▼
   ┌──────────────────────────────────────────────┐
   │ 2. INDEXER DATABASE (Derived Read Model)     │  <-- Non-Authoritative
   └──────────────────────┬───────────────────────┘
                          │
                          ▼
   ┌──────────────────────────────────────────────┐
   │ 3. CACHE LAYER (Ephemeral Acceleration)      │  <-- Transient
   └──────────────────────┬───────────────────────┘
                          │
                          ▼
   ┌──────────────────────────────────────────────┐
   │ 4. FRONTEND PRESENTATION                     │  <-- Display Only
   └──────────────────────────────────────────────┘
```

---

## 2. Inviolable Security Rule
- If the indexer database ever disagrees with the smart contract state: **THE BLOCKCHAIN WINS**.
- Indexed data must NEVER alter smart contract execution, slippage bounds, or settlement.
