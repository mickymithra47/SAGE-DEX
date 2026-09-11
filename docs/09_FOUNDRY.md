# 09 — Foundry Toolchain & Protocol Engineering Workflow

## 1. Foundry Architecture
Foundry is a blazing-fast, portable, and modular toolkit for Ethereum application development written in Rust. It eliminates JavaScript/TypeScript context switching by using Solidity natively for contracts, scripts, and tests.

```
Foundry Toolchain:
├── forge: Build compiler, test runner, gas profiler, and script executor
├── cast: Command-line tool for RPC interactions, encoding, decoding, and contract inspection
├── anvil: Fast local EVM development node with customizable state and instant mining
└── chisel: Interactive Solidity REPL environment for real-time opcode/syntax exploration
```

---

## 2. Essential CLI Commands

```bash
# Compile contracts with bytecode size inspection
forge build --sizes

# Run full test suite with verbose execution traces
forge test -vvv

# Run specific test matching a regex filter
forge test --match-test test_Project3_VaultDepositAndWithdraw -vvvv

# Generate gas consumption snapshot
forge snapshot

# Inspect storage slot layout of a contract
forge inspect Project1_StorageContract storageLayout

# Query function selector via Cast
cast sig "transfer(address,uint256)" # Outputs: 0xa9059cbb

# Compute CREATE2 deterministic address
cast create2 --starts-with 0000 --init-code-hash <hash>

# Start local Anvil development node
anvil --block-time 1
```

---

## 3. Essential Cheatcodes Reference

| Cheatcode | Purpose | Example |
| :--- | :--- | :--- |
| `vm.prank(addr)` | Sets `msg.sender` for the immediate next call | `vm.prank(alice); token.transfer(bob, 10);` |
| `vm.startPrank(addr)` | Sets `msg.sender` for all subsequent calls until `stopPrank` | `vm.startPrank(alice); ... vm.stopPrank();` |
| `vm.deal(addr, amount)` | Sets the native ETH balance of an address | `vm.deal(alice, 100 ether);` |
| `vm.warp(timestamp)` | Sets the block timestamp (`block.timestamp`) | `vm.warp(block.timestamp + 7 days);` |
| `vm.roll(blockNumber)` | Sets the block number (`block.number`) | `vm.roll(19_000_000);` |
| `vm.expectRevert(selector)` | Asserts that the next call reverts with specific error | `vm.expectRevert(ZeroAddress.selector);` |
| `vm.expectEmit()` | Asserts that specific event topics and data are emitted | `vm.expectEmit(true, true, false, true);` |
| `bound(val, min, max)` | Constrains fuzzed input within valid numerical bounds | `amount = bound(amount, 1e6, 1e24);` |
