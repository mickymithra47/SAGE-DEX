# 35 — Router Scope Boundaries & Feature Isolation

## 1. Architectural Scope Confirmations
- **NO Universal Router**: No bytecode commands, plugin dispatchers, or arbitrary external call dispatch.
- **NO Cross-DEX Aggregation**: Swaps only route through Sage protocol pairs.
- **NO Smart Order Routing (SOR)**: Route is provided deterministically by the caller.
- **NO Permit2 in Phase 6**: Standard ERC-20 allowances used; Permit2 deferred to Phase 7.
