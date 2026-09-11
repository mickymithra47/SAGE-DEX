# 15 — Cumulative Price Variables & UQ112x112 Encoding

## 1. Storage of Cumulative Price State
`SagePair` maintains two dedicated cumulative price accumulators in storage:
- `uint256 public price0CumulativeLast;`
- `uint256 public price1CumulativeLast;`

---

## 2. Binary Fixed Point: UQ112x112
To accumulate instantaneous spot price without floating point:
- The reserve ratio $\frac{\text{reserve1}}{\text{reserve0}}$ is encoded as a 224-bit integer with 112 fractional bits:
  $$\text{Price}_{\text{UQ112}} = \frac{\text{reserve1} \times 2^{112}}{\text{reserve0}}$$
- Cumulative update formula:
  $$\text{price0CumulativeLast} \mathrel{+}= \text{Price}_{\text{UQ112}} \times \Delta t$$
- **Overflow Resilience**: `uint256` accumulates price seconds. At normal price scales, overflow will not occur for hundreds of years. Unchecked modular subtraction handles modulo wrapping gracefully.
