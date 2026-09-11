# 22 — Transaction Simulation & Pre-Flight Execution

## 1. Dry-Run Execution via `eth_call`
- Executes `publicClient.simulateContract` prior to wallet signature prompts.
- Catches reverts (e.g. `InsufficientOutput`, `Expired`, `InsufficientAllowance`) early, preventing failed on-chain transactions and wasted gas.
