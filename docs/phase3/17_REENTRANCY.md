# 17 — Reentrancy Threats & Mutex Lock Strategy

## 1. The Reentrancy Vector in AMM Pools
Because `SagePair.swap()` executes external token transfers and supports arbitrary `sageCall()` flash swap callbacks, a malicious token (e.g. ERC-777 or custom callback token) can re-enter the pair before reserves are updated:

```
POOL (Executes swap)
 │
 ├── 1. Transfers Token0 to Attacker
 │        │
 │        ▼ (Token0 callback fires)
 │     ATTACKER CONTRACT
 │        │
 │        └── Calls pair.swap() again! (Reserves are still stale!)
 │
 └── 2. Re-entrancy Mutex Blocks Execution!
```

---

## 2. Low-Level Non-Reentrant Mutex
To permanently neutralize all reentrancy threats across swaps, mints, burns, skims, and syncs:
```solidity
uint256 private unlocked = 1;

modifier lock() {
    if (unlocked != 1) revert Locked();
    unlocked = 0;
    _;
    unlocked = 1;
}
```
- The mutex variable `unlocked` transitions to `0` prior to any external interaction and resets to `1` only after all state checks, invariant tests, and storage updates complete.
