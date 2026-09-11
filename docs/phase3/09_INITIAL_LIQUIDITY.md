# 09 — Initial Liquidity Minting & First-Provider Inflation Defense

## 1. Initial LP Share Calculation
When a pool is first initialized with amounts $a_0$ and $a_1$:
$$\text{initialLiquidity} = \sqrt{a_0 \cdot a_1}$$

### Why Geometric Mean ($\sqrt{a_0 \cdot a_1}$)?
The geometric mean ensures that the initial liquidity share quantity is independent of the initial ratio of assets deposited, tying the value of an LP share directly to the pool invariant $k = x \cdot y$.

---

## 2. The First-Liquidity Inflation Attack
In naive AMMs without minimum liquidity locks:
1. An attacker deposits $1$ wei of $a_0$ and $1$ wei of $a_1$, receiving $1$ wei of LP shares.
2. The attacker directly transfers $10,000$ tokens to the pool without minting.
3. The share price becomes $10,001$ tokens per share.
4. The next depositor depositing $5,000$ tokens receives $\lfloor \frac{5000 \times 1}{10001} \rfloor = 0$ shares!
5. The attacker redeems their 1 share and steals the victim's entire $5,000$ token deposit.

---

## 3. The Sage Defense: `MINIMUM_LIQUIDITY = 1000` Lock
To neutralize this attack permanently:
```solidity
liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
_mint(address(0), MINIMUM_LIQUIDITY);
```
- Exactly **1,000 units** of LP shares are permanently locked at `address(0)` on the very first deposit.
- This ensures `totalSupply >= 1000` at all times, making the cost of inflating the share price to exploit rounding economically prohibitive ($> 1000 \times \text{deposit}$).
