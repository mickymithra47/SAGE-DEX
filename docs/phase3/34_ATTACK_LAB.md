# 34 — AMM Attack Laboratory: 20 Exploit Scenarios & Hardened Defenses

## 20 Exploit Scenarios & Defense Matrix

```
┌──────────────────────────────────────────────┬───────────────────────────────────┬───────────────────────────────────────────────────────────┐
│ Attack Scenario                              │ Precondition / Exploit Vector     │ Protocol Defense Mechanism                                │
├──────────────────────────────────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────┤
│ 1. Reentrancy via Callback                   │ Callback attempts re-entering swap│ Low-level mutex (unlocked == 0 reverts with Locked)       │
│ 2. Direct Donation Attack                    │ Attacker transfers tokens directly│ Stored reserves isolate pricing; skim() sweeps excess     │
│ 3. Reserve Manipulation via Flash Loan       │ Skewing spot reserves in one block│ Invariant check requires post-fee product preservation    │
│ 4. Invalid Token Pair                        │ tokenA == tokenB or zero address  │ Factory reverts with IdenticalAddresses / ZeroAddress     │
│ 5. Duplicate Pool Creation                   │ Re-creating pair with A/B or B/A  │ Factory checks getPair[t0][t1] != address(0)              │
│ 6. Arithmetic Overflow in Reserves           │ Extreme token balance > uint112   │ _update checks balance <= type(uint112).max               │
│ 7. Rounding Exploitation                     │ Manipulating integer divisions    │ Ceil division on input; floor division on output/LP shares│
│ 8. Insufficient Liquidity Drain              │ Requesting output >= reserve      │ Reverts with InsufficientLiquidity                        │
│ 9. Malicious Token Callback Hijacking        │ External token executes hijack    │ Low-level mutex lock across all state transitions         │
│ 10. False-Return Token Integration           │ Token returns false on failure    │ SafeTokenTransfer treats false return as revert           │
│ 11. No-Return Token Integration (USDT)       │ Token returns 0 bytes data        │ SafeTokenTransfer checks returndatasize == 0              │
│ 12. Fee-on-Transfer Token Discrepancy        │ Transfer tax deducts balance      │ Pair directly measures physical balance delta post-call   │
│ 13. Rebasing Token Desynchronization         │ Elastic supply changes balances   │ Raw rebasing tokens prohibited; require share wrapper     │
│ 14. Zero Amount Swap / Liquidity             │ 0 amount input/output/liquidity   │ Reverts with InsufficientOutput / InsufficientLiquidity   │
│ 15. Extreme Integer Amount Handling          │ uint256 max inputs                │ Checked arithmetic in Solidity 0.8.26 prevents overflow   │
│ 16. State Inconsistency on Revert            │ Transfer failure during swap      │ Atomic EVM revert rolls back all state changes            │
│ 17. Failed External Transfer Handling        │ SafeTokenTransfer failure         │ Custom error bubbles up and aborts atomically             │
│ 18. Unexpected External Call Hijacking       │ Token recipient hijacks execution │ Isolated pair execution model; no privileged allowances   │
│ 19. LP Share Manipulation                    │ Distorted asset ratio deposit     │ Min ratio minting penalizes mispriced deposits            │
│ 20. First-Liquidity Inflation Attack         │ 1-wei deposit + massive donation  │ MINIMUM_LIQUIDITY (1000) permanently burned to address(0) │
└──────────────────────────────────────────────┴───────────────────────────────────┴───────────────────────────────────────────────────────────┘
```
