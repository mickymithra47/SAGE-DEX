# Phase 11 — Trust Boundary & Security Topology

## 1. Trust Hierarchy & Authority Classification

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│ TRUST BOUNDARY TOPOLOGY                                                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [TIER 1: ON-CHAIN CONSENSUS & SMART CONTRACTS] (100% AUTHORITATIVE)                             │
│ • SageFactory, SagePair, SageRouter, Permit2, SageOracleEngine                              │
│ • Invariant enforcement (x * y = k), reserve balance-delta checks, signature verification       │
│ • Zero trust in off-chain inputs; strictly enforces calldata constraints and slippage bounds    │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [TIER 2: USER SIGNING AUTHORITY / HARDWARE WALLETS] (CRYPTOGRAPHIC SIGNING ONLY)               │
│ • Holds private keys; signs EIP-712 Permit2 payloads and EVM execution calldata                 │
│ • Must review explicit human-readable amounts, spenders, tokens, and deadlines                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [TIER 3: OFF-CHAIN READ LAYER & INDEXER] (NON-AUTHORITATIVE DERIVED READ MODEL)                │
│ • TypeScript Ingestor, PostgreSQL Database, Redis Cache                                         │
│ • CANNOT initiate transactions, CANNOT transfer tokens, CANNOT modify pool invariants           │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [TIER 4: FRONTEND UI & AI ASSISTANT] (PRESENTATION & ASSISTANCE ONLY)                           │
│ • Zero key access, zero autonomous signing, zero execution privilege                           │
│ • AI assistant operates purely as an explanatory conversational interface                       │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Component Failure & Exploit Matrix

| Component | Can Lose User Funds? | Can Manipulate Accounting? | Can Cause Incorrect Execution? | Can Bypass Authorization? | Can Create Stale Data? | Can Cause DoS? |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`SagePair.sol`** | Only if invariant violated | No (Protected by $k$) | No | No | No | No (O(1) execution) |
| **`SageRouter.sol`** | No (Enforces `amountOutMin`) | No | No | No | No | No |
| **`Permit2.sol`** | No (Bitmap nonces + EIP-712) | No | No | No | No | No |
| **Indexer / DB** | **NO** (Strictly Read Model) | **NO** | **NO** | **NO** | Yes (If lagged) | Read API only |
| **AI Assistant** | **NO** (No Key Access) | **NO** | **NO** | **NO** | Yes (If model drifts) | No |
| **Frontend UI** | **NO** (Wallet prompts user) | **NO** | No (Wallet displays calldata) | **NO** | Yes | No |
