# AUDIT_FINDINGS.md
# SAGE PROTOCOL — COMPLETE AUDIT FINDINGS CATALOG
**Scope**: All Vulnerabilities, Defects, and Discrepancies Across Phases 1–12  

---

## Finding Summary

| Finding ID | Severity | Phase | Component | Title |
| :--- | :---: | :---: | :--- | :--- |
| **FINDING-01** | **CRITICAL** | Phase 12 | Deployment | False Sepolia Deployment Record in `testnet.json` |
| **FINDING-02** | **CRITICAL** | Phase 9 | AI | Complete Absence of Phase 9 AI Assistant Implementation |
| **FINDING-03** | **CRITICAL** | Phase 4 | Smart Contracts | Decimal Mixing in `LPPositionMath.calculatePositionValue` |
| **FINDING-04** | **HIGH** | Phase 8 | Frontend | Contract Execution Mocked with `setTimeout` in `App.tsx` |
| **FINDING-05** | **HIGH** | Phase 10 | Indexer | Missing Reorg Rollback for `lpPositions` in Database |
| **FINDING-06** | **HIGH** | Phase 8 | Frontend | Incomplete Calldata Construction & Dummy Selectors in `txBuilder.ts` |
| **FINDING-07** | **HIGH** | Phase 10 | API / Resolver | Unindexed In-Memory O(N) Array Scan in `getPoolStats()` |
| **FINDING-08** | **MEDIUM** | Phase 10 | Database | Candlestick Float Pricing Loses Precision on 18-Decimal Reserves |
| **FINDING-09** | **MEDIUM** | Phase 10 | API / Resolver | Native `BigInt` Return Types Cause JSON Serialization Exceptions |
| **FINDING-10** | **MEDIUM** | Phase 11 | Documentation | Over-Claimed Formal Verification in Security Reports |
| **FINDING-11** | **MEDIUM** | Phase 10 | Database | In-Memory `Map` Storage Replaces PostgreSQL Persistence |
| **FINDING-12** | **LOW** | Phase 2 | Smart Contracts | Scratch Space Returndata Edge Case in `SafeTokenTransfer.sol` |
| **FINDING-13** | **LOW** | Phase 8 | Frontend | Hardcoded Devnet Fallback Wallet in `App.tsx` |
| **FINDING-14** | **INFORMATIONAL** | Phase 5 | Smart Contracts | Unbounded `observationTimestamps` Array in `SageOracleEngine` |

---

## Detailed Finding Reports

### FINDING-01: False Sepolia Deployment Record in `testnet.json`
- **ID**: `FINDING-01`
- **PHASE**: Phase 12
- **COMPONENT**: Deployment Manifest (`deployments/testnet.json`)
- **SEVERITY**: **CRITICAL**
- **TITLE**: False Sepolia Deployment Record Using Local Anvil Deterministic Addresses
- **DESCRIPTION**: `deployments/testnet.json` claims contracts are live and verified on Sepolia (`chainId: 11155111`). However, all contract addresses match the deterministic addresses of a local Anvil node deployed from test key `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` starting at nonce 0.
- **EVIDENCE**: `SageFactory` = `0x5FbDB2315678afecb367f032d93F642f64180aa3`, `SageRouter` = `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`.
- **ROOT CAUSE**: Local broadcast artifacts were committed as public testnet deployments.
- **IMPACT**: Frontends or indexers targeting Sepolia will query unverified / non-existent contract bytecode.
- **REPRODUCTION**: Query `eth_getCode(0x5FbDB2315678afecb367f032d93F642f64180aa3)` on Ethereum Sepolia RPC; returns `0x`.
- **RECOMMENDED FIX**: Broadcast `DeployPhase12Testnet.s.sol` to Sepolia using a funded deployer key and update `testnet.json`.
- **STATUS**: **OPEN / BLOCKING**

---

