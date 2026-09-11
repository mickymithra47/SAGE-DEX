# 19 — Multi-Decimal Price Normalization

## 1. Decimal Scaling Formulation
$$\text{Normalized Price}(T_0 \to T_1) = \frac{\text{reserve1} \cdot 10^{\text{decimals0}}}{\text{reserve0} \cdot 10^{\text{decimals1}}}$$

### Examples:
1. **USDC (6 decimals) : WETH (18 decimals)**:
   - Reserves: $2,000 \cdot 10^6$ USDC : $1 \cdot 10^{18}$ WETH
   - Normalized Price: $1 \text{ USDC} = 0.0005 \text{ WETH}$, $1 \text{ WETH} = 2,000 \text{ USDC}$.
2. **WBTC (8 decimals) : USDC (6 decimals)**:
   - Reserves: $1 \cdot 10^8$ WBTC : $60,000 \cdot 10^6$ USDC
   - Normalized Price: $1 \text{ WBTC} = 60,000 \text{ USDC}$.
