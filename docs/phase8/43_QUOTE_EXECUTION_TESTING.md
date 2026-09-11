# 43 — Quote vs Execution Consistency Testing

## 1. Zero-Delta Verification
- Every UI swap derives `amountOutMin` strictly from the on-chain constant product formula:
  $$\text{realizedOut} \ge \text{amountOutMin} \equiv \text{frontendQuote} \cdot (1 - \text{slippage})$$
- Zero mathematical divergence between client quotes and on-chain settlements.
