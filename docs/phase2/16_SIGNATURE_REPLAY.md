# 16 — Signature Replay Attack Vectors & Defensive Engineering

## 1. Signature Replay Attack Vectors
A signature replay attack occurs when a valid cryptographic signature is captured and submitted in an unauthorized context:

```
┌─────────────────────────────────┬───────────────────────────────────┬───────────────────────────────────────────┐
│ Replay Vector                   │ Exploit Mechanism                 │ Defensive Mechanism                       │
├─────────────────────────────────┼───────────────────────────────────┼───────────────────────────────────────────┤
│ 1. Same-Contract Replay         │ Submitting same signature twice   │ Monotonic nonces (`nonces[owner]++`)      │
│ 2. Cross-Contract Replay        │ Using signature on clone contract │ Domain separator `verifyingContract` check│
│ 3. Cross-Chain Replay           │ Replaying on Arbitrum / Optimism  │ Domain separator `chainId` check          │
│ 4. Hard Fork Replay             │ Replaying post-fork on old chain  │ Dynamic `block.chainid` re-computation   │
│ 5. Expired Signature Abuse      │ Executing old unmined signature   │ Strict `block.timestamp <= deadline` check│
│ 6. Signature Malleability (s)   │ Inverting elliptic curve $s$-value│ Enforce $s \le \text{secp256k1n} / 2$     │
└─────────────────────────────────┴───────────────────────────────────┴───────────────────────────────────────────┘
```

---

## 2. Dynamic Chain ID Handling in Production
If a token contract caches `DOMAIN_SEPARATOR` as an `immutable` variable and the blockchain later experiences a hard fork (producing two chains with different chain IDs):
- The cached domain separator retains the old chain ID.
- Signatures on the new chain can be replayed on the old chain!

### Production Dynamic Domain Separator Pattern:
```solidity
function DOMAIN_SEPARATOR() public view returns (bytes32) {
    if (block.chainid == _INITIAL_CHAIN_ID) {
        return _INITIAL_DOMAIN_SEPARATOR;
    } else {
        // Rebuild dynamically if chain ID changed post hard-fork
        return _buildDomainSeparator(block.chainid);
    }
}
```
