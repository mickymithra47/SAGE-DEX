# 13 — Token Approval Security, Spender Trust & Universal Routers

## 1. The Token Approval Dilemma
In decentralized exchanges, users must grant token allowances to contracts so the protocol can execute trades. However, approving smart contracts presents serious security trade-offs:

| Approval Strategy | Gas Efficiency | Security & Blast Radius |
| :--- | :--- | :--- |
| **Unlimited Approval (`type(uint256).max`)** | High (Approved once; no SSTORE on swaps) | **Critical Risk**: If router has a bug or is upgradeable, all approved funds can be drained |
| **Exact Approval (Swap amount only)** | Low (Requires separate `approve` tx + SSTORE per trade) | **Minimal Risk**: Only current swap amount is exposed |
| **Permit / Signature Approvals (EIP-2612)** | Maximum (0 standalone approve transactions; atomic) | **High Security**: Single-use, timelocked, scoped permissions |

---

## 2. Spender Trust & Contract Immutability
1. **Never Approve Upgradeable Proxies with Infinite Allowances**: If a router proxy implementation can be updated by an admin key, the admin or a compromised key can steal all approved tokens.
2. **Deterministic Immutability**: SAGE DEX core routers and position managers must be immutable contracts with no administrative withdrawal capabilities.
3. **Approval Revocation Tools**: Protocol UIs must integrate allowance management to allow users to revoke stale allowances.
