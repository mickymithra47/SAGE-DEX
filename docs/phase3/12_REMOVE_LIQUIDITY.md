# 12 — Removing Liquidity: Proportional Redemption & Asset Return

## 1. Low-Level Liquidity Removal Flow
Liquidity withdrawal is executed by burning LP shares via `burn(address to)`:

```
USER / LP
 │
 ├── 1. Transfers LP shares to the Pair contract (pair.transfer(pair, liquidity))
 │
 └── 2. Invokes pair.burn(to)
      │
      ├── Reads liquidity = pair.balanceOf(pair)
      ├── Computes proportional asset shares:
      │     amount0 = (liquidity * balance0) / totalSupply
      │     amount1 = (liquidity * balance1) / totalSupply
      ├── Burns LP shares from pair's balance
      ├── Transfers amount0 to `to` via SafeTokenTransfer
      ├── Transfers amount1 to `to` via SafeTokenTransfer
      ├── Re-reads physical balances and updates reserves
      └── Emits Burn(msg.sender, amount0, amount1, to)
```

---

## 2. Rounding Invariance
- Both `amount0` and `amount1` are calculated using standard integer truncation ($\lfloor \dots \rfloor$).
- This guarantees that the redeemed asset value can never exceed the LP's exact fractional ownership of the pool.
