# 06 — Gas Economics & Optimization Mechanics

## 1. What is Gas?
Gas is the fundamental unit of measurement for computational and storage resources consumed during EVM execution. It establishes an economic market to prevent infinite loops, throttle state growth, and fairly allocate block space.

---

## 2. EIP-1559 Fee Architecture

$$\text{Total Fee Paid} = \text{Gas Used} \times \min(\text{maxFeePerGas}, \text{baseFee} + \text{maxPriorityFeePerGas})$$

- **Base Fee**: Dynamically adjusted by the protocol per block targeting 50% block utilization. **100% burned**.
- **Priority Fee (Tip)**: Paid directly to the validator/block builder to prioritize transaction inclusion.
- **Gas Limit**: Max gas units a transaction or block is permitted to consume (standard block gas limit: 30,000,000 gas).

---

## 3. Core Opcode Cost Reference Table

| Opcode | Operation | Cost (Gas) | Notes |
| :--- | :--- | :--- | :--- |
| `ADD` / `SUB` | Basic Arithmetic | 3 | Immediate stack operations |
| `MUL` / `DIV` | Multiplication / Division | 5 | Fast integer math |
| `MLOAD` / `MSTORE` | Memory Access | 3 + expansion | Linear + quadratic memory expansion |
| `SLOAD` (Cold) | First storage read in tx | **2,100** | EIP-2929 un-cached slot read |
| `SLOAD` (Warm) | Subsequent storage read | **100** | Read from transaction cache |
| `SSTORE` (Zero to Non-Zero) | Initial state allocation | **20,000** | Expands on-chain state trie |
| `SSTORE` (Non-Zero to Non-Zero) | State mutation | **2,900** | Overwrite existing value |
| `TSTORE` / `TLOAD` | Transient Storage | **100** | EIP-1153 (Cancun EVM), 0 refund |
| `LOG0` - `LOG4` | Event Emission | 375 + 375/topic + 8/byte | On-chain log recording |
| `CREATE` / `CREATE2` | Contract Deployment | 32,000 + 200/byte code | New account initialization |

---

## 4. Measured Gas Optimization Experiments

Based on measured Foundry snapshots in `test/gas/GasBenchmarks.t.sol`:

### 1. Storage Packing vs Unpacked Writes
- **Unpacked 4-Slot Cold Write**: ~93,960 gas (4 separate cold SSTOREs).
- **Packed 1-Slot Cold Write**: ~27,917 gas (1 cold SSTORE with bitmasking).
- **Net Savings**: **~66,000 gas (70% reduction)**.

### 2. Custom Error vs Require Revert String
- **`require(cond, "Long revert string...")`**: ~5,405 gas (memory allocation + selector + string length encoding).
- **`if (!cond) revert CustomError(val)`**: ~872 gas (4-byte selector + parameter).
- **Net Savings**: **~4,533 gas (84% reduction)**.

### 3. Immutable vs Storage Read
- **Cold `SLOAD`**: ~7,252 gas.
- **Code-Embedded `immutable`**: ~727 gas (`PUSH32` instruction).
- **Net Savings**: **~6,525 gas (90% reduction)**.

### 4. Calldata vs Memory for Read-Only Arrays
- `calldata` pointer passing avoids `CALLDATACOPY` and quadratic memory expansion, saving thousands of gas on large routing arrays.

### 5. Loop Optimization Patterns
```solidity
// Gas Optimized Loop
uint256 len = items.length; // Cache length outside loop (saves SLOAD / MLOAD every iteration)
for (uint256 i = 0; i < len; ) {
    // Operation...
    unchecked {
        ++i; // Saves overflow check gas + pre-increment cheaper than post-increment
    }
}
```

---

## 5. Future AMM / DEX Relevance
Every unit of gas saved in swap routing and pool math increases trade competitiveness, reduces slippage, and prevents arbitrage opportunities from being priced out by transaction fees.
