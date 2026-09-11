# 09 — Liquidity Removal & Proportional Asset Redemption

## 1. Liquidity Burning Mathematical Formulation
When burning $L_{\text{burn}}$ LP shares:

$$\text{amount0} = \left\lfloor \frac{L_{\text{burn}} \times \text{balance0}}{S_{\text{total}}} \right\rfloor$$
$$\text{amount1} = \left\lfloor \frac{L_{\text{burn}} \times \text{balance1}}{S_{\text{total}}} \right\rfloor$$

---

## 2. Low-Level Execution Pipeline
```
USER / CALLER
 │
 ├── 1. Transfers L_burn LP shares to Pair contract (pair.transfer(pair, L_burn))
 │
 └── 2. Calls pair.burn(to)
      │
      ├── Reads liquidity = pair.balanceOf(pair)
      ├── Computes amount0 and amount1 via proportional formula
      ├── Burns liquidity LP shares from pair's balance
      ├── Transfers amount0 to `to` via SafeTokenTransfer
      ├── Transfers amount1 to `to` via SafeTokenTransfer
      ├── Re-reads balances and updates stored reserves
      └── Emits Burn(msg.sender, amount0, amount1, to)
```
