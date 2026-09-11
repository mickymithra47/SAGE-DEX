# 04 — Initial Liquidity Derivation & Geometric Mean Math

## 1. Initial Deposit Mathematical Model
When a pool is first created, there are no existing reserves to define a price ratio. The initial liquidity provider defines the initial spot price $P_0 = \frac{a_1}{a_0}$.

The total initial LP shares created are derived from the **Geometric Mean**:

$$S_{\text{initial}} = \sqrt{a_0 \times a_1}$$

---

## 2. Why the Geometric Mean?
1. **Ratio Invariance**: If initial amounts are scaled by factor $c$ (e.g. depositing $10 \times a_0$ and $10 \times a_1$), the minted shares scale linearly by $c$.
2. **Invariant Alignment**: $S_{\text{initial}}^2 = a_0 \cdot a_1 = k$. The LP share supply is directly tied to the constant-product invariant $k$.
3. **Symmetry**: Treats both tokens symmetrically regardless of which token has higher numerical denomination or price.
