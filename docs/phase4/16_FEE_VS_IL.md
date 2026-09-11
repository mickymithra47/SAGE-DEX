# 16 — Fee Yield vs Impermanent Loss Net Profitability

## 1. The LP Profitability Equation

$$\text{Net LP Profit} = \text{Fee Yield Accrued} - \text{Impermanent Loss} - \text{Gas Overhead}$$

```
┌───────────────────────┬───────────────────┬────────────────────────────────────────────────────────┐
│ Price Movement (r)    │ Impermanent Loss  │ Trading Volume Required for Profitability (0.3% Fee)   │
├───────────────────────┼───────────────────┼────────────────────────────────────────────────────────┤
│ 1.25x (+25%)          │ -0.60%            │ Cumulative Volume >= 2.0x Pool TVL                     │
│ 1.50x (+50%)          │ -2.00%            │ Cumulative Volume >= 6.7x Pool TVL                     │
│ 2.00x (+100%)         │ -5.72%            │ Cumulative Volume >= 19.1x Pool TVL                    │
│ 3.00x (+200%)         │ -13.40%           │ Cumulative Volume >= 44.7x Pool TVL                    │
│ 5.00x (+400%)         │ -25.50%           │ Cumulative Volume >= 85.0x Pool TVL                    │
└───────────────────────┴───────────────────┴────────────────────────────────────────────────────────┘
```
