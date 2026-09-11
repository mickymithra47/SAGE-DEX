# 18 — Direct Transfer Attacks & Adversarial Scenarios

## 1. Direct Transfer Before Deposit
- **Attack**: Attacker transfers $1,000$ Token0 to the pair before calling `pair.mint()`.
- **Outcome**: The pair measures deposited amount as $\text{balance0} - \text{reserve0}$, treating the transfer as part of the caller's deposit. No funds are trapped or lost.

---

## 2. Direct Transfer Before Swap
- **Attack**: Attacker donates $1,000$ Token0 directly, then calls `pair.swap()`.
- **Outcome**: The swap checks inputs relative to `reserve0`. The $1,000$ excess does not artificially discount swap prices.

---

## 3. Direct Transfer Before Burn
- **Attack**: Attacker donates tokens and burns LP shares.
- **Outcome**: Proportional redemption distributes the donated tokens proportionally to the burned shares, with zero arithmetic errors.
