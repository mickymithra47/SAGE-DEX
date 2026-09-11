# 21 — Token Security Threat Model & Risk Matrix

## Comprehensive 20-Point Token Threat Matrix

```
┌──────────────────────────────────────────────┬───────────────────────────────────┬───────────────────────────────────────────────────────────┐
│ Threat                                       │ Attack Vector / Impact            │ Protocol Mitigation & Decision                            │
├──────────────────────────────────────────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────┤
│ 1. Malicious Token Contract                  │ Arbitrary code execution / theft  │ Isolated pool architectures; no global approvals          │
│ 2. Malicious Token Owner                     │ Backdoor minting / instant rugpull│ Verified registry badges; permissionless pool isolation   │
│ 3. Reentrant Token                           │ Hook callback re-enters swap pool │ Strict CEI + ReentrancyGuard mutex on all entrypoints     │
│ 4. Fee-on-Transfer Token                     │ Balance mismatch on deposit       │ Balance-delta measurement (Exact-Input swaps only)        │
│ 5. Rebasing Token                            │ Elastic supply alters reserves    │ Unsupported in raw pools; require wrapped share vault     │
│ 6. Blacklist Token                           │ Admin freezes pool address        │ Documented asset risk (Category E); isolated pool risk    │
│ 7. Pausable Token                            │ Admin freezes all transfers       │ Documented asset risk (Category E); isolated pool risk    │
│ 8. False-Return Token                        │ Returns false on failure          │ SafeTokenTransfer treats false return as revert           │
│ 9. No-Return Token (USDT)                    │ Returns 0 bytes returndata        │ SafeTokenTransfer checks returndatasize == 0              │
│ 10. Approval Race Attack                     │ Front-running allowance decrease  │ safeApproveWithReset + Permit2 expiring allowances        │
│ 11. Signature Replay                         │ Same signature executed twice     │ Nonces incremented on every permit; EIP-712 binding       │
│ 12. Cross-Chain Replay                       │ Signature replayed on alt chain   │ Domain separator binds block.chainid dynamically          │
│ 13. Decimal Mismatch                         │ 1:1 math between 6 & 18 dec tokens│ TokenAccountingMath scales all amounts to 18-decimal WAD  │
│ 14. Division Precision Loss                  │ Division before multiplication    │ Multiply first; explicit round-up on fees                 │
│ 15. Direct Token Donation                    │ Inflates pool asset balance       │ Track internal reserves; sync() / skim() reconciliation   │
│ 16. Flashloan Balance Manipulation           │ Large spot balance skew in block  │ TWAP oracles + internal reserve isolation                 │
│ 17. Transfer Cap Restriction                 │ Reverts if amount > max limit     │ Swap chunking in router / Category E classification       │
│ 18. Missing Decimals Method                  │ Reverts on decimals() query       │ Low-level staticcall fallback defaulting to 18 decimals   │
│ 19. Signature Malleability                   │ Modifying ECDSA s-value           │ Enforce s <= secp256k1n / 2                               │
│ 20. Malicious Metadata Phishing              │ Spoofed token symbol/name         │ On-chain registry verified flags + token address indexing │
└──────────────────────────────────────────────┴───────────────────────────────────┴───────────────────────────────────────────────────────────┘
```
