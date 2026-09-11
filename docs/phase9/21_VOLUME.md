# 21 — Trading Volume Analytics & Aggregation

## 1. Volume Calculation
- Quantified strictly in native underlying units: `volumeToken0` and `volumeToken1`.
- Aggregates rolling 24-hour and all-time volumes per liquidity pool.
- Avoids fabricating USD valuations when reliable reference quotes are absent.
