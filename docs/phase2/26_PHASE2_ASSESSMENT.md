# 26 — Phase 2 Protocol Engineering Assessment & Key Takeaways

## 1. Architectural Lessons Learned
1. **Never Trust Token Contracts**: External ERC-20 tokens are arbitrary programs that can revert, re-enter, take fees, return unexpected values, or alter state at any time.
2. **Safe Wrappers are Mandatory**: Standard Solidity interfaces cannot safely interact with real-world DeFi tokens like USDT. Every DEX interaction must route through low-level assembly wrappers.
3. **Decimals Dictate Pricing**: Without explicit decimal scaling, multi-decimal pairs (e.g. USDC/WETH) suffer catastrophic mispricing.
4. **Permits Streamline UX but Demand Strict Security**: Gasless permits eliminate friction but require strict nonce tracking, deadline checks, and dynamic domain separators.

---

## 2. Quantitative Benchmarks

```
┌──────────────────────────────────────────────┬──────────────────┐
│ Operation                                    │ Gas Cost (Units) │
├──────────────────────────────────────────────┼──────────────────┤
│ Standard ERC-20 Transfer (Warm SSTORE)       │ ~36,971 gas      │
│ Standard ERC-20 Approve                      │ ~31,770 gas      │
│ WETH Deposit (Wrap ETH -> WETH)              │ ~59,630 gas      │
│ WETH Withdraw (Unwrap WETH -> ETH)           │ ~11,554 gas      │
│ EIP-2612 Permit Signature Verification       │ ~72,281 gas      │
│ SafeTokenTransfer (Happy Path)               │ ~8,410 gas       │
└──────────────────────────────────────────────┴──────────────────┘
```
