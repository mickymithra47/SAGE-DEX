# 06 — Deadline Protection & Execution Freshness

## 1. The `ensure` Modifier
```solidity
modifier ensure(uint256 deadline) {
    if (block.timestamp > deadline) revert Expired();
    _;
}
```

---

## 2. Security Semantics
- **Freshness, Not Price Protection**: The deadline ensures that a transaction delayed in the mempool is not mined minutes or hours later when market conditions have shifted dramatically.
- Works in tandem with `amountOutMin` / `amountInMax` slippage boundaries.
