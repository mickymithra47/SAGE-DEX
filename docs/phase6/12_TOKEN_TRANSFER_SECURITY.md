# 12 — Token Transfer Security & Compatibility Policy

## 1. Supported Token Behaviors
Following the Phase 2 token policy:
- **Standard ERC-20**: Returning `true`.
- **Missing Return Value (USDT)**: Handled via low-level returndata length inspection in `SafeTokenTransfer`.
- **Reverting on Failure**: Bubbled up to trigger atomic transaction rollback.

---

## 2. Unsupported Token Policy
- **Fee-on-Transfer Tokens**: Not supported in standard router methods because gross transfer amounts do not reach the pair intact.
- **Rebasing Tokens**: Must be wrapped prior to routing.