### FINDING-02: Complete Absence of Phase 9 AI Assistant Implementation
- **ID**: `FINDING-02`
- **PHASE**: Phase 9
- **COMPONENT**: AI Chatbot
- **SEVERITY**: **CRITICAL**
- **TITLE**: Phase 9 AI Conversational Assistant Was Not Implemented
- **DESCRIPTION**: Phase 9 was designated as "AI Chatbot & Natural-Language Assistant", but zero implementation exists in the codebase. Indexer documentation and tests mistakenly replaced Phase 9 deliverables.
- **EVIDENCE**: Zero files in `frontend/src/` or `indexer/src/` implement chat, LLM integration, or natural language intent parsing.
- **ROOT CAUSE**: Indexer development was duplicated under Phase 9 and Phase 10 labels.
- **IMPACT**: Protocol lacks the natural language assistant deliverable required prior to Phase 13.
- **RECOMMENDED FIX**: Build the non-custodial chat interface and intent parser or officially amend Phase 9 curriculum scope.
- **STATUS**: **OPEN / BLOCKING**

---

### FINDING-03: Decimal Mixing in `LPPositionMath.calculatePositionValue`
- **ID**: `FINDING-03`
- **PHASE**: Phase 4
- **COMPONENT**: Smart Contract Math (`src/phase4/libraries/LPPositionMath.sol`)
- **SEVERITY**: **CRITICAL**
- **TITLE**: Valuation Math Adds Mismatched Decimal Amounts
- **DESCRIPTION**: `LPPositionMath.calculatePositionValue()` adds `val0` and `val1` without normalizing decimals, corrupting LP position valuations for pools with mismatched token decimals (e.g. USDC 6 dec + WETH 18 dec).
- **EVIDENCE**: `LPPositionMath.sol#L100-L105`: `totalValueWad = val0 + val1;`.
- **ROOT CAUSE**: Missing decimal scaling step before summing asset valuations.
- **IMPACT**: Severe under-reporting of 6-decimal token value by a factor of $10^{12}\times$.
- **RECOMMENDED FIX**: Normalize both token claim amounts to 18 decimals before computing USD valuation.
- **STATUS**: **OPEN / BLOCKING**

---

### FINDING-04: Contract Execution Mocked with `setTimeout` in `App.tsx`
- **ID**: `FINDING-04`
- **PHASE**: Phase 8
- **COMPONENT**: Frontend (`frontend/src/App.tsx`)
- **SEVERITY**: **HIGH**
- **TITLE**: Swap and Liquidity Actions Use Mock Timers Instead of On-Chain Calls
- **DESCRIPTION**: In `App.tsx`, transaction handlers (`handleSwap`, `handleApprove`, `handleAddLiquidity`, `handleSignPermit2`) simulate execution via `setTimeout()` timers rather than calling Viem contract write methods.
- **EVIDENCE**: `App.tsx#L126-L188`.
- **ROOT CAUSE**: Development UI placeholders were not replaced with real Wagmi/Viem write hooks.
- **IMPACT**: Frontend cannot execute real trades on any EVM chain or local node.
- **RECOMMENDED FIX**: Connect Wagmi `useWriteContract()` with `SageRouter` and `SagePermitRouter`.
- **STATUS**: **OPEN / BLOCKING**

---

### FINDING-05: Missing Reorg Rollback for `lpPositions` in Database
- **ID**: `FINDING-05`
- **PHASE**: Phase 10
- **COMPONENT**: Indexer Database (`indexer/src/db/database.ts`)
- **SEVERITY**: **HIGH**
- **TITLE**: `rollbackBlocksAbove()` Deletes Blocks & Swaps but Preserves Mutated LP Positions
- **DESCRIPTION**: When an on-chain reorganization occurs, `rollbackBlocksAbove()` clears reorged blocks, swaps, mints, and burns, but leaves `this.lpPositions` untouched.
- **EVIDENCE**: `database.ts#L324-L349`.
- **ROOT CAUSE**: Incomplete rollback logic in database layer.
- **IMPACT**: Reorged mint/burn transactions leave corrupted, phantom LP balances in the indexer database.
- **RECOMMENDED FIX**: Roll back LP position mutations or replay valid historical transfers during rollback.
- **STATUS**: **OPEN / BLOCKING**

---

