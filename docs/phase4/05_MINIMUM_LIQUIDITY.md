# 05 — Permanent Minimum Liquidity & `MINIMUM_LIQUIDITY = 1000` Lock

## 1. The Minimum Liquidity Protocol
On the initial deposit into any `SagePair`:
1. Total initial shares computed: $S_{\text{initial}} = \sqrt{a_0 \cdot a_1}$.
2. Exactly **1,000 units** of LP shares are permanently minted to `address(0)`:
   $$\_mint(\text{address}(0), 1000)$$
3. The depositor receives the remaining shares:
   $$S_{\text{user}} = S_{\text{initial}} - 1000$$

---

## 2. Why Burn to `address(0)`?
- No private key exists for `address(0)`.
- The 1,000 shares can never be transferred, approved, or burned.
- Ensures `totalSupply >= 1000` for the entire lifespan of the pair, preventing `totalSupply` from ever reaching zero again after initial activation.
