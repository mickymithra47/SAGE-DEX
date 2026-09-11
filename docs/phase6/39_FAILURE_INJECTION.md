# 39 — Failure Injection & Chaos Engineering Suite

## 1. Chaos Scenarios Injected
1. **Expired Deadline**: Transaction submitted with past timestamp -> Reverts `Expired()`.
2. **Slippage Breach**: Market moves beyond `amountOutMin` -> Reverts `InsufficientOutput()`.
3. **Reverting ETH Recipient**: Contract recipient lacks receive/fallback -> Reverts `TransferFailed()`.
4. **Zero Address Recipient**: Target address is `address(0)` -> Reverts `InvalidRecipient()`.
5. **Non-Existent Pair**: Route references uncreated pool -> Reverts `PairNotFound()`.
