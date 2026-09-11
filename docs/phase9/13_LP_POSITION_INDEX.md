# 13 — Reconstructed LP Position Accounting

## 1. Share Fraction & Valuation Formula
$$\text{Share Fraction} = \frac{\text{lpBalance}}{\text{totalLPSupply}}$$
$$\text{Estimated Underlying Token 0} = \left\lfloor \frac{\text{lpBalance} \cdot \text{reserve0}}{\text{totalLPSupply}} \right\rfloor$$
$$\text{Estimated Underlying Token 1} = \left\lfloor \frac{\text{lpBalance} \cdot \text{reserve1}}{\text{totalLPSupply}} \right\rfloor$$

- Reconstructs exact user equity across all liquidity pools.
