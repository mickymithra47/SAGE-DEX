# 23 — Dynamic Gas Estimation & EIP-1559 Fee Modeling

## 1. Dynamic Gas Buffer
$$\text{Gas Limit} = \left\lfloor \text{estimateGas} \cdot 1.20 \right\rfloor$$

- A 20% safety margin ensures multi-hop swaps execute reliably even if storage slots transition from 0 to non-zero.
- Supports EIP-1559 `maxFeePerGas` and `maxPriorityFeePerGas`.
