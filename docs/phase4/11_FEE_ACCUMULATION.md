# 11 — Fee Accumulation Mechanics & Reserve Compounding

## 1. Asset Backing Appreciates Without Share Inflation
In the Sage AMM:
1. When traders trade, LP token share quantities held by users do NOT change.
2. Instead, the **underlying reserve quantities** backing each share increase:

$$\text{Asset Backing per Share}_0 = \frac{\text{reserve0}}{\text{totalSupply}}$$
$$\text{Asset Backing per Share}_1 = \frac{\text{reserve1}}{\text{totalSupply}}$$

---

## 2. Worked Numerical Example
- **Initial Deposit**: Alice deposits $100$ Token0 and $100$ Token1. Minted shares: $100$ LP shares.
- **Trader Swap**: Trader swaps $10$ Token0 for Token1.
  - Net Token0 deposited: $+10$ Token0.
  - Token1 received: $-9.066$ Token1.
  - Fee retained: $+0.03$ Token0.
- **New Reserves**: $110$ Token0, $90.934$ Token1.
- **Alice's LP Claim**: Alice still owns $100$ shares (100% of supply).
  - Can redeem $110$ Token0 and $90.934$ Token1.
  - Invariant $k = 110 \times 90.934 = 10,002.74 > 10,000$.
