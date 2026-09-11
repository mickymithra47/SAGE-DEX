# 21 — ECDSA Signature Malleability & High-$s$ Rejection

## 1. Malleability Vulnerability
- For any valid ECDSA signature $(r, s)$, the tuple $(r, \text{secp256k1n} - s)$ is also a mathematically valid signature for the same message.

---

## 2. Mitigation in `Permit2._recoverSigner`
```solidity
if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D57617F83A26633E977373E29B0EA5B) {
    return address(0);
}
if (v != 27 && v != 28) return address(0);
```
- Strictly enforces low-$s$ canonical signatures (EIP-2).