### FINDING-06: Incomplete Calldata Construction & Dummy Selectors in `txBuilder.ts`
- **ID**: `FINDING-06`
- **PHASE**: Phase 8
- **COMPONENT**: Frontend Transaction Builder (`frontend/src/lib/txBuilder.ts`)
- **SEVERITY**: **HIGH**
- **TITLE**: Malformed Calldata Encoding and Dummy Selectors
- **DESCRIPTION**: `buildSwapExactTokensCalldata` only encodes 2 parameters (`amountIn`, `amountOutMin`), omitting `path`, `to`, and `deadline`. `FUNCTION_SELECTORS` uses placeholder values `0x12345678` and `0x87654321`.
- **EVIDENCE**: `frontend/src/lib/txBuilder.ts#L27-L39`.
- **ROOT CAUSE**: Incomplete manual ABI encoding.
- **IMPACT**: Any transaction submitted using `txBuilder` will revert in EVM calldata decoding.
- **RECOMMENDED FIX**: Use Viem `encodeFunctionData()` with complete `ROUTER_ABI`.
- **STATUS**: **OPEN / BLOCKING**

---

### FINDING-07: Unindexed In-Memory O(N) Array Scan in `getPoolStats()`
- **ID**: `FINDING-07`
- **PHASE**: Phase 10
- **COMPONENT**: API Resolvers (`indexer/src/api/resolvers.ts`)
- **SEVERITY**: **HIGH**
- **TITLE**: Scalability Bottleneck in 24h Volume and Fee Resolver
- **DESCRIPTION**: `getPoolStats()` fetches up to 10,000 swaps and sorts the entire unbounded `this.swaps` array in memory before filtering.
- **EVIDENCE**: `resolvers.ts#L54` and `database.ts#L187-L200`.
- **ROOT CAUSE**: Lack of indexed time-range query and in-memory sort on every API call.
- **IMPACT**: Severe CPU and memory degradation under high swap volume.
- **RECOMMENDED FIX**: Execute an indexed SQL aggregate query in PostgreSQL or maintain a rolling 24h accumulator bucket.
- **STATUS**: **OPEN**

---

### FINDING-08: Candlestick Float Pricing Loses Precision on 18-Decimal Reserves
- **ID**: `FINDING-08`
- **PHASE**: Phase 10
- **COMPONENT**: Database Candlesticks (`indexer/src/db/database.ts`)
- **SEVERITY**: **MEDIUM**
- **TITLE**: Raw Division of BigInts Cast to Float Distorts Chart Prices
- **DESCRIPTION**: `database.ts` computes candlestick prices as `Number(pool.reserve1) / Number(pool.reserve0)`. For 18-decimal reserves exceeding $10^{16}$ wei, precision is truncated, and decimal scaling differences (e.g. 6 dec vs 18 dec) are ignored.
- **EVIDENCE**: `database.ts#L268`.
- **ROOT CAUSE**: Direct float division without decimal normalization.
- **IMPACT**: Candlestick charts display unnormalized or distorted price curves.
- **RECOMMENDED FIX**: Use `calculateNormalizedPrice()` from `priceEngine.ts`.
- **STATUS**: **OPEN**

---

### FINDING-09: Native `BigInt` Return Types Cause JSON Serialization Exceptions
- **ID**: `FINDING-09`
- **PHASE**: Phase 10
- **COMPONENT**: API Resolvers (`indexer/src/api/resolvers.ts`)
- **SEVERITY**: **MEDIUM**
- **TITLE**: Resolver Return Types Contain Native BigInts Breaking JSON.stringify
- **DESCRIPTION**: `getPools()`, `getSwaps()`, and `getUserPositions()` return records with native `bigint` fields, causing `TypeError: Do not know how to serialize a BigInt` in standard REST and GraphQL servers.
- **EVIDENCE**: `resolvers.ts#L17-L48`.
- **ROOT CAUSE**: DTO models not stringifying BigInt values at the API boundary.
- **IMPACT**: REST/GraphQL endpoints crash when returning raw query results.
- **RECOMMENDED FIX**: Convert all `bigint` properties to decimal strings in API DTOs.
- **STATUS**: **OPEN**

---

