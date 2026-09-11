# 30 — Calldata Architecture & ABI Encoding Design

## 1. External Function Signatures

```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts);

function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts);
```

- Using `calldata` for `path` slices memory copying overhead and enables direct memory referencing during loop execution.
