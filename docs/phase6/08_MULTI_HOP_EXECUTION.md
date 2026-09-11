# 08 — Multi-Hop Pipeline & Direct Pool-to-Pool Chaining

## 1. Zero-Intermediate-Hop Transfer Optimization
In a route $A \to B \to C$:

```
Pair(A, B) ──[ transfers B directly to ]──> Pair(B, C) ──[ transfers C to ]──> User
```

- Instead of routing intermediate token $B$ back to `SageRouter` and performing an extra ERC-20 transfer into `Pair(B, C)`, the router sets `to` in `Pair(A, B).swap()` directly to `address(Pair(B, C))`.
- This saves ~25,000 gas per intermediate hop.
