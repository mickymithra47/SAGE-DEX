# 29 — Emergency Nonce Invalidation & User Sovereignty

## 1. Decentralized Invalidation
- Users can invalidate up to 256 pending signature nonces in a single transaction by calling:
  `Permit2.invalidateUnorderedNonces(wordPos, mask)`
- No admin key, multisig, or protocol pause required; users retain 100% sovereign control over their signatures.
