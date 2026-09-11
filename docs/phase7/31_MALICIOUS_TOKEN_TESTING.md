# 31 — Malicious Token Laboratory & Transfer Integrity

## 1. Adversarial Token Results
- **False-Returning Tokens**: SafeTokenTransfer assembly catches zero return byte and reverts cleanly.
- **No-Return Tokens (USDT)**: Successfully handled via returndatasize checks.
- **Reverting Tokens**: Transaction safely reverts; state changes roll back.
- **Reentrant Callback Tokens**: Blocked by Pair mutex lock.
