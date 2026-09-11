# 06 — Trading Fee Mathematics & Fee Retention

## 1. The 30 Basis Point (0.3%) Fee Model
On every swap, an immutable fee of $\gamma = 0.3\% = \frac{3}{1000}$ is deducted from the input tokens:

$$\text{Gross Input} = \Delta x$$
$$\text{Fee Deducted} = \frac{3 \cdot \Delta x}{1000}$$
$$\text{Net Invariant Input} = \frac{997 \cdot \Delta x}{1000}$$

---

## 2. Invariant Scaling
Rather than performing intermediate fractional divisions:
- Both numerator and denominator of the swap formula are multiplied by $1000$, resulting in exact integer arithmetic with zero precision loss.
