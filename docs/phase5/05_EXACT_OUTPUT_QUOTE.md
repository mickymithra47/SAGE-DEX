# 05 — Exact-Output Quoting & Ceiling Rounding

## 1. Exact-Output Swap Formulation
Given desired output $\Delta y$, reserve $x$, and reserve $y$:

$$\Delta x = \left\lceil \frac{1000 \cdot x \cdot \Delta y}{997 \cdot (y - \Delta y)} \right\rceil = \left\lfloor \frac{1000 \cdot x \cdot \Delta y}{997 \cdot (y - \Delta y)} \right\rfloor + 1$$

---

## 2. Rounding Decision Rationale
- Adding $+1$ wei ensures that integer division truncation never produces an input that yields less than the required invariant threshold.
- The trader is guaranteed that submitting the calculated input will fulfill the desired output amount in full without reverting.
