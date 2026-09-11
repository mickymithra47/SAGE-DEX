# 34 — Economic Conservation & Solvency Proofs

## 1. Master Economic Conservation Equation

$$\sum \text{Assets Deposited} + \sum \text{Fees Paid by Traders} \equiv \sum \text{Assets Redeemed by LPs} + \text{Pool Reserves Remaining}$$

---

## 2. Solvency Bounds
For any pool active at block $t$:

$$\text{token0.balanceOf}(\text{pair}) \ge \text{reserve0}$$
$$\text{token1.balanceOf}(\text{pair}) \ge \text{reserve1}$$

- No sequence of mints, burns, or transfers can cause the physical token balance to fall below stored reserves.
