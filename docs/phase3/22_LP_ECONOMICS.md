# 22 — Liquidity Provider Economics & Impermanent Loss

## 1. The LP Economic Balance
Liquidity Providers face two competing economic forces:

$$\text{Net LP Profit} = \sum \text{Fee Yield Accrued} - \text{Impermanent Loss}$$

---

## 2. Impermanent Loss (Divergence Loss)
When relative asset prices shift by ratio $r = \frac{P_{\text{new}}}{P_{\text{initial}}}$:

$$\text{Impermanent Loss (IL)} = \frac{2 \sqrt{r}}{1 + r} - 1$$

```
┌───────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Price Ratio Shift (r)                 │ Impermanent Loss %                                          │
├───────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ 1.25x (+25% price change)             │ -0.6%                                                       │
│ 1.50x (+50% price change)             │ -2.0%                                                       │
│ 2.00x (+100% price change / double)   │ -5.7%                                                       │
│ 3.00x (+200% price change / triple)   │ -13.4%                                                      │
│ 5.00x (+400% price change)            │ -25.5%                                                      │
└───────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
```

- **Impermanent**: If relative prices return to the original ratio, the loss returns to 0%, while accumulated trading fees remain permanent gains.
