# 08 — Token Decimals, Precision & Fixed-Point Scaling

## 1. What are Decimals?
In the EVM, **all token balances are stored as unsigned integers**. Decimals are metadata describing presentation and scale:

- **1.0 USDC** (6 Decimals) $= 10^6 = 1,000,000$ raw units.
- **1.0 WBTC** (8 Decimals) $= 10^8 = 100,000,000$ raw units.
- **1.0 DAI / ETH** (18 Decimals) $= 10^{18} = 1,000,000,000,000,000,000$ raw units.
- **1.0 GEM** (0 Decimals) $= 1$ raw unit.
- **1.0 YAM** (24 Decimals) $= 10^{24}$ raw units.

---

## 2. Multi-Decimal AMM Mispricing Hazard
If an AMM pairs **USDC (6 decimals)** and **DAI (18 decimals)** without normalizing decimals:
- A user swapping 1 USDC ($10^6$ units) expects 1 DAI ($10^{18}$ units).
- A naive 1:1 swap gives the user $10^6$ raw units of DAI $= 0.000000000001$ DAI!
- The remaining $99.9999999999\%$ of the trade value is lost to precision mismatch.

---

## 3. Decimal Normalization Formula (WAD Alignment)
To conduct safe pricing math across arbitrary decimal pairs, normalize all amounts into 18-decimal WAD:

$$\text{toWad}(\text{amount}, d) = \begin{cases} \text{amount} \times 10^{18 - d} & \text{if } d < 18 \\ \text{amount} & \text{if } d = 18 \\ \lfloor \text{amount} / 10^{d - 18} \rfloor & \text{if } d > 18 \end{cases}$$
