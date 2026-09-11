# 24 — Phishing Resistance & Wallet Signature Clarity

## 1. EIP-712 Structured Data Visual Clarity
- Rather than displaying an opaque hex hash (`0x8a91...`), modern wallets parse EIP-712 typed structs to display:
  - **Spender**: `SageRouter` (`0x...`)
  - **Token**: USDC (`100.00 USDC`)
  - **Nonce**: `42`
  - **Deadline**: `2026-08-20 18:30:00 UTC`

---

## 2. Security Benefit
- Significantly reduces phishing vectors compared to legacy `eth_sign` or blind unlimited approvals.
