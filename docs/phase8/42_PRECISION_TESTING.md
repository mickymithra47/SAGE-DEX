# 42 — Multi-Decimal Precision & Zero-Truncation Proof

## 1. Verified Decimals & Test Matrix
- **6 Decimals (USDC)**: $0.000001 \to 1\text{ wei}$, $1.5 \to 1,500,000\text{ wei}$.
- **8 Decimals (WBTC)**: $0.00000001 \to 1\text{ wei}$.
- **18 Decimals (WETH/DAI)**: $1.0 \to 10^{18}\text{ wei}$.
- Complete immunity to floating-point truncation.
