# 27 — Partial Authorization & Nonce Consumption Semantics

## 1. Permit2 Signature Transfer Model
- In `permitTransferFrom`, the nonce is **fully consumed** during execution, even if `requestedAmount < permitted.amount`.
- A single-transfer signature cannot be split across multiple transactions.

---

## 2. Permit2 Allowance Model
- In `permit` (allowance mode), spending `amount < allowed.amount` decrements the remaining allowance balance without invalidating the allowance until expiration or full consumption.
