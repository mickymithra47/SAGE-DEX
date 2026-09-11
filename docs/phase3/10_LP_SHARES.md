# 10 — LP Share Accounting & Proportional Minting

## 1. What is an LP Share?
An **LP Share** is a standard ERC-20 token minted by the `SagePair` that represents a fractional ownership claim on the underlying assets of the pool:

$$\text{User Asset Claim}_0 = \frac{\text{userShares}}{\text{totalSupply}} \cdot \text{reserve0}$$
$$\text{User Asset Claim}_1 = \frac{\text{userShares}}{\text{totalSupply}} \cdot \text{reserve1}$$

---

## 2. Subsequent Liquidity Minting Math
When depositing into an already active pool:
$$\text{liquidityMinted} = \min\left( \frac{a_0 \cdot \text{totalSupply}}{\text{reserve0}}, \frac{a_1 \cdot \text{totalSupply}}{\text{reserve1}} \right)$$

### Why the Minimum ($\min$)?
- If a user deposits tokens in a ratio different from the current reserve ratio ($\frac{a_0}{a_1} \ne \frac{\text{reserve0}}{\text{reserve1}}$), the pool issues shares based on the **lesser** ratio.
- The excess tokens of the other asset are permanently donated to existing liquidity providers, penalizing depositors who fail to match the pool's spot price ratio.
- In practice, future routers compute exact proportional amounts using `SageMath.quote()` to ensure zero excess loss.
