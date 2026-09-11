# Phase 11 — Arithmetic, Unchecked Blocks & Bitwise Audit

## 1. Unchecked Blocks Inventory & Safety Proofs
1. **UQ112x112 Cumulative Price Accumulators**:
   - `price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;`
   - **Proof**: Cumulative prices are designed to overflow `uint256` modulo $2^{256}$. Off-chain oracles compute difference $\Delta P = P_2 - P_1 \pmod{2^{256}}$, which yields correct elapsed price difference.
2. **UQ112x112 Fixed-Point Encoding**:
   - Reserves are bounded by `uint112` ($< 5.19 \times 10^{33}$). Encoding $R \ll 112$ requires 224 bits, safely within `uint256`.
