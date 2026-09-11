# 15 — Balance-Delta Accounting & Reconciliation (`skim` & `sync`)

## 1. The Balance-Delta Verification Primitive
Instead of trusting user-provided function parameters (`amountIn`), the Pair directly inspects physical balances post-transfer:

```solidity
uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
```

---

## 2. Reconciliation Primitives: `skim()` and `sync()`

```
┌─────────────────┬───────────────────────────────────────────┬───────────────────────────────────────────┐
│ Function        │ Operation                                 │ Use Case                                  │
├─────────────────┼───────────────────────────────────────────┼───────────────────────────────────────────┤
│ skim(to)        │ Sweeps (balance - reserve) to `to`        │ Recovers direct donations / excess tokens │
│ sync()          │ Forces reserves to equal physical balance │ Re-anchors reserves after external rebase │
└─────────────────┴───────────────────────────────────────────┴───────────────────────────────────────────┘
```

- **`skim(address to)`**:
  $$\text{sweep0} = \text{token0}.\text{balanceOf}(\text{this}) - \text{reserve0}$$
  $$\text{sweep1} = \text{token1}.\text{balanceOf}(\text{this}) - \text{reserve1}$$
- **`sync()`**:
  $$\text{reserve0} \leftarrow \text{token0}.\text{balanceOf}(\text{this})$$
  $$\text{reserve1} \leftarrow \text{token1}.\text{balanceOf}(\text{this})$$
