# 17 — Direct Token Donations & Reserve vs Balance Accounting

## 1. Physical Balance vs Stored Reserve Separation
When tokens are sent directly to the pool contract (`token.transfer(pair, amount)`):
- Physical balance `balance0` increases.
- Stored reserve `reserve0` remains strictly unchanged.

---

## 2. Who Benefits from Direct Donations?
- Donated tokens remain unindexed until a subsequent operation (`mint`, `burn`, `sync`, or `skim`).
- **If `sync()` is called**: Donated tokens are absorbed into `reserve0`, instantly increasing the claimable assets per LP share and benefiting all current LPs proportionally.
- **If `skim(to)` is called**: Anyone can sweep the unindexed tokens to an external address without disturbing reserves.
- **If `mint()` is called**: The balance delta measures the donation as deposited collateral, minting LP shares based on the unindexed surplus.
