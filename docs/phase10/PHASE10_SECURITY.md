# Phase 10 — Security & Threat Modeling

## 1. Threat Mitigation Strategies
- **Non-Authoritative Client**: Indexed data is never used to validate on-chain invariant fulfillment ($x \cdot y = k$).
- **Reorg Injection Defense**: Immediate rollback of orphaned blocks prevents fraudulent transaction tracking.
- **SQL & Parameter Injection**: All queries strictly parameterized through type-safe query drivers.
- **API Exhaustion Defense**: Pagination caps (max 100) and query timeouts.
