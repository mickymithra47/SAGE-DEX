# 02 — Spot Price vs Execution Price

## 1. Spot Price (Marginal / Instantaneous)
The **Spot Price** is the instantaneous exchange rate for an infinitesimally small trade:

$$P_0 = \frac{\text{reserve1}}{\text{reserve0}} \times 10^{18} \text{ (in WAD)}$$
$$P_1 = \frac{\text{reserve0}}{\text{reserve1}} \times 10^{18} \text{ (in WAD)}$$

---

## 2. Execution Price (Finite Trade Realization)
Because finite trades shift pool reserves along the constant-product hyperbola, the actual **Execution Price** realized by a trade of size $\Delta x$ is:

$$P_{\text{exec}} = \frac{\Delta y}{\Delta x} \times 10^{18} = \frac{997 \cdot y}{1000 \cdot x + 997 \cdot \Delta x} \times 10^{18} < P_0$$

- The gap between Spot Price and Execution Price is the **Price Impact** of the trade.
