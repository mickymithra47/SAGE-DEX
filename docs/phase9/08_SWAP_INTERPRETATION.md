# 08 — Swap Interpretation & Direction Normalization

## 1. Directional Mapping Matrix

```
┌──────────────────────────────────────┬───────────┬────────────┬───────────┬────────────┐
│ Event State                          │ Token In  │ Token Out  │ Amount In │ Amount Out │
├──────────────────────────────────────┼───────────┼────────────┼───────────┼────────────┤
│ amount0In > 0 && amount1Out > 0      │ token0    │ token1     │ amount0In │ amount1Out │
│ amount1In > 0 && amount0Out > 0      │ token1    │ token0     │ amount1In │ amount0Out │
└──────────────────────────────────────┴───────────┴────────────┴───────────┴────────────┘
```

- Decouples raw slot index indexing from human-readable token directions.
