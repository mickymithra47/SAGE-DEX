# 14 — Time-Weighted Average Price (TWAP) Derivation

## 1. TWAP Mathematical Formulation
For continuous or discrete price function $P(t)$ over time interval $[t_1, t_2]$:

$$\text{TWAP}[t_1, t_2] = \frac{1}{t_2 - t_1} \int_{t_1}^{t_2} P(t) \, dt$$

---

## 2. On-Chain Discrete Realization
In discrete EVM execution, price is constant within each block:

$$\text{price0Cumulative}(t_2) - \text{price0Cumulative}(t_1) = \sum_{i=1}^n P_i \cdot \Delta t_i$$

$$\text{TWAP}_0[t_1, t_2] = \frac{\text{price0Cumulative}(t_2) - \text{price0Cumulative}(t_1)}{t_2 - t_1}$$
