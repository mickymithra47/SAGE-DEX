# 20 — Spot Price, Execution Price & Price Impact

## 1. Spot Price vs Execution Price

$$\text{Spot Price (Marginal)} = P_0 = \frac{\text{reserve1}}{\text{reserve0}}$$

$$\text{Execution Price (Effective)} = P_{\text{exec}} = \frac{\Delta y}{\Delta x} = \frac{997 \cdot y}{1000 \cdot x + 997 \cdot \Delta x}$$

---

## 2. Price Impact Calculation
**Price Impact** is the percentage reduction in effective execution price relative to the pre-trade marginal spot price:

$$\text{Price Impact} = 1 - \frac{P_{\text{exec}}}{P_0} = 1 - \frac{997 \cdot x}{1000 \cdot x + 997 \cdot \Delta x} = \frac{3 \cdot x + 997 \cdot \Delta x}{1000 \cdot x + 997 \cdot \Delta x}$$

### Price Impact Characteristics:
- For small trades ($\Delta x \ll x$), Price Impact $\approx 0.3\%$ (pure trading fee).
- For large trades ($\Delta x \approx x$), Price Impact approaches $\approx 50\%$.
- For trades exceeding pool depth, price impact rapidly approaches $100\%$, protecting the pool from total reserve depletion.
