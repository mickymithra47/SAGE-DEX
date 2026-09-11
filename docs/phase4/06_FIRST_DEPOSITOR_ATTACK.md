# 06 — First Depositor Inflation Attack: Mathematical Anatomy & Defense

## 1. The Exploit Mechanics (Vulnerable AMM)
In a pool without a minimum liquidity burn:
1. Attacker deposits $1$ wei of Token0 and $1$ wei of Token1. Receives $S = \sqrt{1 \times 1} = 1$ share.
2. Attacker transfers $1,000,000$ Token0 directly to the pool contract.
   - Total supply $= 1$ share.
   - Reserves $= 1,000,001$ Token0.
   - Price per share $= 1,000,001$ tokens.
3. Victim attempts to deposit $500,000$ Token0 and $500,000$ Token1.
4. Shares minted to victim:
   $$S_{\text{victim}} = \left\lfloor \frac{500,000 \times 1}{1,000,001} \right\rfloor = 0 \text{ shares!}$$
5. The transaction succeeds (or victim gets 0 shares), and the attacker burns their 1 share to steal the victim's entire $500,000$ deposit.

---

## 2. The Sage Defense Proof
With $1,000$ shares permanently locked:
- The initial total supply is at least $1,000$.
- To inflate the share price such that a victim's deposit truncates to $0$, the attacker must donate at least $1000 \times \text{victim deposit}$.
- For a $500,000$ deposit, the attacker must donate $\$500,000,000$, making the attack economically suicidal.
