# 11 — Quote Integration & Real-Time Price Computation

## 1. On-Chain Exact Quoting
- Consumes constant-product formulas:
  $$\Delta y = \frac{R_1 \cdot \Delta x \cdot 997}{R_0 \cdot 1000 + \Delta x \cdot 997}$$
- Exact output quote:
  $$\Delta x = \frac{R_0 \cdot \Delta y \cdot 1000}{(R_1 - \Delta y) \cdot 997} + 1$$
- Displays estimated output, minimum received after slippage, price rate, and fee breakdown in real time.
