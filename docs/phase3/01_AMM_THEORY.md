# 01 — AMM Theory & First-Principles Foundations

## 1. What is an Automated Market Maker (AMM)?
An **Automated Market Maker (AMM)** is an autonomous, decentralized exchange protocol that replaces traditional central limit order books (CLOBs) with algorithmic liquidity pools. In an AMM, traders trade directly against a pooled smart contract reserve rather than matching orders with discrete counterparty buyers or sellers.

---

## 2. Core Financial Concepts & Definitions

```
┌───────────────────────────────┬─────────────────────────────────────────────────────────────────────────┐
│ Term                          │ Definition                                                              │
├───────────────────────────────┼─────────────────────────────────────────────────────────────────────────┤
│ Liquidity Pool                │ A smart contract holding locked reserves of two or more tokens.         │
│ Reserve (x, y)                │ The internal token inventory held by the pool contract.                 │
│ Invariant (k)                 │ The mathematical constraint that must be preserved across swaps.        │
│ Spot / Marginal Price         │ The price of an infinitesimally small trade: P = y / x.                 │
│ Execution Price               │ The actual effective price realized by a finite trade: Δy / Δx.         │
│ Price Impact / Slippage       │ The degradation in execution price caused by shifting the pool reserve. │
│ Trading Fee (30 bps)          │ 0.3% fee deducted from input tokens, retained as reserve growth for LPs.│
│ Liquidity Provider (LP)       │ An economic actor depositing dual assets to earn swap fee yield.        │
│ LP Share                      │ Proportional fungible equity claim on the pool's assets.                │
└───────────────────────────────┴─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. First-Principles Derivation of $x \cdot y = k$
Consider a pool containing inventory $x$ of Token0 and $y$ of Token1:
1. When a trader introduces $\Delta x$ units of Token0, the pool's Token0 inventory increases to $x + \Delta x$.
2. To release $\Delta y$ units of Token1, the state transition must satisfy:
   $$(x + \Delta x)(y - \Delta y) = x \cdot y = k$$
3. This hyperbola guarantees asymptotic liquidity: as $x \to \infty$, $y \to 0$, meaning the pool can never be completely depleted of Token1 by finite inputs of Token0.
