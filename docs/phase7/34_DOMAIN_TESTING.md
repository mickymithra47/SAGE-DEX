# 34 — Domain Separator Verification & Fork Testing

## 1. Domain Properties Verified
- **Chain Fork Simulation**: Changing `block.chainid` dynamically alters `DOMAIN_SEPARATOR()`, rendering previous signatures invalid on the new fork.
- **Contract Address Binding**: Ensures signatures cannot be replayed against other protocol contracts.
