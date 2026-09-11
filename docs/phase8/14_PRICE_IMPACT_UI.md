# 14 — Price Impact UI & Warning Thresholds

## 1. Price Impact Tiers

```
┌─────────────────────┬───────────────────┬────────────────────────────────────────────────┐
│ Price Impact        │ Badge Style       │ UI Behavior                                    │
├─────────────────────┼───────────────────┼────────────────────────────────────────────────┤
│ < 1.0%              │ Green             │ Normal execution                               │
│ 1.0% - 3.0%         │ Yellow / Amber    │ Noticeable price impact indicator              │
│ > 3.0%              │ Red               │ High price impact alert & confirmation notice  │
│ > 15.0%             │ Dark Red (Error)  │ Dangerous trade warning; requires explicit ack │
└─────────────────────┴───────────────────┴────────────────────────────────────────────────┘
```
