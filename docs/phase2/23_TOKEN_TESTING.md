# 23 — Phase 2 Token Layer Testing Methodology & Verification

## 1. Testing Framework Overview

```
Phase 2 Test Harness Structure (88 Total Passing Tests):
├── Unit Tests (ERC20Token, WETH, Decimals, TokenRegistry)
├── Approval Tests (Infinite allowances, race conditions, increase/decrease allowance)
├── Permit & EIP-712 Tests (Valid signatures, expired deadlines, wrong nonces, replay attacks)
├── Security Lab Tests (12 exploit demonstrations & defense verifications)
├── Adversarial Token Compatibility Tests (12 mock tokens tested against diagnostic engine)
├── Token Accounting Tests (Internal reserve tracking, sync() / skim() donation handling)
├── Stateless Property Fuzz Tests (Supply conservation, decimal scaling roundtrip, mulDiv bounds)
├── Stateful Invariant Tests (WETH 1:1 solvency, deposit conservation across 2,048 calls)
└── Gas Profiling Tests (Exact gas measurements for transfers, approvals, wrapping, unwrapping)
```

---

## 2. Tested Invariant Properties

1. **Property 1 (Supply Conservation)**: $\sum \text{balances} = \text{totalSupply}$ across all arbitrary transfer paths.
2. **Property 2 (WETH Solvency)**: $\text{address}(\text{weth}).\text{balance} \equiv \text{weth}.\text{totalSupply}()$.
3. **Property 3 (Allowance Invariance)**: Spenders cannot extract more than their active allowance.
4. **Property 4 (Permit Nonce Invariance)**: Monotonic nonces strictly prevent signature replay attacks.
5. **Property 5 (Decimal Scaling Precision)**: $\text{fromWad}(\text{toWad}(X, d), d) \equiv X$.
