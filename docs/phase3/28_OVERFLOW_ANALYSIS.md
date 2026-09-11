# 28 — Arithmetic Overflow & Bit-Width Bounds Analysis

## 1. Reserve Packing Bounds (`uint112`)
- **Maximum Value**: $2^{112} - 1 \approx 5.192 \times 10^{33}$ units.
- **Product Bound**:
  $$\text{reserve0} \times \text{reserve1} \le (2^{112} - 1)^2 \approx 2.69 \times 10^{67} < 2^{224} \ll 2^{256}$$
- **Safety Guarantee**: The product of any two valid `uint112` reserves will never exceed $2^{224}$, meaning it can never overflow standard 256-bit EVM arithmetic (`uint256`), even when multiplied by $1000^2 = 10^6$.

---

## 2. Invariant Scaling Bound
The scaled post-swap invariant calculation is:
$$\text{balance0Adjusted} \times \text{balance1Adjusted} = (1000 \cdot \text{balance0} - 3 \cdot \Delta x_{\text{in}}) \times (1000 \cdot \text{balance1} - 3 \cdot \Delta y_{\text{in}})$$
- For any realistic total circulating supply ($< 10^{30}$ wei), the product is $< 10^{66}$, fitting safely within `uint256` ($1.15 \times 10^{77}$) without overflow risk.
