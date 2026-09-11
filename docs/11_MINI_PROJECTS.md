# 11 — Mini-Projects Architecture & Technical Reference

## Project Overview

Phase 1 implements 8 self-contained foundational mini-projects located in `src/05_mini_projects/` to master smart contract primitives before building DEX protocols.

```
┌───────────────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Project                                       │ Core Competencies Mastered                                  │
├───────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ 1. Storage Contract                           │ Packed slot boundaries, custom errors, indexed event topics │
│ 2. ERC-20 Token                               │ Supply conservation invariant, balance/allowance tracking   │
│ 3. Vault                                      │ Fractional share accounting, virtual offset donation defense│
│ 4. Escrow                                     │ Explicit state machine, timelocks, multi-role settlement    │
│ 5. Deterministic Factory                      │ CREATE2 salt-based deployment, address precomputation       │
│ 6. Callback Protocol                          │ Flashloan-style callback interface, balance delta checks    │
│ 7. Low-Level Call Laboratory                  │ Raw CALL, STATICCALL, DELEGATECALL with revert bubbling     │
│ 8. Yul Math Laboratory                        │ Fixed-point WAD arithmetic, Babylonian sqrt in assembly     │
└───────────────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
```

---

## Detailed Project Analysis

### Project 1: Storage Contract (`Project1_StorageContract.sol`)
- **Key Mechanics**: Packs `address owner` (20 bytes), `uint64 period` (8 bytes), and `uint32 threshold` (4 bytes) into a single 32-byte storage slot (Slot 0).
- **Events**: Emits `ConfigUpdated` with 3 indexed topics allowing fast log filtering.
- **Errors**: Implements `Unauthorized`, `InvalidAmount`, `ArrayOutOfBounds`.

### Project 2: Standalone ERC-20 Token (`Project2_ERC20Token.sol`)
- **Key Mechanics**: Complete, zero-dependency ERC-20 implementation.
- **Invariants**: Strictly enforces total supply conservation ($\sum \text{balances} = \text{totalSupply}$).
- **Permit**: Implements EIP-712 domain separator hashing foundation for gasless approvals.

### Project 3: Token Vault (`Project3_Vault.sol`)
- **Key Mechanics**: Fractional share issuance where $\text{shares} = \frac{\text{assets} \times (\text{totalShares} + 10^3)}{\text{totalAssets} + 10^3}$.
- **Rounding Direction**: Rounds down on deposit and withdraw to protect vault solvency.
- **Donation Attack Defense**: Implements a $10^3$ virtual asset/share offset to prevent inflation attacks.

### Project 4: Multi-Party Escrow (`Project4_Escrow.sol`)
- **Key Mechanics**: Explicit finite state machine: `Created` $\rightarrow$ `Funded` $\rightarrow$ `Disputed` / `Settled` / `Refunded`.
- **Authorization**: Granular role-based access (`onlyBuyer`, `onlySeller`, `onlyArbiter`) and timelocked auto-release.

### Project 5: Deterministic CREATE2 Factory (`Project5_DeterministicFactory.sol`)
- **Key Mechanics**: Deploys instances via `create2(0, add(bytecode, 0x20), mload(bytecode), salt)`.
- **Precomputation**: Off-chain and on-chain address calculation matching $\text{keccak256}(\text{0xff} \parallel \text{factory} \parallel \text{salt} \parallel \text{keccak256}(\text{initCode}))$.

### Project 6: Callback Protocol (`Project6_CallbackProtocol.sol`)
- **Key Mechanics**: Flashloan callback pattern invoking `IProtocolCallback(caller).onCallback()`.
- **Accounting Invariant**: Verifies `balanceAfter >= balanceBefore + fee` post-execution.

### Project 7: Low-Level Call Laboratory (`Project7_LowLevelCallLab.sol`)
- **Key Mechanics**: Direct execution of raw `call`, `staticcall`, and `delegatecall` opcodes.
- **Error Handling**: Uses inline assembly `revert(add(returnData, 0x20), mload(returnData))` to bubble up target revert reasons faithfully.

### Project 8: Yul-Optimized Math Library (`Project8_YulOptimizedMath.sol`)
- **Key Mechanics**: WAD fixed-point multiplication (`wmul`), division (`wdiv`), and Babylonian square root (`sqrtYul`) implemented in hand-tuned assembly.
