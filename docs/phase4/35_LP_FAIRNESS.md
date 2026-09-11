# 35 — LP Fairness & Multi-Entry Yield Parity

## 1. Multi-Entry Timing Fairness
- **Scenario**:
  - LP A enters at $T_0$ ($10\%$ of pool).
  - LP B enters at $T_1$ ($20\%$ of pool).
  - Trader trades between $T_1$ and $T_2$.
- **Result**:
  - LP B participates in 100% of trading fees generated after $T_1$ at exactly a 2:1 ratio relative to LP A.
  - LP A retains 100% of fees generated between $T_0$ and $T_1$ without retroactive dilution.

---

## 2. Invariant Guarantee
Minting LP shares based on the spot reserve ratio $(\frac{\text{amount0} \cdot S}{R_0})$ guarantees that new depositors purchase pool equity at current asset valuation, perfectly preserving historical yield for earlier LPs.
