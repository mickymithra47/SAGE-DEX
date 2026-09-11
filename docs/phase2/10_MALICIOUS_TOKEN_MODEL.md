# 10 — Malicious & Adversarial Token Taxonomy

## 1. Adversarial Token Landscape
A permissionless decentralized exchange will encounter malicious and adversarial tokens designed to exploit protocol assumptions.

```
┌───────────────────────────┬───────────────────────────────────┬───────────────────────────────────────────┐
│ Malicious Token Type      │ Exploit Vector                    │ Impact on DEX                             │
├───────────────────────────┼───────────────────────────────────┼───────────────────────────────────────────┤
│ 1. Reentrant Token        │ Callback during transfer hook     │ Re-enters swap/withdraw to drain reserves │
│ 2. Fee-on-Transfer Token  │ Transfer tax reduces net credited │ Accounting shortfall / insolvency         │
│ 3. Rebasing Token         │ Elastic supply changes balances   │ Spot price distortion / stuck liquidity   │
│ 4. Blacklist Token        │ Reverts for specific addresses    │ Traps pool reserves; disables swaps       │
│ 5. Pausable Token         │ Admin freezes all transfers       │ Halts trading; blocks LP withdrawals      │
│ 6. Unusual Decimals Token │ 0 or > 18 decimals                │ Precision loss / massive mispricing       │
│ 7. False-Return Token     │ Returns false instead of revert   │ Phantom deposits accepted by protocol     │
│ 8. No-Return Token (USDT) │ Returns 0 bytes returndata        │ Reverts in standard Solidity interfaces   │
│ 9. Always-Reverting Token │ Unconditional revert on transfer  │ DoS on routing hops                       │
│ 10. Malicious Callback    │ Arbitrary external call execution │ Phishing / state manipulation             │
│ 11. Transfer Caps         │ Reverts if amount > limit         │ Breaks large swap settlements             │
│ 12. Approval Race Token   │ Front-runnable allowance change   │ Extraction of double allowance            │
└───────────────────────────┴───────────────────────────────────┴───────────────────────────────────────────┘
```

---

## 2. Protocol Defensive Imperatives
1. Treat all external token transfers as **untrusted external calls**.
2. Never assume that `transferredAmount == receivedAmount`.
3. Never use raw Solidity `IERC20` interface calls; always use `SafeTokenTransfer`.
4. Wrap rebasing tokens in share-based wrappers (e.g. `wstETH`) before pool initialization.
