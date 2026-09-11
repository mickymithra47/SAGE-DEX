# 15 — Verifying Contract Binding & Cross-Deployment Immunity

## 1. Verifying Contract Invariant
- The domain separator binds `verifyingContract: address(this)`.
- If an attacker deploys a rogue clone of `Permit2` or tries to replay a signature against a different contract deployment, the signature digest differs and verification reverts.
