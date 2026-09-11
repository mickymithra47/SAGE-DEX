# 25 — Router Integration & Atomic Signature Verification

## 1. Clean Architectural Extension
`SagePermitRouter` inherits directly from `SageRouter` without duplicating swap logic:

```solidity
function swapExactTokensForTokensWithPermit(...) external returns (uint256[] memory amounts) {
    IERC20Permit(path[0]).permit(msg.sender, address(this), amountIn, deadline, v, r, s);
    amounts = swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
}
```

- All Phase 6 protections (`ensure(deadline)`, `amountOutMin`, direct pool-to-pool forwarding) are preserved intact.
