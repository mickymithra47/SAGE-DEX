# 32 — Router Event Specifications & Indexing Semantics

## 1. Aggregate Execution Event
`SageRouter` emits a single high-level summary event per swap execution:

```solidity
event SwapExecuted(
    address indexed sender,
    address indexed recipient,
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 amountOut
);
```

---

## 2. Indexer Considerations
- Off-chain indexers (subgraphs/orderbook monitors) track `SwapExecuted` for top-level trade telemetry.
- Detailed reserve state tracking continues to rely on low-level `Swap` and `Sync` events emitted directly by `SagePair`.
