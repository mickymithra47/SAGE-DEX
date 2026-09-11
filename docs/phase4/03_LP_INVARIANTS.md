# 03 — LP Share Accounting Invariants

## Master Accounting Invariants

```
┌─────────────┬────────────────────────────────────────────────────────────────────────────────────────┐
│ Invariant # │ Mathematical & Architectural Specification                                             │
├─────────────┼────────────────────────────────────────────────────────────────────────────────────────┤
│ Invariant 1 │ S_total >= 0 at all times; after initial mint, S_total >= 1000.                        │
│ Invariant 2 │ S_user <= S_total for all user addresses.                                              │
│ Invariant 3 │ ∑ S_user + S_locked ≡ S_total (Strict balance conservation).                           │
│ Invariant 4 │ LP shares can ONLY be created via legitimate pair.mint() deposits.                     │
│ Invariant 5 │ LP shares can ONLY be destroyed via legitimate pair.burn() redemptions.                │
│ Invariant 6 │ User claim Claim_i ≤ Reserve_i; redemption can never exceed total pool assets.         │
│ Invariant 7 │ Failed liquidity operations revert atomically with zero state mutation.                │
│ Invariant 8 │ Zero-value liquidity operations (amountIn = 0 or shares = 0) revert cleanly.           │
│ Invariant 9 │ Locked minimum liquidity (1000 shares at address(0)) can NEVER be redeemed or moved.   │
│ Invariant 10│ Repeated round-trip deposit/burn operations cannot extract free value via rounding.    │
└─────────────┴────────────────────────────────────────────────────────────────────────────────────────┘
```
