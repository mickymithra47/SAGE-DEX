# 37 — Deterministic Event Sorting & Sequencing

## 1. Deterministic Ordering Key
- Events are ordered strictly by:
  `ORDER BY block_number DESC, log_index DESC`
- Prevents timestamp collision artifacts from multi-transaction blocks.
