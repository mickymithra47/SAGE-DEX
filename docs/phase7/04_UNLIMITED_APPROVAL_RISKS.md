# 04 — Unlimited Approval Threat Model & Long-Lived Exposure

## 1. Threat Scenarios
- **DEX Upgrade / Proxy Takeover**: If a router contract is upgradeable or compromised, all accounts with active `type(uint256).max` allowances can be drained instantly.
- **Phishing Authorization**: Users blindly signing `approve(maliciousContract, max)` lose their entire token balance.

---

## 2. Sage Mitigations
- `SageRouter` and `SagePermitRouter` are strictly **immutable** (non-upgradeable) and stateless.
- Protocol frontends can offer exact approvals by default with an opt-in toggle for unlimited approvals.
