# 14 — Price Movements, Reserve Drift & LP Asset Exposure

## 1. Asset Exposure in an AMM Pool
When the external market price of an asset changes:
- Traders trade against the pool until the pool's marginal price aligns with external consensus.
- As Token0 appreciates relative to Token1, the pool automatically sells Token0 to arbitrageurs and accumulates Token1.
- As a result, LPs hold fewer units of the appreciating asset and more units of the depreciating asset.

---

## 2. Rebalancing Dynamics
```
Price Shift Direction  │ Pool Reserve Response              │ LP Asset Holding Effect
───────────────────────┼────────────────────────────────────┼─────────────────────────────────
Token0 Price Doubles   │ Pool sells Token0, buys Token1     │ LP holds 0.707x Token0, 1.414x Token1
Token0 Price Halves    │ Pool buys Token0, sells Token1     │ LP holds 1.414x Token0, 0.707x Token1
```
