# 21 — Arbitrage Equilibrium & Market Efficiency Mechanics

## 1. How Arbitrage Governs AMM Pricing
An AMM pool does not have an active external price feed or oracle; its prices are updated purely by economic actors:

```
External Centralized Exchange Price:   1 ETH = $2,000
Sage AMM Liquidity Pool Price:        1 ETH = $1,800

ARBITRAGE OPPORTUNITY:
1. Arbitrageur buys 1 ETH on Sage AMM for $1,800.
2. Arbitrageur sells 1 ETH on External Exchange for $2,000.
3. Arbitrageur locks in $200 profit.
4. Consequence on AMM: ETH reserve decreases, USDC reserve increases, pushing the AMM spot price to $2,000!
```

---

## 2. Optimal Arbitrage Size Formula
Given external market price $P^* = \frac{y^*}{x^*}$:
The optimal gross input $\Delta x^*$ that brings the AMM spot price to $P^*$ is:

$$\Delta x^* = \frac{\sqrt{997 \cdot 1000 \cdot x \cdot y \cdot P^*} - 1000 \cdot x}{997}$$
- When market price shifts, arbitrageurs instantly trade $\Delta x^*$, capturing profits while keeping the AMM price aligned with global market consensus.
