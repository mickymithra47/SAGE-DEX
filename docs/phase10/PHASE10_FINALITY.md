# Phase 10 — Finality Policies & Data Freshness

## 1. Finality Tiers
- **Observed**: 0-1 block depth (provisional; subject to reorg).
- **Confirmed**: 2-63 block depth.
- **Finalized**: >= 64 blocks (PoS finalized).
- Lag gauge: $\text{Lag} = \text{chainTip} - \text{latestIndexedBlock}$.
