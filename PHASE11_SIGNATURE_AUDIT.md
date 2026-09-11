# Phase 11 — Signature Security & Permit2 Replay Audit

## 1. Cryptographic Signature Defenses
1. **Dynamic Domain Separator**: Uses `block.chainid` dynamically to prevent cross-chain signature replay across hard forks.
2. **Unordered Bitmap Nonce Matrix**: 256 nonces packed per storage word (`wordPos = nonce >> 8`, `bitPos = nonce & 0xff`). Replay attempts revert immediately.
3. **EIP-2 Low-s Signature Restriction**: Rejects malleable signatures with $s > \text{secp256k1n} / 2$.
