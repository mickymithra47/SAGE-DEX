# 02 — Constant Product Mathematical Derivations

## 1. The Core Equation: Zero-Fee Derivation
Starting from the fundamental invariant:
$$(x + \Delta x)(y - \Delta y) = x \cdot y$$

Expanding both sides:
$$x \cdot y - x \cdot \Delta y + \Delta x \cdot y - \Delta x \cdot \Delta y = x \cdot y$$

Subtracting $x \cdot y$ from both sides:
$$\Delta x \cdot y = \Delta y \cdot (x + \Delta x)$$

Solving for output tokens $\Delta y$:
$$\Delta y = \frac{y \cdot \Delta x}{x + \Delta x}$$

---

## 2. Introducing Trading Fees (0.3% / 30 bps)
When a trader deposits gross input $\Delta x$:
1. A fee of $\gamma = 0.3\% = \frac{3}{1000}$ is deducted.
2. The **net input** entering the constant-product invariant is:
   $$\Delta x_{\text{net}} = \Delta x \cdot (1 - \gamma) = \frac{997}{1000} \cdot \Delta x$$
3. Substituting $\Delta x_{\text{net}}$ into the zero-fee output equation:
   $$\Delta y = \frac{y \cdot \left(\frac{997}{1000} \Delta x\right)}{x + \left(\frac{997}{1000} \Delta x\right)}$$
4. Multiplying numerator and denominator by $1000$:
   $$\Delta y = \frac{997 \cdot \Delta x \cdot y}{1000 \cdot x + 997 \cdot \Delta x}$$
