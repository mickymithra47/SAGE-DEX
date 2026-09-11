# 12 — Security Laboratory: Exploits & Defensive Engineering

## Overview

The Security Laboratory in `src/06_security_lab/` and `test/security/SecurityLab.t.sol` implements 9 real-world DeFi vulnerability scenarios. Each scenario contains:
1. **Vulnerable Contract**: Intentionally flawed implementation.
2. **Attacker Contract**: Exploit contract that extracts funds or corrupts state.
3. **Automated Exploit Test**: Forge test proving the exploit succeeds against the flawed contract.
4. **Hardened Contract**: Production-grade implementation mitigating the vulnerability.
5. **Defensive Verification**: Forge test proving the exploit fails against the hardened contract.

---

## The 9 Security Scenarios

### Scenario 1: Reentrancy
- **Vulnerability**: `VulnerableBank.withdraw()` transfers ETH *before* updating `balances[msg.sender] = 0`.
- **Exploit**: `ReentrancyAttacker` intercepts the transfer in `receive()` and recursively calls `withdraw()`, draining the bank.
- **Defense**: `SecureBank` implements Checks-Effects-Interactions (sets balance to 0 before the external call) + a `nonReentrant` mutex.

### Scenario 2: Broken Access Control
- **Vulnerability**: `VulnerableOwner.setProtocolFee()` lacks any modifier, allowing arbitrary callers to modify protocol fees.
- **Exploit**: Attacker calls `setProtocolFee(5000)` and `transferOwnership(attacker)`.
- **Defense**: `SecureOwner` enforces `onlyOwner` modifier and a 2-step ownership transfer (`transferOwnership` + `acceptOwnership`).

### Scenario 3: tx.origin Phishing
- **Vulnerability**: `VulnerableTxOriginWallet` authorizes withdrawals using `require(tx.origin == owner)`.
- **Exploit**: Owner is tricked into interacting with `TxOriginAttacker` (e.g. minting an NFT), which drains the wallet because `tx.origin` is the owner.
- **Defense**: `SecureTxOriginWallet` strictly checks `msg.sender == owner`.

### Scenario 4: Unchecked Low-Level Calls
- **Vulnerability**: `VulnerablePayer` invokes `recipient.call{value: amount}("")` without inspecting the boolean return value.
- **Exploit**: If recipient contract reverts in `receive()`, `VulnerablePayer` resets user balance to 0 and marks payout as completed while recipient received nothing.
- **Defense**: `SecurePayer` checks `require(success, "Transfer failed")` and reverts if the transfer fails.

### Scenario 5: Arbitrary Delegatecall Storage Hijacking
- **Vulnerability**: `VulnerableProxy` exposes `execute(address target, bytes calldata data)` executing `delegatecall` on untrusted targets.
- **Exploit**: `DelegatecallAttacker` executes `sstore(0, caller())`, directly overwriting Slot 0 (the proxy owner slot).
- **Defense**: `SecureProxy` locks delegatecall execution exclusively to verified implementation contracts.

### Scenario 6: Division Before Multiplication Precision Loss
- **Vulnerability**: `VulnerableFeeCalculator` calculates `fee = (amount / 10000) * feeBps`. If `amount < 10000`, division truncates to 0.
- **Exploit**: User executes trades with amounts $< 10,000$ wei, paying 0 protocol fees.
- **Defense**: `SecureFeeCalculator` multiplies first: `(amount * feeBps) / 10000` with explicit rounding up option.

### Scenario 7: Push Payment Denial of Service (DoS)
- **Vulnerability**: `VulnerableAuction.bid()` pushes ETH refunds directly to the previous highest bidder.
- **Exploit**: `DosAttacker` bids and reverts on incoming ETH in `receive()`, permanently freezing the auction against higher bids.
- **Defense**: `SecurePullAuction` implements the **Pull-Over-Push** pattern, crediting `pendingRefunds` and allowing users to pull refunds asynchronously.

### Scenario 8: State Inconsistency During Callback
- **Vulnerability**: `VulnerableCallbackReceiver` invokes an external receiver before updating user balances.
- **Exploit**: Receiver re-enters or queries stale balance states during callback execution.
- **Defense**: `SecureCallbackReceiver` enforces CEI state updates prior to callback execution + non-reentrancy locks.

### Scenario 9: Non-Standard "Weird" Token Incompatibilities
- **Vulnerability**: `naiveDeposit()` assumes transferred amount equals credited amount, failing for fee-on-transfer tokens.
- **Exploit**: Token takes 10% transfer tax; contract credits 100% to user, leading to vault insolvency.
- **Defense**: `WeirdTokenHandler` measures actual balance deltas (`balanceAfter - balanceBefore`) and uses low-level assembly to support non-standard tokens like USDT.
