# 16 — Slippage Tolerance UI & Boundary Calculation

## 1. Slippage Derivation
- Presets: `0.1%` (10 bps), `0.5%` (50 bps, default), `1.0%` (100 bps), Custom.
- Derived bound sent to smart contract:
  $$\text{amountOutMin} = \left\lfloor \frac{\text{amountOut} \cdot (10000 - \text{slippageBps})}{10000} \right\rfloor$$
- Protects user against adverse price movements in the mempool.
