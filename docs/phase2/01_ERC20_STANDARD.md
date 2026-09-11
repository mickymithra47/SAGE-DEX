# 01 — ERC-20 Standard Specification & Execution Pipeline

## 1. What is the ERC-20 Standard?
EIP-20 defines the canonical fungible token standard on the Ethereum Virtual Machine (EVM). It specifies a uniform API for transferring tokens, reading account balances, tracking total circulating supply, and delegating transfer authority to third-party smart contracts (such as DEX routers and liquidity pools).

---

## 2. Why Does a DEX Need It?
A decentralized exchange requires a predictable interface to interact with thousands of distinct assets. Without a standardized interface, every liquidity pool would have to write custom integration logic for every token.

---

## 3. The 6 Core Methods & 2 Events

```
┌──────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Function / Event                     │ Description                                            │
├──────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ totalSupply()                        │ Returns the total circulating token supply             │
│ balanceOf(account)                   │ Returns the token balance of an account                │
│ transfer(to, amount)                 │ Moves tokens from msg.sender to recipient              │
│ allowance(owner, spender)            │ Returns remaining delegated allowance                  │
│ approve(spender, amount)             │ Authorizes spender to withdraw up to amount            │
│ transferFrom(from, to, amount)       │ Moves tokens from owner to recipient using allowance   │
│ Transfer(from, to, value)            │ Emitted when tokens are transferred, minted, or burned │
│ Approval(owner, spender, value)      │ Emitted when an allowance is set                       │
└──────────────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 4. End-to-End Execution Flow

```
USER
 │ (Invokes token.transfer(alice, 100))
 ▼
TOKEN CONTRACT
 │ ├── Validates msg.sender balance >= 100
 │ ├── Deducts 100 from balances[msg.sender] (SSTORE)
 │ ├── Adds 100 to balances[alice] (SSTORE)
 │ └── Emits Transfer(msg.sender, alice, 100) (LOG3)
 ▼
RECEIPT & STATE DELTA
 └── Returns boolean true to caller
```

---

## 5. Security & Protocol Implications for Future AMMs
1. **Supply Conservation**: A valid ERC-20 must maintain $\sum \text{balances} = \text{totalSupply}$.
2. **Return Value Discrepancies**: Real-world tokens may omit return booleans (USDT) or return `false` on failure instead of reverting. Future DEX contracts must use `SafeTokenTransfer`.
