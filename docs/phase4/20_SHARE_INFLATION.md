# 20 — LP Share Price Inflation Vectors & Defense Proof

## 1. Inflation Attack Vector Analysis
Share inflation attacks attempt to manipulate $\frac{\text{reserve}}{\text{totalSupply}}$ so high that legitimate user deposits round down to $0$ shares:

$$\text{Shares Minted} = \left\lfloor \frac{\text{amountDeposited} \times S_{\text{total}}}{\text{reserve}} \right\rfloor = 0$$

---

## 2. Permanent Invariant Defense Proof
1. `SagePair` locks `MINIMUM_LIQUIDITY = 1000` to `address(0)` on the very first deposit.
2. Therefore, $S_{\text{total}} \ge 1000$ at all times.
3. For a victim deposit of amount $D$ to result in $0$ shares, the attacker must inflate reserves such that:
   $$\frac{D \times S_{\text{total}}}{\text{reserve}} < 1 \implies \text{reserve} > D \times S_{\text{total}} \ge 1000 \times D$$
4. The attacker must donate at least $1,000 \times$ the victim's entire deposit, making the attack economically impossible.
