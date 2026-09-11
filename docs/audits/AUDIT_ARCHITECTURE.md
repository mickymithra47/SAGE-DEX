# AUDIT_ARCHITECTURE.md
# SAGE PROTOCOL — ARCHITECTURAL AUDIT & COMPARISON MATRIX
**Scope**: System Architecture & Constraint Conformance across Phases 1–12  

---

## 1. Documented vs Actual Architecture Comparison

| Component | Documented Specification | Actual Repository State | Audit Classification | Explanation of Mismatch / Delta |
| :--- | :--- | :--- | :---: | :--- |
| **EVM Smart Contracts** | Solidity 0.8.26, V2 Constant-Product Pair, Factory, Router, Permit2, TWAP Oracle | `src/phase2-7` implementing `SagePair`, `SageFactory`, `SageRouter`, `SagePermitRouter`, `Permit2`, `SageOracleEngine` | **MATCH** | All core contract primitives exist and compile under Solidity 0.8.26 with Cancun EVM target. |
| **Token & Approvals** | ERC-20, WETH9, EIP-2612 Permit, Permit2 | `src/phase2/` and `src/phase7/` | **MATCH** | Standard tokens, WETH wrapping, Permit, and Permit2 bitmap nonces implemented. |
| **AMM Core Math** | $x \cdot y = k$, 30 bps fee, minimum liquidity lock | `SagePair.sol`, `SageMath.sol`, `Math.sol` | **MATCH** | Constant product math strictly enforced with 1000 wei minimum liquidity lock to `address(0)`. |
| **Position Viewer** | Pure on-chain LP position math & viewer | `SageLPAccountingEngine.sol`, `LPPositionMath.sol` | **PARTIAL** | Core engine exists, but `calculatePositionValue` fails decimal normalization between mismatched assets. |
| **Price & Oracle Engine** | Spot pricing, multi-hop quoter, TWAP cumulative accumulator | `SagePricingLibrary.sol`, `SageOracleEngine.sol` | **MATCH** | TWAP sliding window with binary-search historical observation lookup implemented. |
| **Swap Execution Router** | Multi-hop exact-in/out, ETH wrap/unwrap, Permit2 integration | `SageRouter.sol`, `SagePermitRouter.sol` | **MATCH** | Correct stateless execution routing and atomic Permit2 swap routing. |
| **Frontend Web App** | React 18, Vite, Viem/Wagmi, Live Swap/Liquidity UX | `frontend/src/` | **PARTIAL** | UI layout and math libraries exist, but user transaction execution in `App.tsx` is simulated with `setTimeout` mocks instead of real contract calls. |
| **AI Assistant (Phase 9)** | Conversational Natural-Language Non-Custodial Assistant | Missing in `frontend/src` and backend | **MISSING** | Phase 9 documentation and tests were overwritten with Indexer content; no AI component was developed. |
| **Relational Indexer** | Event ingester, PostgreSQL database, reorg handler | `indexer/src/` | **PARTIAL** | Decoders and ingest logic exist, but runtime operates on an in-memory Map structure rather than a live PostgreSQL connection. |
| **Query API & Resolvers** | REST / GraphQL resolvers, 24h stats, freshness | `indexer/src/api/resolvers.ts` | **PARTIAL** | Resolvers work against in-memory DB, but `getPoolStats` performs unindexed O(N) array scans and lacks GraphQL serialization. |
| **Testnet Deployment** | Deployed & verified contracts on Sepolia | `deployments/testnet.json` | **MISMATCH** | JSON records deterministic local Anvil/Hardhat deployment addresses (`0x5FbDB...`) rather than real Sepolia contracts. |
| **Formal Verification** | Formal mathematical proofs of invariant safety | `PHASE11_FORMAL_VERIFICATION.md` | **MISMATCH** | Document claims formal verification, but only Foundry fuzzing and invariant suites were executed. |

---

## 2. Project Architectural Constraints Verification

The project defined strict architectural constraints forbidding specific features. The codebase was audited against each constraint:

| Prohibited Architectural Pattern | Present in Codebase? | Verified Status |
| :--- | :---: | :---: |
| **DAO / Governance Tokens** | No | **COMPLIANT** |
| **Complex Multi-Sig / TimeLock Governance** | No | **COMPLIANT** |
| **Mobile Application (React Native / Flutter)** | No | **COMPLIANT** |
| **Go Microservices** | No (TypeScript/Node only) | **COMPLIANT** |
| **Dutch Auctions** | No | **COMPLIANT** |
| **UniswapX Intent Auctions** | No | **COMPLIANT** |
| **Cross-DEX Aggregation** | No | **COMPLIANT** |
| **Cross-Chain Bridging / Aggregation** | No | **COMPLIANT** |
| **V3 Concentrated Liquidity (Tick Math)** | No | **COMPLIANT** |
| **V4 Dynamic Hooks / Singleton PoolManager** | No | **COMPLIANT** |
| **Order-Book Trading** | No | **COMPLIANT** |
| **Autonomous AI Custodial Trading** | No | **COMPLIANT** |

**Constraint Conformance Verdict**: **100% COMPLIANT**. The protocol has preserved strict adherence to its foundational V2 AMM + Permit2 scope without architectural drift into forbidden areas.

---

## 3. Structural & Architectural Anomalies

1. **Phase 9 / Phase 10 Numbering Collision**:
   - The master curriculum defines Phase 9 as "AI Chatbot & Natural-Language Assistant" and Phase 10 as "Indexing, Market Data & Observability".
   - In the repository, `docs/phase9/` contains 71 documentation files detailing the *Indexer and Database*, and `indexer/test/mini_projects/Phase9MiniProjects.test.ts` tests the indexer. Phase 10 duplicated these indexer tests (`Phase10MiniProjects.test.ts`). The AI Chatbot layer was omitted.

2. **Frontend Disconnection from Smart Contracts**:
   - `frontend/src/App.tsx` contains complete UI cards for Swapping and Liquidity, but `handleSwap`, `handleApprove`, `handleAddLiquidity`, and `handleSignPermit2` do not call `useWriteContract` or Viem wallet client; they use `setTimeout()` mock state transitions.

3. **In-Memory Mock Database vs PostgreSQL Schema**:
   - `indexer/src/db/schema.sql` defines an optimal relational PostgreSQL schema with appropriate composite primary keys and B-Tree indexes.
   - However, `indexer/src/db/database.ts` implements an in-memory `Map` repository without a real PostgreSQL driver connection.
