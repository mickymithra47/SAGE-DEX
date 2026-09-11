# 25 — Protocol Events, Custom Errors & Indexing Semantics

## 1. Protocol Events Specification

```
┌─────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────┐
│ Event Signature                                             │ Emitted Condition & Off-Chain Utility                 │
├─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────┤
│ PairCreated(address token0, address token1, address pair)   │ Emitted by Factory on pair deployment via CREATE2.    │
│ Mint(address sender, uint256 amount0, uint256 amount1)      │ Emitted by Pair on LP token minting.                  │
│ Burn(address sender, uint256 a0, uint256 a1, address to)    │ Emitted by Pair on LP share burning and asset return. │
│ Swap(address sender, uint256 in0, in1, out0, out1, to)      │ Emitted by Pair on trade execution.                   │
│ Sync(uint112 reserve0, uint112 reserve1)                    │ Emitted by Pair on any reserve update.                │
└─────────────────────────────────────────────────────────────┴───────────────────────────────────────────────────────┘
```

---

## 2. Structured Custom Errors
- `Locked()`: Mutex triggered during reentrant invocation.
- `KInvariantViolation()`: Post-swap invariant $< \text{pre-swap } k$.
- `InsufficientLiquidityMinted()`: Initial deposit $< 1000$ or subsequent share mint $= 0$.
- `InsufficientOutputAmount()`: Requested swap output is zero.
- `InsufficientLiquidity()`: Requested swap output $\ge$ current pool reserves.
- `PairExists()`: Attempted duplicate deployment in Factory.
