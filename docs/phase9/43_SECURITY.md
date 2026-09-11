# 43 — Indexer Security & Threat Vector Analysis

## 1. Threat Matrix & Mitigations
1. **Malicious RPC Node**: Validates block hashes and parent chain continuity.
2. **Reorgs & Fork Injection**: Strict atomic unwinding and common ancestor verification.
3. **API DOS Attacks**: Hard query limit bounds, pagination depth caps, and timeout middleware.
4. **SQL Injection**: Fully parameterized queries via typed ORM/SQL drivers.
