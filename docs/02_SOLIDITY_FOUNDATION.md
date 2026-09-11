# 02 — Solidity Language & Type System Foundation

## 1. What is Solidity?
Solidity is a statically typed, contract-oriented, high-level programming language targeting the EVM. It compiles human-readable code into compact EVM bytecode, managing low-level memory pointers, storage layout offsets, and ABI function dispatch tables.

---

## 2. Why Does the EVM Need It?
Writing raw bytecode or pure Yul for complex financial state machines is error-prone, insecure, and difficult to audit. Solidity provides:
- Type safety and bounds checking.
- Structured object-oriented abstractions (contracts, interfaces, libraries).
- Native ABI encoding and decoding.
- Custom errors and structured exception handling.

---

## 3. Core Language Components & EVM Compilation

### Variable Classification & Storage/Code Allocation
| Type | Keyword | EVM Location | Mutability | Gas Characteristic |
| :--- | :--- | :--- | :--- | :--- |
| **State Variable** | Default | Persistent Storage (`SLOAD`/`SSTORE`) | Mutable | Expensive (100–20,000 gas) |
| **Constant** | `constant` | Inlined directly into runtime bytecode | Immutable at compile-time | Free (0 SLOAD cost; inlined as `PUSH32`) |
| **Immutable** | `immutable` | Appended/inlined into deployed runtime bytecode during constructor | Immutable after deployment | Free (0 SLOAD cost; inlined as `PUSH32`) |
| **Local Variable** | `memory` / `calldata` / `stack` | Stack or volatile memory | Mutable / Read-only | Cheap (3–12 gas per word) |

### Function Visibility & Dispatch
- `external`: Part of the contract's public interface; receives parameters in `calldata` directly without allocating memory.
- `public`: Can be called externally or internally. When called internally, parameters are passed via stack/memory; when called externally, via calldata.
- `internal`: Accessible only within the current contract or derived contracts. Does not generate an ABI function selector; called via direct `JUMP`/`JUMPI` opcodes.
- `private`: Accessible only within the exact contract where declared.

### Function Mutability
- `pure`: Promises neither to read from nor write to state. Compiles without `SLOAD` or `SSTORE`.
- `view`: Promises not to modify state. Can be executed externally via `STATICCALL` with 0 state risk.
- `payable`: Allows the function to receive native Ether (`msg.value`). Omitting `payable` adds a compiler check (`CALLVALUE; DUP1; ISZERO; JUMPI; REVERT`) to reject incoming ETH.
- Non-payable default: Explicitly enforces `msg.value == 0`.

### Custom Errors vs Require Strings
- **`require(cond, "Long revert string")`**: Encodes `Error(string)` selector (`0x08c379a0`), 32-byte string offset, string length, and ASCII string bytes in memory. Costs ~200–500 extra gas per call.
- **`if (!cond) revert CustomError(arg1, arg2)`**: Encodes 4-byte custom error selector + ABI-encoded parameters. Avoids string literal memory allocation and saves significant gas.

---

## 4. User-Defined Value Types & Interfaces
```solidity
// User Defined Value Type: 0 runtime cost abstraction over uint256
type Wad is uint256;

interface IPoolCallback {
    function swapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}
```

---

## 5. Receive vs Fallback Functions
- `receive() external payable`: Triggered when ETH is sent to contract with empty `calldata` (`msg.data.length == 0`).
- `fallback() external payable`: Triggered when no function selector matches `msg.sig` or when data is non-empty without a matching function. Used in proxy delegatecall forwarders.

---

## 6. Security Implications
1. **Unprotected Initializers**: In upgradeable contracts, forgetting access control on initialization functions allows attackers to claim contract ownership.
2. **Missing `receive()` with payable fallback**: Contracts with payable fallback can silently accept unintended method calls or ETH without explicit routing.

---

## 7. Gas Implications
- Always use `immutable` for addresses and configuration parameters initialized in the constructor (e.g., token addresses, factory pointers). Saves 2,100–2,600 gas on every single read.
- Prefer `external` over `public` for functions with large array parameters to allow direct `calldata` processing.

---

## 8. Future AMM / DEX Relevance
- In SAGE DEX, factory addresses, token0/token1 immutable references, and pool keys will be stored as `immutable` variables to achieve gas efficiency during high-frequency swaps.
