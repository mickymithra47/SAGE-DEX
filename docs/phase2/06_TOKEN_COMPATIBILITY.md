# 06 — Real-World Token Compatibility & Return Value Anomalies

## 1. The Token Non-Standard Reality
Although EIP-20 explicitly states that `transfer` and `transferFrom` must return a `bool`, several of the largest tokens by market capitalization violate this rule.

```
┌───────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Token Behavior Pattern                │ Real-World Example / Consequence                            │
├───────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ 1. Standard ERC-20                    │ Returns boolean true on success; reverts on failure.        │
│ 2. Missing Return Data (No-Return)   │ USDT (Tether), BNB — returns 0 bytes of returndata.         │
│ 3. False-Returning Tokens             │ ZRX, EURS — returns boolean false instead of reverting.     │
│ 4. Reverting Without Reason           │ Some legacy tokens revert with empty error bytes.          │
│ 5. Fee-on-Transfer Tokens             │ STA, PAXG — deductions taken during transfer.               │
│ 6. Rebasing Tokens                    │ stETH, AMPL — balances shift dynamically outside transfers. │
└───────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
```

---

## 2. The Strict Solidity ABI Decoding Trap
If a contract calls `IERC20(token).transfer(to, amount)` using standard Solidity syntax:
1. Solidity generates bytecode expecting at least 32 bytes of return data (`abi.decode(returndata, (bool))`).
2. When interacting with **USDT**, the returndata size is **0 bytes**.
3. Solidity's internal ABI decoder attempts to decode 32 bytes from 0 bytes, fails, and throws an immediate EVM revert!
4. Result: Naive DEX contracts cannot trade USDT without specialized wrappers.
