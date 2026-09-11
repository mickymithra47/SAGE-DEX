# 01 — EVM Architecture & Execution Model

## 1. What is the EVM?
The **Ethereum Virtual Machine (EVM)** is a quasi-Turing complete, 256-bit stack-based execution engine that executes smart contract bytecode deterministically across every node in the Ethereum network. It defines the formal state transition function:

$$\sigma_{t+1} = \Upsilon(\sigma_t, T)$$

where $\sigma_t$ represents the World State, $T$ represents a valid transaction, and $\Upsilon$ is the EVM execution function.

---

## 2. Why Does the EVM Need It?
Decentralized financial protocols require total, deterministic consensus across thousands of independent validator nodes with varying hardware. If execution were non-deterministic (e.g. dependent on clock time, thread scheduling, or floating-point CPU architectures), network state would fork. The EVM enforces deterministic computation through discrete 32-byte word sizes, bounded gas limits, and formal state transition rules.

---

## 3. How Does It Work Internally?

### World State ($\sigma$)
The World State is a modified Merkle Patricia Trie (MPT) mapping 160-bit (20-byte) account addresses to 4-element account states:
1. **Nonce**:
   - For an **Externally Owned Account (EOA)**: Number of transactions sent from this account.
   - For a **Contract Account**: Number of contract creation events (`CREATE` calls) made by this contract.
2. **Balance**: Amount of native Ether (in wei: $10^{-18}$ ETH) owned by this address.
3. **Storage Root**: A 256-bit hash of the root node of the 256-bit to 256-bit MPT that encodes the contract's persistent storage. (EOAs have an empty storage root `keccak256("")`).
4. **Code Hash**: The `keccak256` hash of the immutable EVM bytecode associated with this account. (EOAs have `keccak256("")`).

```
                ┌──────────────────────────────────────┐
                │          EVM World State             │
                │        (Merkle Patricia Trie)        │
                └──────────────────┬───────────────────┘
                                   │
         ┌─────────────────────────┴─────────────────────────┐
         ▼                                                   ▼
┌──────────────────┐                                ┌──────────────────┐
│   EOA Account    │                                │ Contract Account │
├──────────────────┤                                ├──────────────────┤
│ Nonce: 14        │                                │ Nonce: 3         │
│ Balance: 5.2 ETH │                                │ Balance: 100 ETH │
│ StorageRoot: 0x0 │                                │ StorageRoot: MPT │
│ CodeHash: 0x0    │                                │ CodeHash: 0xabcd │
└──────────────────┘                                └──────────────────┘
```

### The EVM Virtual Machine Components
During transaction execution, the EVM instantiates an isolated execution context composed of:
1. **Program Counter (PC)**: Points to the next bytecode instruction to execute.
2. **Stack**: A LIFO array of 256-bit words, capped at 1024 elements (Stack depth limit).
3. **Memory**: Volatile, linear byte-addressable memory buffer that expands dynamically with quadratic gas cost.
4. **Calldata**: Immutable byte array containing the input arguments of the transaction or message call.
5. **Storage**: Persistent, key-value storage mapping $2^{256}$ 32-byte keys to 32-byte values.
6. **Transient Storage (EIP-1153, Cancun EVM)**: Key-value storage mapping that persists across call frames within a single transaction but is discarded upon transaction finality.
7. **Gas Meter**: Tracks remaining gas; decrements with each opcode executed. If meter hits 0, an `Out Of Gas` error triggers an immediate revert of all state changes in that frame.

---

## 4. How Does Solidity Compile and Use It?
Solidity code is parsed into an Abstract Syntax Tree (AST), lowered into intermediate representations (Yul / EVM assembly), optimized, and compiled to raw hex bytecode.
- Functions are dispatched via a 4-byte selector switch table checking `msg.sig`.
- Variables are mapped to storage slots, memory pointers, or stack registers.
- State access becomes `SLOAD` / `SSTORE` (persistent) or `TLOAD` / `TSTORE` (transient).

---

## 5. Transaction Lifecycle Breakdown

```
[User / EOA] 
     │ (Signs transaction with ECDSA secp256k1 private key)
     ▼
[Raw Tx RLP / EIP-1559] (nonce, maxFeePerGas, maxPriorityFeePerGas, gasLimit, to, value, data, v, r, s)
     │
     ▼
[JSON-RPC Node] (eth_sendRawTransaction)
     │
     ▼
[Mempool / Block Builder] (Validates signature, nonce, upfront balance: gasLimit * maxFeePerGas + value)
     │
     ▼
[EVM Execution Engine] 
     ├── Deducts upfront gas payment: gasLimit * baseFee
     ├── Increments sender nonce
     ├── Instantiates execution environment (Stack, Memory, Calldata, Storage)
     ├── Executes Bytecode Opcode by Opcode
     ├── Emits Logs / Topics (LOG0 - LOG4)
     └── Computes State Delta
     │
     ▼
[Post-Execution Settlement]
     ├── Unused gas refunded to sender (up to 20% max refund)
     ├── Base fee burned (EIP-1559)
     ├── Priority fee (tip) paid to block validator / builder
     └── Receipt generated (status: 1/0, cumulativeGasUsed, logsBloom, logs)
```

---

## 6. Security Implications
1. **Stack Limit (1024 frames)**: Deep recursive calls or expression nesting can hit stack depth limits ("Stack too deep" compiler errors or call depth limits).
2. **Deterministic Reverts**: Any unhandled revert in an external call reverts all sub-calls unless isolated in low-level `call()`.
3. **State Rollback**: Reverts restore storage, balance, and nonces to the snapshot taken at the beginning of the call frame, but gas consumed up to the point of revert is NOT refunded.

---

## 7. Gas Implications
- Opcode costs directly reflect computational and cryptographic complexity.
- Reading cold accounts/storage costs 2600 gas (`COLD_SLOAD`), warm access costs 100 gas (`WARM_SLOAD`).
- Memory expansion has a linear cost for small buffers and quadratic cost for large buffers ($3 \times \text{words} + \lfloor \frac{\text{words}^2}{512} \rfloor$).

---

## 8. Future AMM / DEX Relevance
- **Singleton Architecture (PoolManager)**: Uses transient storage (`TSTORE`/`TLOAD`) to track flash accounting balances across multiple pool swaps in a single transaction, settling net tokens only at transaction conclusion.
- **Multihop Swaps**: Understanding memory expansion and calldata slicing ensures routing algorithms do not waste gas re-allocating swap hop arrays in memory.
