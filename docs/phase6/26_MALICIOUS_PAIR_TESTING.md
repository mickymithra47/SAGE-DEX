# 26 — Malicious Pair Contract Testing & Registry Isolation

## 1. Threat Scenarios
- **Fake Pair Impersonation**: Attacker attempts to route swaps through an unverified custom contract that returns fraudulent output amounts.
- **Defense**: Router queries `ISageFactory(factory).getPair(tokenA, tokenB)`. Because only genuine pairs created by the factory are returned, malicious standalone pair contracts are unreachable.
