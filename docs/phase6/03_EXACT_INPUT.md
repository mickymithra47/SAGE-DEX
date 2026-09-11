# 03 — Exact-Input Swap Execution Mechanics

## 1. Single-Hop & Multi-Hop Exact-Input Execution Flow
1. **Deadline Check**: `require(block.timestamp <= deadline, "Expired")`
2. **Quote Computation**: `amounts = SagePricingLibrary.getAmountsOut(factory, amountIn, path)`
3. **Slippage Check**: `require(amounts[last] >= amountOutMin, "InsufficientOutput")`
4. **Initial Token Transfer**: `SafeTokenTransfer.safeTransferFrom(path[0], msg.sender, firstPair, amounts[0])`
5. **Chained Swap Calls**:
   - For hop $i < \text{path.length} - 2$, destination is the next pool `Pair(path[i+1], path[i+2])`.
   - For final hop, destination is the user's `to` recipient address.
