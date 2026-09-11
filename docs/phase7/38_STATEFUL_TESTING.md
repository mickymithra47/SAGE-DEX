# 38 — Stateful Invariant Testing: Multi-Actor Authorization State Machine

## 1. Invariant Verification Results
- **Runs & Depth**: 64 runs $\times$ 32 calls = **2,048 stateful multi-actor transactions**.
- **Invariants Verified**:
  - `token.balanceOf(alice) + token.balanceOf(spender) == INITIAL_SUPPLY`
  - Bit positions in `nonceBitmap` flip from $0 \to 1$ monotonically.
  - Zero unauthorized balance withdrawals across all runs.
  - Zero transaction reverts.
