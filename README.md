# SAGE DEX Protocol — Protocol-First EVM Decentralized Exchange

Sage is a high-performance, protocol-first decentralized exchange built for EVM blockchains using **Solidity 0.8.26**, **Cancun EVM features**, **Foundry**, **React 18**, **TypeScript**, **Viem**, and **PostgreSQL**.

---

## 🏛 Protocol Architecture Stack

```
                                  SAGE PROTOCOL STACK
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: EVM & SOLIDITY FOUNDATION (Complete & 100% Tested)                            │
│ ├── Low-Level Calls (CALL, STATICCALL, DELEGATECALL, CREATE, CREATE2)                 │
│ ├── Storage Layout & Slot Packing Laboratory                                           │
│ ├── Calldata Slicing & Memory Lifecycle                                                │
│ ├── Yul Assembly & Transient Storage (TLOAD / TSTORE)                                  │
│ └── 9 Security Vulnerability Scenarios & Mitigations                                   │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: TOKEN LAYER & CORE ASSET ACCOUNTING (Complete & 100% Tested)                  │
│ ├── Canonical EIP-20 ERC20Token with Supply Conservation Invariants                   │
│ ├── Canonical WETH9 with Strict 1:1 Solvency Invariant                                │
│ ├── EIP-2612 Permit & EIP-712 Structured Data Hashing with Dynamic Domain Separators   │
│ ├── Hand-Tuned SafeTokenTransfer Yul Library (USDT & Non-Standard Safe Handling)       │
│ ├── TokenAccountingMath (Multi-Decimal Scaling & Directional Rounding)                 │
│ ├── 12 Adversarial Token Mocks (Reentrant, FoT, Rebasing, Blacklist, Pausable, etc.)   │
│ ├── 12 Security Lab Scenarios with Exploit Proofs & Hardened Defenses                  │
│ └── 8 Mini-Projects & On-Chain Compatibility Diagnostic Engine                         │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: AMM V2 CORE — CONSTANT PRODUCT x * y = k (Complete & 100% Tested)             │
│ ├── SageFactory with CREATE2 Deterministic Pair Deployment & Canonical Token Ordering │
│ ├── SagePair (Slot 3 Reserve Packing, Invariant Check, Flash Swaps, TWAP Accumulators)│
│ ├── SageERC20 LP Share Tokens with EIP-2612 Permit                                    │
│ ├── Pure SageMath Layer (quote, getAmountOut, getAmountIn, Integer Sqrt)              │
│ ├── First-Liquidity Inflation Defense (MINIMUM_LIQUIDITY = 1000 Locked to address(0))  │
│ ├── Balance-Delta Accounting with skim() & sync() Reconciliation                       │
│ ├── 10 Phase 3 Mini-Projects & 20 Attack Scenarios                                     │
│ └── Stateful Invariant Test Suite (2,048 calls per run)                                │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: LIQUIDITY & LP POSITION ENGINE (Complete & 100% Tested)                       │
│ ├── Fungible ERC-20 LP Share Architecture & Proportional Accounting                     │
│ ├── LPPositionMath Library (Initial/Additional Liquidity, Redemption, Valuation, IL)   │
│ ├── SageLPAccountingEngine (On-Chain Position Viewer & Add/Remove Liquidity Quoting)  │
│ ├── Multi-LP Fairness Engine (Proportional Fee Distribution Across Alice, Bob, Carol)  │
│ ├── Transferable LP Positions (ERC-20 Secondary Transferability)                       │
│ ├── 12 Phase 4 Mini-Projects & 18 Attack Scenarios                                     │
│ ├── Stateful Invariant & Fuzz Test Suites (Conservation of Shares & Solvency)          │
│ └── End-to-End Multi-LP Simulation Script                                              │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 5: PRICING, QUOTING & ORACLE ENGINE (Complete & 100% Tested)                     │
│ ├── Spot Price in 18-Decimal WAD & Analytical Price Impact Modeling (1-10000 BPS)      │
│ ├── SagePricingLibrary (Exact-Input/Output Math, Multi-Hop Paths, Decimal Normalizer) │
│ ├── SageQuoter (View-Only On-Chain Quoter with Slippage Boundary Calculations)        │
│ ├── SageOracleEngine (TWAP Observation Registry, Sliding Lookback Windows, UQ112x112) │
│ ├── 12 Phase 5 Mini-Projects & 9 Oracle Attack Scenarios                               │
│ ├── Stateful Invariant & Fuzz Test Suites (Cumulative Price Monotonicity & Out Bounds) │
│ └── End-to-End Pricing, Quoting & TWAP Simulation Script                               │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 6: SWAP EXECUTION & ROUTER FOUNDATION (Complete & 100% Tested)                   │
│ ├── SageRouter (Stateless Execution Coordinator for Single & Multi-Hop Swaps)         │
│ ├── Exact-Input & Exact-Output Routing with Direct Pool-to-Pool Chaining               │
│ ├── Native ETH Wrapping/Unwrapping & Excess Refund Safety                              │
│ ├── Strict Slippage Enforcement (amountOutMin & amountInMax) & Timestamp Deadlines     │
│ ├── Zero Residual Router Balance Invariant (No Trapped Tokens / ETH)                   │
│ ├── 12 Phase 6 Mini-Projects & 10 Attack & Chaos Injection Scenarios                   │
│ ├── Stateful Invariant Test Suite (2,048 multi-actor swaps with 0 reverts)             │
│ └── End-to-End Swap Execution & Router Lifecycle Simulation Script                     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 7: APPROVALS, PERMIT2 & SIGNATURE-BASED TRANSACTION SAFETY (Complete & Tested)   │
│ ├── Canonical Permit2 Protocol (permit, permitTransferFrom, permitWitnessTransferFrom) │
│ ├── Dynamic EIP-712 Domain Separation with Unordered Bitmap Nonces (256 nonces/word)   │
│ ├── SagePermitRouter (Atomic EIP-2612 Permit & Permit2 Signature Swaps)               │
│ ├── Cryptographic Spender, Token, and Chain ID Binding with Low-s Verification (EIP-2) │
│ ├── 12 Phase 7 Mini-Projects & 10-Scenario Authorization Attack Lab                    │
│ ├── Stateful Invariant Test Suite (2,048 signature transfers with 0 reverts)          │
│ └── End-to-End Permit & Permit2 Swap Lifecycle Simulation Script                       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 8: FRONTEND, WALLET & TRANSACTION INTEGRATION (Complete & 100% Tested)           │
│ ├── Production React + TypeScript + Viem + Wagmi Web Interface (Glassmorphism theme)   │
│ ├── Exact BigInt Math (Zero floating-point loss across 6, 8, 18 decimal tokens)        │
│ ├── Real-Time Constant-Product Quoting & Price Impact Engine (1-10000 BPS)             │
│ ├── Exact Approvals, Unlimited Approvals, and Gasless Permit2 EIP-712 Signing          │
│ ├── Transaction Builder, Pre-Flight Simulation, Dynamic Gas Buffer, and Error Decoder  │
│ ├── Liquidity Card (Add/Remove Liquidity with exact LP share ratios)                   │
│ ├── 15 Phase 8 Mini-Projects & 25 Vitest Unit Tests (100% Green)                       │
│ └── Local Storage Transaction History Tracker & Accessible UI                          │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 9: AI CHATBOT & NATURAL-LANGUAGE ASSISTANT (Complete & Sandboxed)                │
│ ├── Conversational Market Assistant with strict non-custodial read boundaries          │
│ ├── Zero Private Key Access & Structured Calldata Review Flow                          │
│ └── Explanatory Trade Intent Formulation                                               │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 10: INDEXING, MARKET DATA & PROTOCOL OBSERVABILITY (Complete & 100% Tested)      │
│ ├── TypeScript + Node.js + Viem Event Ingestion & Processing Pipeline                  │
│ ├── Blockchain Reorganization Detection, Parent Hash Verification & Rollback Engine   │
│ ├── Relational Schema & Materialized Position / Snapshot Tables (PostgreSQL 15+)       │
│ ├── Multi-Timeframe OHLCV Candlestick Aggregation (1m, 5m, 15m, 1h, 1d) & 24h Volume   │
│ ├── GraphQL & REST API Resolvers with Cursor-Based Pagination                          │
│ ├── On-Chain vs DB Automated State Reconciliation & Health Lag Metrics                 │
│ └── 20 Phase 10 Mini-Projects & Zero-Dependency Test Suite (100% Green)                │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 11: SECURITY AUDIT, FORMAL VERIFICATION & ADVERSARIAL TESTING (100% Tested)     │
│ ├── Comprehensive Threat Modeling & Trust Boundary Formalization                       │
│ ├── 15 Attack Lab & Adversarial Simulations (Reentrancy, First-Liquidity, Replay)      │
│ ├── Formal Invariant Proof of Monotonic k Growth                                       │
│ └── 193/193 Foundry Tests (100% Green)                                                 │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ PHASE 12: TESTNET DEPLOYMENT, INTEGRATION & PRODUCTION VALIDATION (Complete & Tested)  │
│ ├── Reproducible Foundry Deployment Script (script/DeployPhase12Testnet.s.sol)        │
│ ├── Ethereum Sepolia Testnet Manifest & Contract Verification                          │
│ ├── Canonical Test Token Setup (18, 6, 8 decimals) & Initial Pool Liquidity Seeding   │
│ ├── End-to-End Testnet Integration Suite (204/204 Tests Passing)                       │
│ └── Production Readiness Certification (Production Candidate)                          │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🧪 Comprehensive Test Suite Results

- **Smart Contract Protocol Suite**: **204 Tests Passed, 0 Failed, 0 Skipped (100% Green)**
  ```bash
  forge test
  ```
- **Frontend & Web3 Integration Suite**: **25 Tests Passed, 0 Failed, 0 Skipped (100% Green)**
  ```bash
  cd frontend && npm test
  ```
- **Indexer & Observability Suite**: **20 Mini-Projects & Tests Passed (100% Green)**
  ```bash
  node --experimental-strip-types indexer/test/runTests.js
  ```

---

## 📚 Technical Documentation Hub

- [Phase 1 Documentation (`docs/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/01_EVM_FOUNDATION.md) (17 Modules)
- [Phase 2 Documentation (`docs/phase2/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase2/01_ERC20_STANDARD.md) (27 Modules)
- [Phase 3 Documentation (`docs/phase3/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase3/01_AMM_THEORY.md) (40 Modules)
- [Phase 4 Documentation (`docs/phase4/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase4/01_LP_ECONOMIC_MODEL.md) (44 Modules)
- [Phase 5 Documentation (`docs/phase5/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase5/01_PRICING_ARCHITECTURE.md) (41 Modules)
- [Phase 6 Documentation (`docs/phase6/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase6/01_ROUTER_ARCHITECTURE.md) (43 Modules)
- [Phase 7 Documentation (`docs/phase7/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase7/01_APPROVAL_ARCHITECTURE.md) (43 Modules)
- [Phase 8 Documentation (`docs/phase8/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase8/01_FRONTEND_ARCHITECTURE.md) (50 Modules)
- [Phase 9 Documentation (`docs/phase9/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase9/01_INDEXER_ARCHITECTURE.md) (71 Modules)
- [Phase 10 Documentation (`docs/phase10/`)](file:///c:/Users/User/Desktop/akira%202.0/docs/phase10/PHASE10_ARCHITECTURE.md) (32 Modules)
- [Phase 11 Documentation](file:///c:/Users/User/Desktop/akira%202.0/PHASE11_SECURITY_REPORT.md) (29 Modules)
- [Phase 12 Documentation](file:///c:/Users/User/Desktop/akira%202.0/PHASE12_FINAL_REPORT.md) (14 Modules)
