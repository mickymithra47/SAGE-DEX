# 50 — Phase 8 to Phase 9 Dependency Report (Indexing & Market Data)

## 1. Phase 8 Accomplishments & Stabilized Surface
- Full-stack React + TypeScript + Viem + Wagmi web application.
- Real-time client quoting, exact BigInt calculations, price impact modeling.
- Exact approvals, unlimited approvals, and gasless Permit2 EIP-712 signing.
- Custom error decoding, transaction tracking, and liquidity interfaces.

---

## 2. Handoff Specifications for Phase 9 (Indexing, Market Data & Protocol Observability)

### 1. Events Required for Indexing Subgraph / Backend
- **SageFactory**: `PairCreated(address indexed token0, address indexed token1, address pair, uint256 allPairsLength)`
- **SagePair**:
  - `Mint(address indexed sender, uint256 amount0, uint256 amount1)`
  - `Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to)`
  - `Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to)`
  - `Sync(uint112 reserve0, uint112 reserve1)`
- **SageRouter**: `SwapExecuted(address indexed sender, address indexed recipient, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut)`

### 2. High-Priority Indexer Query Surfaces
- 24-hour pool trading volume and fees generated.
- Historical reserve snapshots and candlestick OHLCV data.
- User LP position share valuations and fee accrual tracking.
- Top-liquidity pool rankings and search autocomplete.

---

## 3. What Phase 9 Must NOT Modify
- Core AMM invariant math ($x \cdot y = k$).
- Constant-product pair state transitions and fee retention formulas.
- Router execution and Permit2 bitmap authorization logic.
- Client-side pre-flight slippage derivations.
