# 03 — Fixed-Point Price Representation & Arithmetic Precision

## 1. Selected Price Representations

```
┌─────────────────────────┬───────────────────────────────┬────────────────────────────────────────────────────────┐
│ Context                 │ Encoding Format               │ Rationale                                              │
├─────────────────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Spot Pricing & Quotes   │ 18-Decimal Fixed-Point (WAD)  │ Standard EVM token precision (1e18); human-readable.   │
│ Price Impact & Slippage │ Basis Points (BPS)            │ 1 BPS = 0.01%; 10,000 = 100.00%.                       │
│ TWAP Accumulators       │ Binary Fixed-Point (UQ112x112)│ 112 fractional bits; prevents overflow over 100+ years.│
└─────────────────────────┴───────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 2. Why Not `sqrtPriceX96` in V2 AMM?
- `sqrtPriceX96` is specialized for tick math in V3 concentrated liquidity.
- In constant-product AMMs ($x \cdot y = k$), linear WAD scaling provides optimal gas efficiency, high precision, and simplicity without unnecessary square root operations on every quote.
