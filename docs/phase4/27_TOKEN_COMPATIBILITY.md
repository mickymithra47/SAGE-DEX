# 27 — Token Compatibility & Asset Integration Boundaries

## 1. Asset Support Classification

```
┌───────────────────────────────────────┬──────────────┬──────────────────────────────────────────────────────┐
│ Token Category                        │ Support Tier │ Operational Behavior & Defenses                      │
├───────────────────────────────────────┼──────────────┼──────────────────────────────────────────────────────┤
│ Standard Canonical ERC-20             │ FULL         │ Fully supported across mint, burn, and transfer.     │
│ Non-Standard Return (USDT)            │ FULL         │ Supported via SafeTokenTransfer assembly wrapper.     │
│ False-Returning Tokens                │ FULL         │ Treated as revert by SafeTokenTransfer.              │
│ Fee-on-Transfer (FoT) Tokens          │ CONDITIONAL  │ Supported on mint/burn via physical balance deltas.  │
│ Rebasing / Elastic Tokens             │ UNSUPPORTED  │ Requires static-share wrapper (e.g. wstETH).         │
│ Blacklist / Pausable Tokens           │ CONDITIONAL  │ Isolated pool risk; transfers revert if frozen.      │
│ Reentrant Callback Tokens             │ FULL         │ Protected by low-level non-reentrant mutex.          │
└───────────────────────────────────────┴──────────────┴──────────────────────────────────────────────────────┘
```
