# 07 — Price Impact Modeling & Analytical Formula

## 1. Defining Price Impact
**Price Impact** is the structural degradation in execution price caused by moving the pool's reserve state along the constant-product curve:

$$\text{Price Impact} = \frac{P_{\text{spot}} - P_{\text{execution}}}{P_{\text{spot}}}$$

---

## 2. Formulation in Basis Points (BPS)
Given spot price $P_0 = \frac{R_{\text{out}} \times 10^{18}}{R_{\text{in}}}$ and realized execution price $P_{\text{exec}} = \frac{\Delta y \times 10^{18}}{\Delta x}$:

$$\text{Price Impact (BPS)} = \left\lfloor \frac{(P_0 - P_{\text{exec}}) \times 10,000}{P_0} \right\rfloor$$

### Characteristics:
- Small trades ($\Delta x \ll x$): Impact $\approx 30$ BPS (pure trading fee).
- Large trades ($\Delta x = x$): Impact $\approx 5000$ BPS (50.00%).
