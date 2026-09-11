# 07 — Smart Contract Security Foundation & Vulnerability Taxonomy

## 1. The Protocol Security Paradigm
In decentralized protocol engineering, code is immutable and sovereign. Unlike traditional web applications where bugs can be patched behind a server without immediate loss, smart contract vulnerabilities result in instant, irreversible economic drain.

---

## 2. Core Vulnerability Taxonomy & Defenses

```
┌───────────────────────────────────┬───────────────────────────────────┬──────────────────────────────────┐
│ Vulnerability                     │ Exploit Mechanism                 │ Production Defense               │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 1. Reentrancy                     │ External call before state update │ Checks-Effects-Interactions (CEI)│
│                                   │ allows recursive re-entry.        │ + ReentrancyGuard mutex lock.    │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 2. Broken Access Control          │ Missing modifier or open init     │ 2-Step Ownership transfer &      │
│                                   │ function allows takeover.         │ strict access modifiers.         │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 3. tx.origin Authentication       │ Phishing contract tricks owner    │ Always authenticate via          │
│                                   │ into executing malicious tx.      │ `msg.sender`, NEVER `tx.origin`. │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 4. Unchecked Low-Level Calls      │ Ignored boolean return value      │ Check `require(success)` and     │
│                                   │ assumes transfer succeeded.       │ bubble up revert data.           │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 5. Arbitrary Delegatecall         │ Delegatecall into attacker code   │ Never allow user-supplied        │
│                                   │ overwrites proxy storage slots.   │ delegatecall targets.            │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 6. Division Before Multiplication │ Integer truncation zeros out      │ Multiply first, divide last.     │
│                                   │ intermediate values/fees.         │ Specify rounding direction.      │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 7. Push Payment Denial of Service │ Reverting recipient in push loop  │ Pull-Over-Push pattern: credit   │
│                                   │ permanently blocks state updates. │ balances, allow users to pull.   │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 8. State Inconsistency in Callback│ Contract state modified during    │ NonReentrant locks + balance     │
│                                   │ untrusted external hook.          │ delta invariant verification.    │
├───────────────────────────────────┼───────────────────────────────────┼──────────────────────────────────┤
│ 9. Weird Token Incompatibilities  │ Fee-on-transfer, rebasing, or     │ Balance-delta measurement +      │
│                                   │ missing return booleans (USDT).   │ SafeERC20 low-level wrapper.     │
└───────────────────────────────────┴───────────────────────────────────┴──────────────────────────────────┘
```

---

## 3. Deep Dive: Checks-Effects-Interactions (CEI)

The CEI pattern is the single most critical structural discipline in smart contract development:

```solidity
function withdraw(uint256 amount) external nonReentrant {
    // 1. CHECKS (Validate inputs, balances, and permissions)
    if (balances[msg.sender] < amount) revert InsufficientBalance();

    // 2. EFFECTS (Update internal accounting and storage FIRST)
    balances[msg.sender] -= amount;

    // 3. INTERACTIONS (Perform external calls / token transfers LAST)
    (bool success, ) = msg.sender.call{value: amount}("");
    if (!success) revert TransferFailed();
}
```

---

## 4. Arithmetic Precision & Rounding Direction

In EVM integer arithmetic, every division that is not evenly divisible truncates towards zero:

$$\lfloor \frac{a \times b}{c} \rfloor$$

### Rule of Rounding Direction in DeFi:
- **When user deposits / buys**: Round **UP** in favor of protocol reserves (or round down on minted shares).
- **When user withdraws / sells**: Round **DOWN** on returned assets.
- **Solvency Invariant**: The protocol must never distribute more tokens than it physically holds in reserves.

---

## 5. Non-Standard "Weird" Token Handling
Standard ERC-20 assumes `transfer` returns a boolean and that `balanceOf(to)` increases by exactly `amount`. In reality:
1. **Fee-on-Transfer Tokens**: Take a percentage fee during transfer.
   - *Fix*: Measure `balanceAfter - balanceBefore`.
2. **Missing Return Tokens (e.g. USDT)**: Do not return a `bool`, causing standard Solidity interfaces to revert.
   - *Fix*: Use assembly to check `returndatasize() == 0 || abi.decode(returndata, (bool))`.
3. **Rebasing Tokens**: Balances change dynamically over time.
   - *Fix*: Track internal fractional shares, not raw token balances.
