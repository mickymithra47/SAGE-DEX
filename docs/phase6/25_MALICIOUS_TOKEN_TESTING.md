# 25 — Malicious Token Laboratory: Attack Vectors & Rejection

## 1. Attack Vectors Tested

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Malicious Token Type                  │ Router Reaction & Security Guarantee                   │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Reverting on TransferFrom             │ Transaction reverts cleanly without state changes.     │
│ False-Returning Token                 │ Treated as failure by SafeTokenTransfer and reverts.   │
│ Empty-Returndata Token (USDT)         │ Successfully handled by SafeTokenTransfer assembly.    │
│ Reentrant Token on Transfer Callback  │ Reentrancy fails to corrupt state (Router is stateless)│
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
