# 22 — Signer Recovery & Identity Verification

## 1. Strict Verification Invariant
```solidity
address recovered = _recoverSigner(digest, signature);
if (recovered == address(0) || recovered != signer) revert InvalidSignature();
```

---

## 2. Invalidation Scenarios
- Corrupted signature bytes -> Reverts `InvalidSignature()`.
- Altered token address -> Reverts `InvalidSignature()`.
- Altered amount -> Reverts `InvalidSignature()`.
- Altered spender address -> Reverts `InvalidSignature()`.
- Altered nonce -> Reverts `InvalidSignature()`.
