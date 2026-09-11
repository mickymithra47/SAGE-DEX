# 09 — Route Representation: Minimal Address Arrays

## 1. Linear Representation: `address[] calldata path`
- The route is represented as an ordered array of token addresses:
  `[Token0, Token1, Token2, ...]`
- **Advantages**:
  - Minimal calldata encoding overhead.
  - Transparent verification by wallets and explorers.
  - Zero need for complex graph decoders or arbitrary bytecode dispatchers.
