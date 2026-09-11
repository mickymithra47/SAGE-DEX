# 04 — Exact-Output Swap Execution Mechanics

## 1. Execution Flow (Reverse Calculation, Forward Execution)
1. **Reverse Traverse**: Compute required intermediate inputs backwards from desired final output $\Delta y$:
   $$\text{amounts} = \text{SagePricingLibrary.getAmountsIn}(\text{factory}, \text{amountOut}, \text{path})$$
2. **Maximum Input Bound**: `require(amounts[0] <= amountInMax, "ExcessiveInput")`
3. **Initial Transfer**: Pull exact `amounts[0]` from `msg.sender` into `firstPair`.
4. **Forward Swap**: Execute swaps sequentially through each pair along the route, delivering exact `amountOut` to `to`.
