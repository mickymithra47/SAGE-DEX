# 26 — Defense Against Malicious LP Behaviors

## 1. Adversarial LP Exploit Vectors & Mitigations

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Exploit Vector                        │ Hardened Protocol Defense                              │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Zero Deposit (amount0=0, amount1=0)   │ Reverts with InsufficientLiquidityMinted()             │
│ Tiny 1-wei Deposit                    │ Reverts with InsufficientLiquidityMinted() (< 1000)    │
│ Excess Imbalanced Deposit             │ Min-ratio formula credits smaller side, penalizing user│
│ Zero Withdrawal (0 shares burned)     │ Reverts with InsufficientLiquidityBurned()             │
│ Oversized Withdrawal (> balance)      │ SafeTransfer of LP shares reverts with Insufficient    │
│ Reentrancy during Mint/Burn           │ Low-level non-reentrant mutex reverts with Locked()    │
│ Front-running LP Share Transfers      │ Standard ERC-20 nonce and allowance checks             │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