### FINDING-10: Over-Claimed Formal Verification in Security Reports
- **ID**: `FINDING-10`
- **PHASE**: Phase 11
- **COMPONENT**: Security Documentation (`PHASE11_FORMAL_VERIFICATION.md`)
- **SEVERITY**: **MEDIUM**
- **TITLE**: Invariant and Fuzzing Tests Mislabeled as Formal Verification
- **DESCRIPTION**: Phase 11 documentation claimed formal verification was complete. However, no formal specification languages (Certora, Halmos, SMTChecker) were used.
- **EVIDENCE**: `PHASE11_FORMAL_VERIFICATION.md` describes Foundry invariant tests as formal proofs.
- **ROOT CAUSE**: Terminology confusion between stateful fuzzing/invariants and formal verification.
- **IMPACT**: False assurance regarding mathematical completeness of proofs.
- **RECOMMENDED FIX**: Accurately classify testing as "Stateful Property-Based Fuzzing & Invariant Verification".
- **STATUS**: **OPEN**

---

### FINDING-11: In-Memory `Map` Storage Replaces PostgreSQL Persistence
- **ID**: `FINDING-11`
- **PHASE**: Phase 10
- **COMPONENT**: Database Persistence (`indexer/src/db/database.ts`)
- **SEVERITY**: **MEDIUM**
- **TITLE**: Production Indexer Operates on Ephemeral In-Memory Maps
- **DESCRIPTION**: While `schema.sql` defines PostgreSQL tables, `database.ts` only implements an in-memory `Map` data store without persistent database connection pooling.
- **EVIDENCE**: `database.ts#L94-L101`.
- **ROOT CAUSE**: Production SQL driver integration was deferred.
- **IMPACT**: Total data loss on process restart; lack of database stress testing.
- **RECOMMENDED FIX**: Implement a PostgreSQL client database adapter.
- **STATUS**: **OPEN**

---

### FINDING-12: Scratch Space Returndata Edge Case in `SafeTokenTransfer.sol`
- **ID**: `FINDING-12`
- **PHASE**: Phase 2
- **COMPONENT**: Smart Contract Library (`src/phase2/libraries/SafeTokenTransfer.sol`)
- **SEVERITY**: **LOW**
- **TITLE**: Potential Scratch Space Read on 1–31 Byte Returndata
- **DESCRIPTION**: If a non-compliant token returns between 1 and 31 bytes, `returndatacopy(0x00, 0x00, 0x20)` reads past returndata length.
- **EVIDENCE**: `SafeTokenTransfer.sol#L76-L82`.
- **ROOT CAUSE**: Hardcoded 32-byte copy when `returndatasize > 0`.
- **IMPACT**: Extremely low likelihood edge case with non-compliant tokens.
- **RECOMMENDED FIX**: Assert `returndatasize >= 32` when `returndatasize > 0`.
- **STATUS**: **OPEN**

---

### FINDING-13: Hardcoded Devnet Fallback Wallet in `App.tsx`
- **ID**: `FINDING-13`
- **PHASE**: Phase 8
- **COMPONENT**: Frontend (`frontend/src/App.tsx`)
- **SEVERITY**: **LOW**
- **TITLE**: Devnet Wallet `0xf39Fd...` Hardcoded in Frontend
- **DESCRIPTION**: In `App.tsx`, if no wallet provider is available, it defaults to the Anvil test account `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`.
- **EVIDENCE**: `App.tsx#L64`.
- **ROOT CAUSE**: Development convenience fallback.
- **IMPACT**: Unconnected users see pre-filled balance data for the test account.
- **RECOMMENDED FIX**: Show disconnected wallet state when no provider is connected.
- **STATUS**: **OPEN**

---

### FINDING-14: Unbounded `observationTimestamps` Array in `SageOracleEngine`
- **ID**: `FINDING-14`
- **PHASE**: Phase 5
- **COMPONENT**: Smart Contract Oracle (`src/phase5/core/SageOracleEngine.sol`)
- **SEVERITY**: **INFORMATIONAL**
- **TITLE**: Unbounded Storage Growth on High-Frequency Oracle Updates
- **DESCRIPTION**: `observationTimestamps[pair]` grows unbounded on every block update.
- **EVIDENCE**: `SageOracleEngine.sol#L39-L43`.
- **RECOMMENDED FIX**: For mainnet deployment, use a fixed circular buffer.
- **STATUS**: **OPEN**
