# 04 — Trading Fee Architecture & Yield Accumulation

## 1. The 0.3% (30 bps) Fee Architecture
Every swap executed against an Sage AMM pool incurs an immutable **30 basis point (0.3%)** fee:

$$\text{Fee Amount} = \frac{3 \cdot \Delta x}{1000}$$
$$\text{Net Input} = \frac{997 \cdot \Delta x}{1000}$$

---

## 2. How Liquidity Providers (LPs) Earn Fees
Unlike centralized exchanges that transfer fee tokens to a separate treasury address on every trade:
1. The entire fee remains inside the pool's physical reserve balances ($x$ and $y$).
2. As trades occur, the pool's invariant $k = x \cdot y$ strictly increases monotonically.
3. Because the total circulating LP share supply remains unchanged, the underlying asset backing per LP share ($\frac{\text{reserve}}{\text{totalShares}}$) continuously appreciates.
4. LPs realize their accumulated fee yield upon calling `burn()` to withdraw their proportional reserves.

---

## 3. Protocol Fee Switch (Conceptual Architecture)
If enabled via `feeToSetter`:
- A fraction of the 30 bps fee (e.g. 1/6th of growth $= 0.05\%$) can be minted to the `feeTo` address as newly minted LP shares upon liquidity operations, without imposing runtime gas overhead on individual swaps.
