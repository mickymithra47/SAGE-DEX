# 15 — Native ETH Excess Refunds & Safety

## 1. Refund Formulation in Exact-Output Swaps
When calling `swapETHForExactTokens`:
- User deposits `msg.value`.
- Required WETH is `amounts[0]`.
- If `msg.value > amounts[0]`:
  $$\text{Refund Amount} = \text{msg.value} - \text{amounts}[0]$$
  Transferred back to `msg.sender` via low-level `.call{value: refund}("")`.
- If refund fails, transaction reverts cleanly with `TransferFailed()`.
