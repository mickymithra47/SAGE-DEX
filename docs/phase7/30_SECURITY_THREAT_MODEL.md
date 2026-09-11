# 30 — Comprehensive Security Threat Model & Mitigations

## 15-Vector Threat Assessment

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Threat Scenario                       │ Protocol Defense Mechanism                             │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. Signature Replay in same tx/block  │ Bitmap nonce flipped; duplicate reverts InvalidNonce() │
│ 2. Cross-Chain Replay                 │ block.chainid embedded dynamically in domain separator│
│ 3. Cross-Contract Replay              │ verifyingContract bound to address(this)               │
│ 4. Cross-Token Replay                 │ Token address embedded in TokenPermissions hash        │
│ 5. Wrong Spender Interception         │ msg.sender embedded directly in dataHash               │
│ 6. Over-Authorization / Wrong Amount  │ requestedAmount <= permitted.amount enforced           │
│ 7. Expired Signature Exploitation     │ block.timestamp <= deadline enforced                   │
│ 8. High-s Signature Malleability      │ Enforced low-s canonical bound (<= secp256k1n / 2)     │
│ 9. Nonce Collision Attack             │ 256-bit word positioning prevents bit collision        │
│ 10. Phishing Authorization            │ Transparent EIP-712 structured wallet previews         │
│ 11. Unlimited Allowance Drain         │ Stateless/immutable contracts + exact permit support   │
│ 12. Spender Router Compromise         │ Non-upgradeable immutable contracts                    │
│ 13. Malicious Non-Standard Tokens     │ SafeTokenTransfer Yul assembly handling                │
│ 14. Reentrancy During Transfer        │ Non-reentrant AMM pairs + stateless router             │
│ 15. Witness Tampering                 │ Witness hash embedded in EIP-712 struct hash           │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
