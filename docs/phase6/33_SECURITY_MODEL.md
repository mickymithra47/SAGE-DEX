# 33 — Security Model & Threat Mitigation Matrix

## Comprehensive Phase 6 Threat Matrix

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Threat Category                       │ Protocol Defense Mechanism                             │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. Mempool Frontrunning / Slippage    │ Enforced amountOutMin and amountInMax checks.          │
│ 2. Miner Block Delay Exploitation     │ Enforced timestamp deadline checks.                    │
│ 3. Trapped User Funds                 │ Pull-exact and zero-retention invariant (balance == 0).│
│ 4. Reentrancy on ETH Transfers        │ Stateless router architecture + non-reentrant pairs.   │
│ 5. Non-Standard ERC-20 Tokens         │ Hand-tuned SafeTokenTransfer Yul assembly.             │
│ 6. Malicious Pair Impersonation       │ Factory getPair registry validation on every hop.      │
│ 7. Accidental Burn to address(0)      │ Explicit InvalidRecipient() rejection.                 │
│ 8. Native ETH Refund Theft            │ Direct transfer to msg.sender with revert on failure.  │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
