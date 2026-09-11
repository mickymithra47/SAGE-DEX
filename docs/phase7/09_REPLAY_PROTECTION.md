# 09 — Replay Protection & Attack Vectors

## 1. Attack Vectors Prevented
1. **Same-Transaction Replay**: Nonce consumed on first execution; second invocation in same block reverts `InvalidNonce()`.
2. **Subsequent-Transaction Replay**: Stored bitmap bit remains set to `1`.
3. **Cross-Chain Replay**: Signature digest includes `chainId`; invalid on any alternate chain.
4. **Cross-Spender Replay**: Signature binds `spender = msg.sender`; unauthorized callers cannot execute.
5. **Cross-Token Replay**: Token address is embedded in the signed EIP-712 struct.
