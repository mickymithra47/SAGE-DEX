# 07 — Additional Liquidity: Proportional Minting & Pool Ratios

## 1. Proportional Deposit Requirement
When depositing into an already active pool with reserves $(R_0, R_1)$ and total supply $S_{\text{total}}$:

$$\text{Shares from Token0} = \frac{a_0 \cdot S_{\text{total}}}{R_0}$$
$$\text{Shares from Token1} = \frac{a_1 \cdot S_{\text{total}}}{R_1}$$

$$\text{Shares Minted} = \min\left( \frac{a_0 \cdot S_{\text{total}}}{R_0}, \frac{a_1 \cdot S_{\text{total}}}{R_1} \right)$$

---

## 2. Handling Imbalanced Deposits
- **Exact Ratio ($\frac{a_0}{a_1} = \frac{R_0}{R_1}$)**: Both ratios are equal, maximizing LP shares issued.
- **Imbalanced Deposit ($\frac{a_0}{a_1} \ne \frac{R_0}{R_1}$)**: Shares are minted based on the smaller ratio. The excess amount of the other token is credited directly to pool reserves, permanently benefiting existing LPs.
