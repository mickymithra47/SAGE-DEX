# 44 — Phase 4 to Phase 5 Dependency Report & Pricing Engine Handoff

## 1. Current AMM Subsystems Finalized in Phase 4
- **Reserve Model**: Single-slot packed reserves (`reserve0`, `reserve1`, `blockTimestampLast`).
- **Fee Model**: Immutable 30 bps (0.3%) fee retained inside reserves.
- **LP Accounting**: Fungible ERC-20 LP tokens with $1000$ dead shares locked to `address(0)`.
- **Swap Math**: Pure integer arithmetic with directional rounding (`SageMath.getAmountOut` and `getAmountIn`).
- **LP Accounting Viewer**: `SageLPAccountingEngine` with optimal deposit quotes and position inspection.

---

## 2. What Phase 5 (Pricing Engine & Quoting Layer) Will Build
1. **Multi-Hop Quoting Primitives**: Calculating exact-input and exact-output routes across arbitrary pool paths $(A \to B \to C)$.
2. **Price Impact Computations**: Analytical and simulated price impact calculations for trade sizing.
3. **Execution Price vs Marginal Price Analyzers**: Distinguishing spot price from realized execution price across trade sizes.
4. **Off-Chain & On-Chain Quoting Interfaces**: Standalone view-only quoting contracts that allow frontends and future routers to query route outputs without state changes or approvals.

---

## 3. Contracts that Must Remain Immutable
- `SageFactory.sol`: Factory registry and CREATE2 deployment logic are locked.
- `SagePair.sol`: Core constant-product pair, mutex, and invariant enforcement are locked.
- `SageERC20.sol`: LP share token contracts are locked.
- `LPPositionMath.sol`: LP position mathematics library is locked.
