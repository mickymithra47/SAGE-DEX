# Phase 11 — Approval & Allowance Security Audit

## 1. Allowance Scoping
- Direct ERC-20 allowances granted to `Permit2` do NOT grant direct transfer authority to arbitrary contracts.
- Transferees must provide valid cryptographic EIP-712 signatures explicitly naming `msg.sender` as the permitted `spender`.
