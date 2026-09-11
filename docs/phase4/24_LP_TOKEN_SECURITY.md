# 24 — LP Token Security Architecture & Mint/Burn Access Control

## 1. Zero Unauthorized Issuance Guarantee
In `SageERC20` / `SagePair`:
- `_mint` and `_burn` are **internal** methods.
- The ONLY contract logic capable of minting LP shares is `SagePair.mint()`, which strictly requires physical balance deltas of both deposited tokens.
- The ONLY contract logic capable of burning LP shares is `SagePair.burn()`, which burns shares previously transferred to the pair contract and transfers proportional reserves back to the caller.

---

## 2. No External Owner or Admin Mint Privileges
- There is NO `owner`, `onlyOwner`, `minterRole`, or governance address that can mint LP shares.
- Total supply is mathematically locked to physical liquidity deposits.
