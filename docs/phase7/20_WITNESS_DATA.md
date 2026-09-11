# 20 — Witness Data Cryptographic Binding

## 1. Witness Mechanics
- `permitWitnessTransferFrom` allows appending arbitrary application-specific metadata (e.g. order parameters, fee shares, router metadata) to the signature hash.
- The witness hash is injected directly into the EIP-712 type definition and data hash, ensuring that any tamper with witness parameters invalidates the signature.
