# 10 — Signature Expiration & Temporal Freshness

## 1. Expiration Verification
```solidity
if (block.timestamp > deadline) revert SignatureExpired();
```

---

## 2. Expiration Semantics
- **Short-Lived Authorization**: Recommended signature deadline is 30 to 300 seconds for automated trades.
- Guarantees that pending mempool authorizations cannot be executed weeks or months later after market prices have diverged.
