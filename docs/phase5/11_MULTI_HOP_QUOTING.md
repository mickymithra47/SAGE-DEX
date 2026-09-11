# 11 — Multi-Hop Route Quoting & Sequential Route Evaluation

## 1. Deterministic Multi-Hop Evaluation
Given path $[T_0, T_1, T_2, \dots, T_n]$:
Each hop takes the preceding pool's exact output as the subsequent pool's input:

```
Input a0 ──[ Pair 0/1 ]──> a1 ──[ Pair 1/2 ]──> a2 ──[ Pair 2/3 ]──> Final Output a3
```

---

## 2. Implementation: `getAmountsOut` and `getAmountsIn`
- **Forward Traversal (`getAmountsOut`)**:
  $$\text{amounts}[i+1] = \text{getAmountOut}(\text{amounts}[i], \text{reserveIn}_i, \text{reserveOut}_i)$$
- **Reverse Traversal (`getAmountsIn`)**:
  $$\text{amounts}[i-1] = \text{getAmountIn}(\text{amounts}[i], \text{reserveIn}_{i-1}, \text{reserveOut}_{i-1})$$
