# 28 — Reentrancy Threats Across LP Lifecycle Operations

## 1. Reentrancy Vulnerability Points in LP Operations
During `pair.mint()` or `pair.burn()`, external calls are made:
- In `burn()`: `SafeTokenTransfer.safeTransfer(token0, to, amount0)` and `safeTransfer(token1, to, amount1)` trigger external execution on recipient contracts or malicious tokens.

---

## 2. Low-Level Mutex Defense
Every state-changing function in `SagePair` (`mint`, `burn`, `swap`, `skim`, `sync`) is guarded by the `lock` modifier:

```solidity
modifier lock() {
    if (unlocked != 1) revert Locked();
    unlocked = 0;
    _;
    unlocked = 1;
}
```
- In `LPAttackLabTest` (`test_LPAttack9_ReentrancyDefense`), an attacker attempting a reentrant `mint()` during a callback reverts with `Locked()`, fully protecting the contract.
