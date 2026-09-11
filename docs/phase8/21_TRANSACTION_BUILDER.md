# 21 — Transaction Builder & Calldata Encoding

## 1. Modular Encoding Architecture
- Encapsulates ABI encoding methods (`buildSwapExactTokensCalldata`, `buildSwapExactTokensPermit2Calldata`, `buildApproveCalldata`).
- Decouples blockchain encoding logic from presentation UI components.
