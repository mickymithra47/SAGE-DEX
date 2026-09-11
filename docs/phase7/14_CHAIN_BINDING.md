# 14 — Chain Binding & Cross-Chain Replay Immunity

## 1. Domain Chain Binding
- `block.chainid` is embedded in the EIP-712 domain separator.
- A signature generated on Ethereum Mainnet (`chainId: 1`) is cryptographically invalid on Arbitrum (`chainId: 42161`), Optimism (`chainId: 10`), or local devnets.
