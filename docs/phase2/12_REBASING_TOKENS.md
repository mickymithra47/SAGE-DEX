# 12 — Rebasing Tokens & Elastic Supply Dynamics

## 1. What are Rebasing Tokens?
Rebasing tokens (e.g. `stETH`, `AMPL`, `OHM`) dynamically alter user balances by adjusting an internal multiplier or global supply factor without executing individual transfer transactions:

$$\text{balanceOf}(U) = \text{shares}[U] \times \text{rebaseMultiplier}$$

---

## 2. Impact on Constant-Product AMMs ($x \cdot y = k$)
1. **Positive Rebase**: When the token rebases upward, the pool's physical token balance increases automatically.
   - If the AMM does not sync internal reserves, arbitrage bots can swap against the stale reserve price, extracting 100% of the newly minted rebase tokens.
2. **Negative Rebase**: When the token rebases downward, the pool's physical token balance decreases.
   - Internal reserves now claim more tokens than physically exist in the pool, causing subsequent liquidity withdrawals or swaps to revert due to insufficient balance!

---

## 3. SAGE Protocol Architectural Decision

> [!IMPORTANT]
> **PROTOCOL DECISION: DIRECT REBASING TOKENS ARE NOT SUPPORTED IN RAW POOLS.**
>
> To trade rebasing assets in SAGE DEX:
> 1. The rebasing token must first be wrapped in a **Non-Rebasing Share Wrapper** (e.g. wrap `stETH` into `wstETH`).
> 2. The wrapper holds the underlying rebasing shares while presenting a strictly static balance to the AMM pool.
> 3. Value accrues via price appreciation rather than balance mutation.
