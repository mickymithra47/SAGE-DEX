# 39 — Stateless Property Fuzz Testing Suite

## 1. Fuzz Properties Verified
- **Arbitrary Valid Signatures**: Across 256 fuzz runs with randomized amounts and nonces, valid signatures execute precisely once and deliver the exact requested token amount.
- **Unauthorized Modifications**: Any random alteration of bytes in `signature`, `amount`, `nonce`, or `spender` reverts with `InvalidSignature()` or `InvalidNonce()`.
