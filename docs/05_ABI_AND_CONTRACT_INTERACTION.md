# 05 — ABI, Calldata Encoding & Low-Level Calls

## 1. What is the ABI?
The **Application Binary Interface (ABI)** is the standardized contract specification defining how data structures and functions are encoded into raw binary payloads that the EVM can interpret.

---

## 2. Function Selectors & Calldata Structure

A function call in Solidity compiles into a payload structured as:

$$\text{Calldata} = \underbrace{\text{Selector}}_{\text{4 Bytes}} \parallel \underbrace{\text{Encoded Arguments}}_{\text{Multiples of 32 Bytes}}$$

The **Function Selector** is the first 4 bytes of the `keccak256` hash of the normalized canonical function signature (without spaces, with canonical type names like `uint256` instead of `uint`):

$$\text{Selector} = \text{bytes4}(\text{keccak256}("transfer(address,uint256)")) = \text{0xa9059cbb}$$

```
Calldata Structure:
[ 0x00 .. 0x03 ] -> 0xa9059cbb (4-byte function selector)
[ 0x04 .. 0x23 ] -> 0x000000000000000000000000d8da6bf26964af9d7eed9e03e53415d37aa96045 (to: 32-byte padded)
[ 0x24 .. 0x43 ] -> 0x0000000000000000000000000000000000000000000000056bc75e2d63100000 (amount: 100 ETH)
```

---

## 3. Static vs Dynamic Type Encoding
- **Static Types** (`uint256`, `address`, `bool`, `bytes32`): Encoded in-place as 32-byte words.
- **Dynamic Types** (`bytes`, `string`, `uint256[]`, dynamic arrays): Encoded using an offset pointer pointing to the location where the length and raw data elements reside.

---

## 4. EVM Low-Level Call Mechanisms

```
+----------------+---------------------+-------------------+------------------+-----------------------+
| Call Opcode    | Context msg.sender  | Context msg.value | address(this)    | Storage Executed In   |
+----------------+---------------------+-------------------+------------------+-----------------------+
| CALL           | Caller contract     | Value forwarded   | Target contract  | Target Storage        |
| STATICCALL     | Caller contract     | 0 (Forbidden)     | Target contract  | Read-only Target      |
| DELEGATECALL   | Original msg.sender | Value preserved   | Caller contract  | Caller Storage        |
+----------------+---------------------+-------------------+------------------+-----------------------+
```

### Detailed Opcode Comparison

1. **`CALL`**:
   - Switches execution context to the target contract.
   - `msg.sender` inside the target is the calling contract (`address(this)` of caller).
   - Allows ETH transfer (`{value: x}`).
   - Modifies target contract storage.

2. **`STATICCALL`**:
   - Executes target code under read-only state restriction.
   - Throws an immediate EVM exception if target attempts `SSTORE`, `LOG`, `CREATE`, `SELFDESTRUCT`, or `CALL` with value.
   - Vital for read-only simulations and view methods.

3. **`DELEGATECALL`**:
   - Executes target bytecode in the **caller's** storage context.
   - `msg.sender`, `msg.value`, and `address(this)` remain preserved from the caller.
   - Used for upgradeable proxy patterns and reusable libraries.

4. **`CREATE` vs `CREATE2`**:
   - `CREATE`: Address $= \text{keccak256}(\text{rlp.encode}([\text{sender}, \text{nonce}]))[12:]$.
   - `CREATE2`: Address $= \text{keccak256}(\text{0xff} \parallel \text{sender} \parallel \text{salt} \parallel \text{keccak256}(\text{initCode}))[12:]$.
   - `CREATE2` enables deterministic pool address precomputation before on-chain deployment.

---

## 5. Security & Gas Implications
- **Unchecked Return Values**: Low-level `target.call(...)` returns `(bool success, bytes memory data)`. If `success` is ignored, execution continues even if the subcall reverted! Always enforce `require(success, "Call failed")`.
- **Revert Reason Bubbling**: Raw assembly reverts must be bubbled up to preserve accurate error reporting.

---

## 6. Future AMM / DEX Relevance
- Router execution requires multi-hop dynamic calldata encoding and decoding.
- AMM factories rely on `CREATE2` to compute pool addresses deterministically without querying chain state.
