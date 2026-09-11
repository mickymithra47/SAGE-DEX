# 14 — Phase 1 Architecture & Modular System Design

## System Architecture Diagram

```
                                  AKIRA 2.0 PROTOCOL FOUNDATION (PHASE 1)
                                  
   +-------------------------------------------------------------------------------------------------------+
   |                                         DEVELOPMENT TOOLCHAIN                                         |
   |   [ Foundry: forge 1.7.1 ]   [ cast 1.7.1 ]   [ anvil 1.7.1 ]   [ Solc 0.8.26 ]   [ Cancun EVM ]      |
   +-------------------------------------------------------------------------------------------------------+
                                                      │
         ┌────────────────────────────────────────────┼────────────────────────────────────────────┐
         ▼                                            ▼                                            ▼
+─────────────────────────────────+  +─────────────────────────────────+  +─────────────────────────────────+
|         EVM CALL LAYER          |  |       STORAGE & MEMORY LAB      |  |         YUL ASSEMBLY LAB        |
|  - CallDemo (CALL Context)      |  |  - StoragePackingExperiment     |  |  - YulArithmetic (Safe Math)   |
|  - StaticcallDemo (Read-Only)   |  |  - MappingSlotCalculator        |  |  - YulStorageOps (TLOAD/TSTORE)|
|  - DelegatecallDemo (Proxy)     |  |  - StorageCollisionDemo         |  |  - YulCallForwarder            |
|  - CreateDemo (CREATE Nonce)    |  |  - CalldataVsMemory             |  |  - YulVsSolidityBenchmark      |
|  - Create2Deployer (CREATE2)    |  |  - FreeMemoryPointerDemo        |  |                                 |
+─────────────────────────────────+  +─────────────────────────────────+  +─────────────────────────────────+
         │                                            │                                            │
         └────────────────────────────────────────────┼────────────────────────────────────────────┘
                                                      │
                                                      ▼
   +-------------------------------------------------------------------------------------------------------+
   |                                          8 MINI-PROJECTS                                              |
   |  1. Project1_StorageContract  2. Project2_ERC20Token     3. Project3_Vault     4. Project4_Escrow     |
   |  5. Project5_Deterministic    6. Project6_CallbackProto  7. Project7_LowLevel  8. Project8_YulMath    |
   +-------------------------------------------------------------------------------------------------------+
                                                      │
                                                      ▼
   +-------------------------------------------------------------------------------------------------------+
   |                                     9 SECURITY LAB SCENARIOS                                          |
   |  - Reentrancy (CEI / Lock)      - Access Control (2-Step)   - tx.origin Phishing (msg.sender)         |
   |  - Unchecked Call (Require)     - Delegatecall Hijack       - Precision Loss (Mul before Div)         |
   |  - Push Payment DoS (Pull)      - Malicious Callback        - Weird Tokens (Balance Delta / SafeERC20)|
   +-------------------------------------------------------------------------------------------------------+
                                                      │
                                                      ▼
   +-------------------------------------------------------------------------------------------------------+
   |                                     COMPREHENSIVE TEST HARNESS                                        |
   |  [ Unit Tests ]  [ Revert Tests ]  [ Stateless Fuzz ]  [ Stateful Invariants ]  [ Gas Benchmarks ]    |
   |                                50 / 50 Passing Tests (100% Green)                                     |
   +-------------------------------------------------------------------------------------------------------+
```

---

## Directory & File Structure
```
akira 2.0/
├── foundry.toml
├── README.md
├── docs/
│   ├── 01_EVM_FOUNDATION.md
│   ├── 02_SOLIDITY_FOUNDATION.md
│   ├── 03_TRANSACTION_LIFECYCLE.md
│   ├── 04_STORAGE_MEMORY_CALLDATA.md
│   ├── 05_ABI_AND_CONTRACT_INTERACTION.md
│   ├── 06_GAS.md
│   ├── 07_SECURITY.md
│   ├── 08_YUL.md
│   ├── 09_FOUNDRY.md
│   ├── 10_TESTING.md
│   ├── 11_MINI_PROJECTS.md
│   ├── 12_SECURITY_LAB.md
│   ├── 13_DEFI_PREPARATION.md
│   ├── 14_PHASE_1_ARCHITECTURE.md
│   ├── 15_PHASE_1_CHECKLIST.md
│   ├── 16_PHASE_1_ASSESSMENT.md
│   └── 17_PHASE_1_TO_PHASE_2_DEPENDENCIES.md
├── src/
│   ├── 01_evm_calls/
│   ├── 02_storage_layout/
│   ├── 03_calldata_memory/
│   ├── 04_yul_lab/
│   ├── 05_mini_projects/
│   └── 06_security_lab/
├── test/
│   ├── unit/
│   ├── security/
│   ├── fuzz/
│   ├── invariant/
│   └── gas/
└── script/
    ├── SimulateLifecycle.s.sol
    └── DeployPhase1.s.sol
```
