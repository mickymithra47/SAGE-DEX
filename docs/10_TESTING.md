# 10 — Testing Methodology & Invariant-Driven Verification

## 1. The Protocol Testing Hierarchy

DeFi protocol development requires a multi-layered verification strategy that goes far beyond standard unit testing:

```
                  ┌───────────────────────────────┐
                  │    Invariant Testing (Top)    │  Stateful randomized sequence testing
                  ├───────────────────────────────┤
                  │    Fuzz Testing (Property)    │  Stateless input space exploration
                  ├───────────────────────────────┤
                  │    Fork / Integration Tests   │  Real-world mainnet state interactions
                  ├───────────────────────────────┤
                  │    Unit & Revert Tests        │  Isolated function & branch verification
                  └───────────────────────────────┘
```

---

## 2. Example-Based vs Invariant-Based Testing

| Dimension | Example-Based Testing | Property/Invariant-Based Testing |
| :--- | :--- | :--- |
| **Input Selection** | Hand-crafted specific inputs (e.g., deposit 100, withdraw 50) | Randomized mathematical fuzzing across $2^{256}$ input space |
| **Focus** | "Does function $f(x)$ return $y$ for this exact $x$?" | "Does condition $C$ hold true for ALL valid states and sequences?" |
| **Exploit Discovery**| Catches known regressions | Uncovers unknown edge cases, arithmetic overflows, and sequence exploits |

---

## 3. The 10 Testing Paradigms in SAGE DEX

1. **Unit Tests**: Verifies individual function execution, return types, and storage mutations in isolation.
2. **Integration Tests**: Verifies end-to-end multi-contract flows (e.g. Factory deploys Token -> Vault initializes -> User deposits).
3. **Revert & Custom Error Tests**: Asserts that unauthorized or invalid calls revert with exact 4-byte custom error selectors via `vm.expectRevert()`.
4. **Event Emission Tests**: Verifies that state changes emit expected event topics and unindexed data via `vm.expectEmit()`.
5. **Access Control Tests**: Verifies that non-owners/unauthorized callers are blocked from privileged administrative functions.
6. **Edge-Case Tests**: Explicitly tests 0 values, `type(uint256).max`, 1 wei, boundary conditions, and zero addresses.
7. **Stateless Fuzz Tests**: Tests mathematical properties using randomized inputs constrained by `bound(val, min, max)` (e.g., multiplication commutativity, supply conservation).
8. **Stateful Invariant Tests**: Uses dedicated Handler contracts to execute randomized sequences of deposits, swaps, and withdrawals while asserting core protocol invariants on every single step.
9. **Gas Benchmark Tests**: Compares opcode and pattern costs (e.g., packed vs unpacked storage, Yul vs Solidity math) via `forge snapshot`.
10. **Fork Tests**: Forks live blockchain state (`--fork-url`) to test interactions with live tokens, oracles, and liquidity pools.

---

## 4. Handler-Based Invariant Architecture Example

In `test/invariant/VaultInvariant.t.sol`:
- `VaultHandler` exposes randomized action methods (`deposit`, `withdraw`, `fundActors`).
- The `VaultInvariantTest` asserts two critical protocol invariants across hundreds of consecutive random actions:
  1. **Solvency Invariant**: `token.balanceOf(vault) >= vault.totalAssets()`
  2. **Conservation Invariant**: `totalWithdrawn <= totalDeposited`
