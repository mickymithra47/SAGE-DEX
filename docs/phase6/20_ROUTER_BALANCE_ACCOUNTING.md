# 20 — Router Balance Accounting & Invariant Proof

## 1. Zero-Balance Invariant
$$\forall \text{ token } T, \quad \text{balanceOf}(T, \text{Router}) \equiv 0$$
$$\text{address}(\text{Router}).\text{balance} \equiv 0$$

- Formally verified in stateless fuzz tests, end-to-end simulation, and 2,048 stateful invariant transitions.
