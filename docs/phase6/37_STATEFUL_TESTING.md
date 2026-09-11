# 37 — Stateful Invariant Testing: Multi-Actor Execution

## 1. Handler State Machine & Invariant Assertions
- **Actors**: Trader executing alternating multi-hop and single-hop swaps in randomized directions ($A \to B$ and $B \to A$).
- **Runs & Calls**: 64 runs $\times$ 32 depth = **2,048 stateful calls**.
- **Invariants Verified**:
  - `tokenA.balanceOf(address(router)) == 0`
  - `tokenB.balanceOf(address(router)) == 0`
  - `address(router).balance == 0`
  - Zero transaction reverts or residual token accumulation across all runs.
