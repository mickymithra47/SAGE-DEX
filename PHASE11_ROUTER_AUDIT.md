# Phase 11 — Router Security & Execution Safety Audit

## 1. Router Invariants
1. **Zero Residual Balances**: `SageRouter` does NOT retain user tokens or ETH post-swap. Multi-hop swaps transfer directly from pool to pool (`pair_i -> pair_{i+1}`).
2. **Slippage Enforcement**: `amountOut >= amountOutMin` for exact-input; `amountIn <= amountInMax` for exact-output.
3. **Deadline Protection**: `block.timestamp <= deadline` enforced at top-level entry.
