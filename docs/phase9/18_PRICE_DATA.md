# 18 — Historical Price Engine & Spot Rate Derivation

## 1. Spot Price Derivation
$$\text{Price of Token 0 in Token 1} = \frac{\text{reserve1}}{\text{reserve0}}$$
$$\text{Price of Token 1 in Token 0} = \frac{\text{reserve0}}{\text{reserve1}}$$

- Price source: On-chain reserve ratio at the block of execution.
- Recorded at every `Sync` and `Swap` event.
