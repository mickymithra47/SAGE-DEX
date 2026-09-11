# 03 — Allowance Architecture, Approvals & Race Conditions

## 1. What is the Allowance Model?
The ERC-20 allowance model decouples the token owner from the transaction executor. It allows smart contracts (e.g. DEX Routers, Vaults, and Escrows) to execute token transfers on behalf of users via delegated authority.

```
USER (Token Owner)
 │
 ├── 1. approve(Router, 1000) ──> Sets allowance[Owner][Router] = 1000
 │
ROUTER (Spender)
 │
 └── 2. transferFrom(Owner, Pool, 1000) ──> Transfers tokens & decrements allowance
```

---

## 2. The Approval Front-Running Race Condition
If Alice approves Bob for 100 tokens and later decides to reduce it to 50 tokens by calling `approve(Bob, 50)`:
1. Bob observes Alice's unconfirmed transaction in the public mempool.
2. Bob front-runs Alice's transaction by submitting `transferFrom(Alice, Bob, 100)` with a higher gas tip.
3. Bob's transaction is mined first, spending 100 tokens.
4. Alice's transaction is mined next, setting Bob's allowance to 50.
5. Bob calls `transferFrom(Alice, Bob, 50)`, extracting a total of **150 tokens** instead of 50.

### Mitigations:
- **`increaseAllowance` / `decreaseAllowance`**: Adjusts the allowance relative to current state.
- **Zero-Reset Pattern**: Enforce `approve(spender, 0)` before setting a new non-zero allowance (implemented in `SafeTokenTransfer.safeApproveWithReset`).
- **EIP-2612 Permit**: Single-use cryptographic signatures with explicit nonces and deadlines.

---

## 3. Infinite Allowance Optimization
To avoid paying 2,900 gas for an `SSTORE` on every single swap, modern DeFi contracts treat `type(uint256).max` ($2^{256} - 1$) as **infinite allowance**, bypassing the allowance decrement `SSTORE`:

```solidity
if (currentAllowance != type(uint256).max) {
    require(currentAllowance >= amount, "Insufficient allowance");
    allowance[from][msg.sender] = currentAllowance - amount;
}
```
