# 17 — Atomicity & Transaction Failure Rollback

## 1. All-or-Nothing Guarantee
In any multi-hop swap $A \to B \to C \to D$:
- If an error occurs at any point (e.g. slippage breach at hop 3, recipient rejecting ETH, transfer failure, expired deadline):
  - **The entire EVM transaction reverts atomically.**
  - All token approvals, balance transfers, and intermediate pool reserves roll back to their pre-transaction states.
  - Zero partial executions or orphaned intermediate tokens can exist.
