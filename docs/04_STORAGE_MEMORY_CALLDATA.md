# 04 — EVM Data Locations & Storage Layout

## 1. Comprehensive Data Location Comparison

| Location | Lifetime | Mutability | Scope | Cost Model | Typical Use |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Stack** | Frame execution | Mutable | Local function frame | Very Cheap (3 gas/pop/push) | Local scalar variables, intermediate calculations |
| **Memory** | Call transaction frame | Mutable | Contract execution | Cheap + Quadratic Expansion | Complex structs, dynamic arrays, ABI encoding |
| **Calldata** | Call transaction frame | **Immutable (Read-only)** | Input parameters | Cheapest (zero allocation cost) | External function arguments, routing data |
| **Storage** | Permanent (On-chain state) | Mutable | Global contract state | **Most Expensive** (100–20,000 gas) | Balances, allowances, ownership, pool state |
| **Transient Storage** | Single Transaction | Mutable | Cross-call within tx | Very Cheap (100 gas SLOAD/SSTORE equivalent) | Reentrancy guards, flash accounting, temp flags |

---

## 2. Storage Layout Rules & Slot Allocation

The EVM exposes a flat 32-byte key-value store with $2^{256}$ addressable slots for each contract account.

```
Slot 0: [ 32 Bytes: Variable A (uint128) | Variable B (uint64) | Variable C (uint64) ]
Slot 1: [ 32 Bytes: Variable D (uint256)                                             ]
Slot 2: [ 32 Bytes: Mapping Pointer (Keccak-based addressing)                       ]
Slot 3: [ 32 Bytes: Dynamic Array Length                                             ]
```

### Storage Packing Rules
1. Variables are packed from right to left (low-order to high-order bytes) in the order declared.
2. Multiple variables that fit within a 32-byte boundary share a single slot.
3. If a variable exceeds the remaining space in the current slot, it begins at the start of the next slot.
4. `struct` and `array` declarations always start a fresh slot.

### Storage Addressing Formulas
1. **Elementary Mapping `mapping(K => V)` at slot `p`**:
   The value for key `k` is stored at:
   $$\text{slot}(k) = \text{keccak256}(\text{abi.encode}(k, p))$$

2. **Nested Mapping `mapping(K1 => mapping(K2 => V))` at slot `p`**:
   $$\text{slot}(k_1, k_2) = \text{keccak256}(\text{abi.encode}(k_2, \text{keccak256}(\text{abi.encode}(k_1, p))))$$

3. **Dynamic Array `T[]` at slot `p`**:
   - Slot `p` stores the `length` of the dynamic array.
   - The element at index `i` is stored at:
     $$\text{slot}(arr[i]) = \text{keccak256}(\text{abi.encode}(p)) + i \cdot \text{slotsPerElement}$$

---

## 3. Memory Layout & Free Memory Pointer
Solidity allocates memory sequentially and never garbage-collects during execution:
- `0x00 - 0x3f` (64 bytes): Scratch space for hashing methods and inline assembly.
- `0x40 - 0x5f` (32 bytes): **Free Memory Pointer (FMP)**, initialized to `0x80`.
- `0x60 - 0x7f` (32 bytes): Zero slot (default value for empty dynamic memory arrays).
- `0x80+`: Dynamically allocated data.

```
Memory Layout:
[0x00 .. 0x3f] -> Scratch Space (64 bytes)
[0x40 .. 0x5f] -> Free Memory Pointer (holds next available memory address: 0x80)
[0x60 .. 0x7f] -> Zero Slot (32 bytes)
[0x80 .. END ] -> Allocated Memory Space
```

---

## 4. Calldata Zero-Copy Slicing
Unlike `memory`, which requires copying bytes via `CALLDATACOPY` and expanding memory, `calldata` allows $O(1)$ zero-cost pointer slicing:
```solidity
function processHops(bytes[] calldata hops) external {
    // Zero memory allocated; passes a slice of the original calldata pointer
    bytes[] calldata remainingHops = hops[1:];
}
```

---

## 5. Security & Gas Implications
- **Unchecked Array Allocations**: `new uint256[](largeSize)` can cause massive quadratic memory expansion gas exhaustion.
- **Slot Collisions in Upgradeable Contracts**: Modifying the declaration order of state variables in upgraded logic contracts corrupts stored values. Always use append-only or ERC-7201 namespaced storage layout.

---

## 6. Future AMM / DEX Relevance
- In SAGE DEX, AMM liquidity positions, tick indices, and reserve balances will be tightly packed into minimal storage slots (e.g. `uint128 liquidity`, `int24 tickLower`, `int24 tickUpper` in a single slot).
- Transient storage (`TSTORE`/`TLOAD`) will manage balance deltas in the core PoolManager.
