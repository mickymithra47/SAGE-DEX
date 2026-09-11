# 08 — Nonce Management: Sequential vs Unordered Bitmaps

## 1. Nonce Architectures

```
┌─────────────────────┬─────────────────────────────────┬─────────────────────────────────┐
│ Feature             │ Sequential Nonce (EIP-2612)     │ Unordered Nonce Bitmap (Permit2)│
├─────────────────────┼─────────────────────────────────┼─────────────────────────────────┤
│ Ordering            │ Strictly ordered (0, 1, 2, ...) │ Unordered (any nonce in word)   │
│ Concurrency         │ Single inflight signature       │ High concurrency (256/word)     │
│ Storage Cost        │ 1 SSTORE per use                │ 1 SSTORE per word (bit flip)    │
│ Batch Invalidation  │ Invalidate all subsequent       │ Invalidate specific bitmask     │
└─────────────────────┴─────────────────────────────────┴─────────────────────────────────┘
```
