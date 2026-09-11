# 23 — Fee-On-Transfer Token Policy & Architectural Separation

## 1. Protocol Policy
- Standard `SageRouter` functions assume exact balance transfers.
- Tokens that deduct a fee on transfer deliver less than the calculated `amounts[0]` to the first pair, causing `pair.swap()` to revert with `InsufficientInputAmount()`.
- Future extensions may add dedicated `swapExactTokensForTokensSupportingFeeOnTransferTokens` methods that measure post-transfer balance deltas explicitly.
