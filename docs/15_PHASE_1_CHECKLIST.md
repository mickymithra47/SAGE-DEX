# 15 — Phase 1 Mastery Checklist

## Core Competencies Verification

### 1. EVM Architecture & State
- [x] Can explain the difference between EOAs and Contract Accounts (nonce, balance, storageRoot, codeHash).
- [x] Understands the EVM 256-bit stack machine, 1024 depth limit, and program counter.
- [x] Understands World State Merkle Patricia Trie structure and state transitions.
- [x] Understands transient storage (EIP-1153 `tstore`/`tload`) vs persistent storage (`sstore`/`sload`).

### 2. EVM Data Locations & Storage Layout
- [x] Masters storage packing rules for variables $\le 32$ bytes.
- [x] Knows mapping slot formula: $\text{keccak256}(\text{abi.encode}(k, p))$.
- [x] Knows nested mapping formula: $\text{keccak256}(\text{abi.encode}(k_2, \text{keccak256}(\text{abi.encode}(k_1, p))))$.
- [x] Knows dynamic array formula: length at $p$, elements at $\text{keccak256}(p) + i$.
- [x] Understands memory layout (`0x00` scratch, `0x40` free memory pointer, `0x60` zero slot).
- [x] Understands quadratic memory expansion gas cost: $3a + \lfloor a^2 / 512 \rfloor$.
- [x] Explains why `calldata` pointer slicing is zero-copy and preferred over `memory` for read-only arguments.

### 3. EVM Call Types & Context
- [x] Explains `CALL` context switch (`msg.sender` = caller, `address(this)` = target, target storage mutated).
- [x] Explains `STATICCALL` read-only guarantee and immediate revert on state-modifying opcodes.
- [x] Explains `DELEGATECALL` proxy execution (`msg.sender` preserved, `address(this)` = proxy, proxy storage mutated).
- [x] Explains `CREATE` address derivation from sender and nonce.
- [x] Explains `CREATE2` deterministic address formula: $\text{keccak256}(\text{0xff} \parallel \text{sender} \parallel \text{salt} \parallel \text{hash}(\text{initCode}))$.

### 4. ABI & Low-Level Encoding
- [x] Computes 4-byte function selectors: $\text{bytes4}(\text{keccak256}(\text{"func(types)"}))$.
- [x] Encodes static and dynamic types in calldata.
- [x] Understands custom error selectors and why they save ~80% gas over revert strings.
- [x] Understands event topic encoding (Topic 0 = event signature hash, Topics 1–3 = indexed parameters).

### 5. Gas Economics & Profiling
- [x] Understands EIP-1559 Base Fee burn and Priority Fee (tip) mechanics.
- [x] Knows cold vs warm storage access costs (EIP-2929: 2100 vs 100 gas).
- [x] Knows storage creation (20,000 gas) vs mutation (2,900 gas) costs.
- [x] Can use `forge snapshot` and `forge test -vvv` gas logs to profile contract execution.

### 6. Security & Defensive Engineering
- [x] Masters Checks-Effects-Interactions (CEI) and ReentrancyGuard mutexes.
- [x] Understands 2-step ownership transfers (`pendingOwner`).
- [x] Understands `tx.origin` phishing exploits vs `msg.sender` authentication.
- [x] Understands checked vs unchecked low-level calls.
- [x] Understands delegatecall storage hijacking in upgradeable proxies.
- [x] Understands division before multiplication precision loss.
- [x] Understands Push Payment DoS and the Pull-Over-Push defensive pattern.
- [x] Understands fee-on-transfer, rebasing, and missing boolean return tokens (USDT).

### 7. Yul & Inline Assembly
- [x] Can write safe arithmetic, bitwise shifts, and custom memory operations in Yul.
- [x] Understands free memory pointer preservation in assembly.
- [x] Can write low-level proxy fallbacks with returndata bubbling.

### 8. Foundry Testing & Toolchain
- [x] Uses `forge`, `cast`, `anvil`, and `chisel` independently.
- [x] Can write unit tests, custom error revert tests, and event emission tests.
- [x] Can write property-based stateless fuzz tests with `bound()`.
- [x] Can write handler-based stateful invariant tests asserting protocol solvency.
