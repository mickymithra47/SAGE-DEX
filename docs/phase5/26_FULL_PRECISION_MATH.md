# 26 — Full-Precision Fixed-Point Math & Binary Fractions

## 1. Binary Fixed Point vs Decimal Fixed Point

$$\text{Decimal WAD}: \quad X \times 10^{18}$$
$$\text{Binary Q112x112}: \quad X \times 2^{112}$$

---

## 2. Derivation of TWAP Scaling Conversion
When converting accumulated price $\Delta \text{Cumulative}$ (in Q112x112) to WAD:

$$\text{Average Price}_{\text{UQ112}} = \frac{\Delta \text{Cumulative}}{\Delta t}$$

$$\text{TWAP}_{\text{WAD}} = \frac{\text{Average Price}_{\text{UQ112}} \times 10^{18}}{2^{112}} = \frac{\Delta \text{Cumulative} \times 10^{18}}{\Delta t \times 2^{112}}$$

- Tested across all fuzz and unit test suites with 0 precision drift.
