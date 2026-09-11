# 05 — Slippage Enforcement During Execution

## 1. Slippage Verification Invariant
- **Exact Input**:
  $$\text{amounts}[\text{last}] \ge \text{amountOutMin}$$
  If the reserves moved prior to transaction execution and the realized output is even 1 wei below `amountOutMin`, the router reverts with `InsufficientOutput()`.

- **Exact Output**:
  $$\text{amounts}[0] \le \text{amountInMax}$$
  If the required input exceeds `amountInMax`, the router reverts with `ExcessiveInput()`.
