# 61 — Event Decoder Test Verification

## 1. Verified Event Decoders
- [x] `PairCreated`: Topic 1, Topic 2, pair address and index unpacking.
- [x] `Swap`: Sender, recipient, amount0In/Out, amount1In/Out parsing.
- [x] `Mint` & `Burn`: Liquidity addition and withdrawal parameter extraction.
- [x] `Sync`: Reserve0 and Reserve1 uint112 unpacking.
- [x] `Transfer`: From, To, and Token value extraction for LP shares.
