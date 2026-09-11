# 03 — Network Detection & Chain Handling

## 1. Supported Network Matrix

```
┌─────────────────────────────┬───────────┬────────────────────────────────────────────────────────┐
│ Network                     │ Chain ID  │ Protocol Status                                        │
├─────────────────────────────┼───────────┼────────────────────────────────────────────────────────┤
│ Anvil Local Fork / Devnet   │ 31337     │ Full Local Sandbox Deployment                          │
│ Sepolia Ethereum Testnet    │ 11155111  │ Public Testnet Deployment                              │
│ Ethereum Mainnet            │ 1         │ Production Target                                      │
└─────────────────────────────┴───────────┴────────────────────────────────────────────────────────┘
```

---

## 2. Unsupported Network Guard
- If `chainId` is not in `SUPPORTED_CHAINS`, the UI renders a prominent warning banner and prompts the user to switch networks, blocking calldata construction to prevent accidental execution against wrong contracts.
