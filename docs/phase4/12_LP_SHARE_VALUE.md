# 12 — LP Share Valuation Model

## 1. Defining LP Share Value
An LP share's economic value is defined off-chain by valuing its underlying proportional asset claims against external spot prices:

$$\text{LP Share Value} = \frac{\text{reserve0} \cdot P_0 + \text{reserve1} \cdot P_1}{\text{totalSupply}}$$

---

## 2. Dynamic Price Sensitivity
- If external market prices change, traders arbitrage the pool, shifting reserve ratios until $\frac{\text{reserve1}}{\text{reserve0}} \approx \frac{P_0}{P_1}$.
- At arbitrage equilibrium ($k = x \cdot y$), the total dollar value of the pool is:
  $$\text{Total Pool Value} = 2 \cdot \sqrt{k \cdot P_0 \cdot P_1}$$
  $$\text{Value per LP Share} = 2 \cdot \frac{\sqrt{k \cdot P_0 \cdot P_1}}{\text{totalSupply}}$$
