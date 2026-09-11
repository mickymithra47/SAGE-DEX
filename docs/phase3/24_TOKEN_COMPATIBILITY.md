# 24 — Phase 3 AMM Token Compatibility Boundaries

## 1. Asset Support Matrix in AMM Core

```
┌───────────────────────────────────────┬────────────┬────────────────────────────────────────────────────────┐
│ Token Category                        │ Status     │ AMM Behavior & Defense Mechanism                       │
├───────────────────────────────────────┼────────────┼────────────────────────────────────────────────────────┤
│ 1. Canonical Standard ERC-20          │ SUPPORTED  │ Fully operational across mint, burn, and swap.         │
│ 2. Missing Return Data (USDT)         │ SUPPORTED  │ Supported via SafeTokenTransfer assembly wrapper.       │
│ 3. False-Returning Tokens             │ SUPPORTED  │ SafeTokenTransfer treats false return as revert.       │
│ 4. Fee-on-Transfer Tokens             │ CAUTION    │ Supported ONLY on Exact-Input; uses balance deltas.    │
│ 5. Rebasing Tokens                    │ UNSUPPORTED│ Raw rebasing tokens prohibited; require share wrapper. │
│ 6. Blacklist / Pausable Tokens        │ CAUTION    │ Isolated pool risk; transfers will revert if frozen.   │
│ 7. Reentrant Callback Tokens          │ SUPPORTED  │ Fully mitigated by low-level mutex lock.               │
│ 8. Always-Reverting Tokens            │ UNSUPPORTED│ Reverts atomically during transfer; no state changes.  │
└───────────────────────────────────────┴────────────┴────────────────────────────────────────────────────────┘
```
