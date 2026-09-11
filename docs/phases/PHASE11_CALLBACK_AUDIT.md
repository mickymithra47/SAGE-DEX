# Phase 11 — Callback Security & Flash Swap Audit

## 1. Flash Swap Callback Protocol
- `SagePair.swap(amount0Out, amount1Out, to, data)`:
  - If `data.length > 0`, invokes `ISageCallee(to).sageCall(msg.sender, amount0Out, amount1Out, data)`.
  - Pair reserves are re-evaluated AFTER callback completion.
  - If the callback fails to return borrowed assets plus the 0.30% fee, the invariant check fails and the entire transaction reverts.
