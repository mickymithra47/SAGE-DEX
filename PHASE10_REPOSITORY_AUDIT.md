# Phase 10 — Repository Audit & Architecture Assessment

## 1. Executive Summary & Repository Survey

This audit inspects the entire codebase across all prior phases (Phases 1 through 9) to establish the ground truth for **Phase 10 — Indexing, Market Data & Observability**.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│ PHASE REPOSITORY MAP                                                                            │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ • Smart Contracts (src/):                                                                       │
│   ├── src/01_evm_calls/       Low-level CALL, CREATE, CREATE2 demos                             │
│   ├── src/02_token/           ERC20Token, WETH9, SafeTokenTransfer Yul library, Permit, Mocks   │
│   ├── src/03_amm_core/        SageFactory, SagePair, SageERC20, SageMath                    │
│   ├── src/04_liquidity/       LPPositionMath, SageLPAccountingEngine                           │
│   ├── src/05_pricing_oracle/  SagePricingLibrary, SageQuoter, SageOracleEngine (TWAP)        │
│   ├── src/06_swap_router/     SageRouter (Stateless swap execution)                            │
│   └── src/07_authorization/   Permit2, SagePermitRouter                                        │
│ • Frontend (frontend/):       React 18 + TS + Viem + Wagmi web app                              │
│ • Indexer Infrastructure (indexer/): TypeScript + Node.js + PostgreSQL schema                   │
│ • Tests (test/):              186 Foundry smart contract tests (100% Green)                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. On-Chain Contracts & Canonical Events

### A. Factory Contract (`src/03_amm_core/SageFactory.sol`)
- **Emitted Event**:
  ```solidity
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256 allPairsLength);
  ```
- **Topic**: `0x0d3648bd0f6ba80134a33ba9275ac585d9d315f0ad8355cddefde31afa28d0e9`
- **Behavior**: Enforces numerical canonical ordering (`token0 < token1`), deploys pairs via `CREATE2`, and stores pairs bidirectionally in `getPair[token0][token1]`.

### B. Pair Contract (`src/03_amm_core/SagePair.sol`)
- **Emitted Events**:
  1. `Swap(address indexed sender, address indexed recipient, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out)`
     - Topic: `0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822`
  2. `Mint(address indexed sender, uint256 amount0, uint256 amount1)`
     - Topic: `0x4c209b37986879e7c75c607cd3820285587c08d79acd61535b03725c55920b3f`
  3. `Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to)`
     - Topic: `0xdccd412f0b1252819cb1fd330b93224ca42612892bb3f4f789976e6d81936496`
  4. `Sync(uint112 reserve0, uint112 reserve1)`
     - Topic: `0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1`
- **LP Token Semantics**: `SagePair` is an `ERC20` token emitting `Transfer(address indexed from, address indexed to, uint256 value)`.

### C. Router Contract (`src/06_swap_router/SageRouter.sol` & `src/07_authorization/SagePermitRouter.sol`)
- Stateless execution coordinator ensuring zero residual token balances.

---

## 3. Data Consumers & Requirements

1. **Phase 8 Frontend Interface**:
   - Requires discoverable pool lists, token metadata, recent swaps, user trade history, and LP position valuations.
2. **Phase 9 AI Assistant**:
   - Consumes read APIs for market volume, pool reserves, exchange rates, and user transaction summaries.
3. **Smart Contract Invariant Guard**:
   - The indexer is strictly non-authoritative. The hierarchy is `BLOCKCHAIN > INDEXER > DATABASE > CACHE > FRONTEND/AI`.

---

## 4. Phase 10 Recommended Engineering Architecture

- **Language & Runtime**: TypeScript (Node.js ES Modules).
- **Storage Layer**: PostgreSQL 15+ relational schema with versioned SQL migrations and in-memory test repository.
- **Reorg Engine**: Verifies `parentHash` continuity and unwinds orphaned blocks atomically to the common ancestor.
- **Price Engine**: Normalizes prices across asymmetric decimals ($10^6 \leftrightarrow 10^{18}$, $10^8 \leftrightarrow 10^{18}$).
- **API & Observability**: REST/GraphQL resolvers with cursor pagination, Prometheus metrics, structured logging, and automated on-chain reconciliation.
