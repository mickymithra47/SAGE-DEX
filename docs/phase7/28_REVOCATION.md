# 28 — Revocation Mechanisms: Allowances vs Nonce Invalidation

## 1. Multi-Tier Revocation Summary

```
┌─────────────────────┬─────────────────────────────────┬─────────────────────────────────┐
│ Layer               │ Revocation Mechanism            │ Action / Method                 │
├─────────────────────┼─────────────────────────────────┼─────────────────────────────────┤
│ ERC-20 Allowance    │ Reset allowance to 0            │ token.approve(spender, 0)       │
│ Permit2 Allowance   │ Reset amount to 0 or expire     │ permit(owner, 0 amount, ...)    │
│ Permit2 Signature   │ Flip bitmap mask to invalidate  │ invalidateUnorderedNonces(...)  │
└─────────────────────┴─────────────────────────────────┴─────────────────────────────────┘
```
