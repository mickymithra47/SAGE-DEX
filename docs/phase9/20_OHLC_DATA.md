# 20 — Candlestick (OHLCV) Aggregation Engine

## 1. Supported Intervals
- `1m` (60 seconds), `5m` (300 seconds), `15m` (900 seconds), `1h` (3,600 seconds), `1d` (86,400 seconds).

---

## 2. Candle Bucket Formulation
$$\text{Bucket Timestamp} = \left\lfloor \frac{\text{swapTimestamp}}{\Delta t} \right\rfloor \cdot \Delta t$$

- **Open**: First realized spot price in bucket.
- **High**: Maximum spot price in bucket.
- **Low**: Minimum spot price in bucket.
- **Close**: Last realized spot price in bucket.
- **Volume**: Sum of underlying token flows $\sum (\text{amount0} + \text{amount1})$.
- No artificial candles are fabricated during periods with zero trades.
