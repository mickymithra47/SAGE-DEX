# 21 — Low-Liquidity Oracle Risks & Limits of TWAP

## 1. Capital Cost of TWAP Manipulation
The cost to manipulate a TWAP price by percentage $\delta$ over duration $T$ is proportional to the pool's liquidity:

$$\text{Manipulation Cost} \propto \delta^2 \cdot \sqrt{k} \cdot T$$

---

## 2. Low-Liquidity Risk
- In a pool with only $\$10,000$ in reserves, an attacker can hold the price at $2\times$ for 10 minutes at minimal cost ($< \$500$ in fees/arbitrage risk).
- In a pool with $\$100,000,000$ in reserves, holding a $2\times$ price distortion for 10 minutes would cost millions in arbitrage loss.
- **Rule**: Never consume TWAP from pools below verified minimum liquidity thresholds.
