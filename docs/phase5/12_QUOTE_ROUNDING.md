# 12 — Multi-Hop Error Propagation & Precision Truncation

## 1. Compounding Floor Divisions
In a multi-hop swap of length $k$:
- Each hop applies standard floor truncation ($\lfloor \dots \rfloor$).
- Over $k$ hops, the cumulative rounding error is strictly bounded by $< k$ wei.

---

## 2. Practical Route Depth
- For typical DeFi paths ($k \le 4$ hops), precision loss is negligible ($< 10^{-16}$ of the trade value).
- Because fees compound multiplicatively ($(0.997)^k$), paths exceeding 3 or 4 hops become economically inefficient for traders due to fee friction rather than arithmetic rounding.
