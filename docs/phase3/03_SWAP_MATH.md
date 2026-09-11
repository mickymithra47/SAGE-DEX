# 03 — Swap Math: Exact-Input vs Exact-Output Formulations

## 1. Exact-Input Swap Math
In an **Exact-Input swap**, the trader specifies the exact amount of tokens to spend ($\Delta x$) and computes the resulting output ($\Delta y$).

$$\Delta y = \left\lfloor \frac{997 \cdot \Delta x \cdot y}{1000 \cdot x + 997 \cdot \Delta x} \right\rfloor$$

- **Rounding Decision**: Round DOWN ($\lfloor \dots \rfloor$). Truncation favors the pool reserves and preserves the $k$-invariant.

---

## 2. Exact-Output Swap Math
In an **Exact-Output swap**, the trader specifies the exact amount of output tokens desired ($\Delta y$) and computes the necessary input ($\Delta x$).

From the invariant:
$$\left(x + \frac{997}{1000} \Delta x\right)(y - \Delta y) = x \cdot y$$

Solving for gross input $\Delta x$:
$$\Delta x = \left\lceil \frac{1000 \cdot x \cdot \Delta y}{997 \cdot (y - \Delta y)} \right\rceil = \left\lfloor \frac{1000 \cdot x \cdot \Delta y}{997 \cdot (y - \Delta y)} \right\rfloor + 1$$

- **Rounding Decision**: Round UP ($\lceil \dots \rceil$). Adding $1$ wei ensures that integer division never produces an input that yields less than the required invariant.
