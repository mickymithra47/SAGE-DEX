# 29 — Deterministic Event Identity & Strict Idempotency

## 1. Primary Invariant
- Processing the exact same block or transaction twice produces **zero duplicate records** and zero balance distortions.
- Primary Key for all event records:
  $$\text{Event ID} = (\text{chainId}, \text{txHash}, \text{logIndex})$$
- Timestamps and block numbers are non-unique metadata attributes.
