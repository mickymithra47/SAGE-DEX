# 25 — Arithmetic Overflow & Bit-Width Bounds in Pricing Layer

## 1. Overflow Auditing in Pricing Formulations

```
┌───────────────────────────────────────┬───────────────────┬────────────────────────────────────────────────────────┐
│ Operation                             │ Intermediate Size │ Overflow Safety Bound                                  │
├───────────────────────────────────────┼───────────────────┼────────────────────────────────────────────────────────┤
│ Spot Price: (reserveOut * 1e18)       │ Max ~5.19e51      │ < 2^256 (~1.15e77); completely safe.                   │
│ Exact-Input: (997 * aIn * rOut)       │ Max ~5.19e54      │ Fits comfortably in standard uint256.                  │
│ Exact-Output: (1000 * rIn * aOut)     │ Max ~5.19e54      │ Fits comfortably in standard uint256.                  │
│ Price Impact: (P_spot - P_exec) * BPS │ Max ~1e23         │ Fits comfortably in standard uint256.                  │
│ Cumulative Accumulator Addition       │ uint256           │ Unchecked addition handles modulo wrapping gracefully. │
└───────────────────────────────────────┴───────────────────┴────────────────────────────────────────────────────────┘
```
