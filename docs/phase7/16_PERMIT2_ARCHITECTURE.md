# 16 — Permit2 Canonical Architecture & Core Concepts

## 1. Permit2 Operating Modes
1. **Allowance Model (`permit` + `transferFrom`)**:
   - Manages an internal mapping of `(owner, token, spender) -> (amount, expiration, nonce)`.
   - Allows users to sign batched, time-limited allowances.
2. **Signature Transfer Model (`permitTransferFrom`)**:
   - One-shot signature-based transfer directly from owner to recipient without persistent storage of allowances.
   - Uses unordered 256-bit bitmap nonces.
