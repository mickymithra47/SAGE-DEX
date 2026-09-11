# 29 — Atomic Execution Ordering & Reversion Guarantees

## 1. Safe Execution Order (Checks-Effects-Interactions)

```
[1. VALIDATION] ──> [2. STATE UPDATE] ──> [3. EXTERNAL TRANSFERS] ──> [4. RE-READ & EMIT]
```

### In `burn(address to)`:
1. **Checks**: Verify `liquidity > 0` and `totalSupply > 0`.
2. **Effects**: Burn LP shares immediately from pair balance (`_burn(address(this), liquidity)`).
3. **Interactions**: Transfer `amount0` and `amount1` to recipient `to`.
4. **Reconcile**: Re-read physical balances and update Slot 3 stored reserves.

---

## 2. All-or-Nothing Guarantee
If any token transfer fails or if the recipient reverts during execution, the entire transaction reverts, leaving LP share balances and pool reserves completely unchanged.
