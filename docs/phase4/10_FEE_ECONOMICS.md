# 10 — Fee Economics: In-Pool Accrual vs Separate Distribution

## 1. Fee Architectural Comparison

```
┌───────────────────────────────┬───────────────────────────────────┬───────────────────────────────────┐
│ Feature                       │ Model A: In-Pool Reserve Growth   │ Model B: Separate Fee Vaults      │
├───────────────────────────────┼───────────────────────────────────┼───────────────────────────────────┤
│ 1. Runtime Gas Overhead       │ 0 gas (Automatic via invariant)   │ High (External transfers per swap)│
│ 2. Storage Overhead           │ 0 new storage slots               │ Multiple balance mappings per LP  │
│ 3. Compounding Yield          │ Automatic (Compounded into k)     │ Manual reinvestment required      │
│ 4. DeFi Composability         │ Standard ERC-20 LP token          │ Complex multi-token reward claims │
│ 5. Audit & Security Surface   │ Minimal                           │ Substantial (claim reentrancy)    │
└───────────────────────────────┴───────────────────────────────────┴───────────────────────────────────┘
```

---

## 2. Sage AMM Selection: Model A
Sage implements **Model A**:
- Swap fees (0.3%) remain inside the pool's physical token reserves.
- Monotonically grows the constant product invariant $k = x \cdot y$.
- Appreciation is realized naturally when an LP calls `pair.burn()`.
