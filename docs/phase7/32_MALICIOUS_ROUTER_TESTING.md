# 32 — Malicious Spender / Rogue Router Laboratory

## 1. Adversarial Test: Unauthorized Spender
- Scenario: Signer authorizes `SagePermitRouter` for 100 USDC.
- Attacker deploys `SpenderFrontRunningAttacker` and submits the signature.
- **Result**: `Permit2.permitTransferFrom` computes `msg.sender == address(attacker)`, recovering an invalid signer address; reverts with `InvalidSignature()`.
