# 23 — Token Decimals & Scale Discrepancies in AMM Pricing

## 1. The Decimal Discrepancy Problem
- Tokens on EVM have different decimal precision:
  - USDC / USDT: $6$ decimals ($1 \text{ USDC} = 10^6$)
  - WBTC: $8$ decimals ($1 \text{ WBTC} = 10^8$)
  - WETH / DAI: $18$ decimals ($1 \text{ WETH} = 10^{18}$)
- Raw reserve ratios without decimal scaling produce misleading magnitudes:
  $$\frac{2000 \times 10^6 \text{ USDC}}{1 \times 10^{18} \text{ WETH}} = 2 \times 10^{-9} \text{ (raw integer)}$$

---

## 2. Standardized Scaling in Pricing Layer
- The pricing layer scales all spot prices into **18-decimal WAD** units:
  $$\text{Price}_{\text{WAD}} = \frac{R_1 \times 10^{18}}{R_0}$$
- This guarantees uniform pricing interfaces across all token decimal pairs.
