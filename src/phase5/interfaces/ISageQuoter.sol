// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title ISageQuoter
 * @notice View-only interface for computing exact-input and exact-output trade quotes,
 *         multi-hop amounts, price impact, and minimum outputs under slippage.
 */
interface ISageQuoter {
    struct QuoteResult {
        uint256 amountOut;
        uint256 spotPriceWad;
        uint256 executionPriceWad;
        uint256 priceImpactBps;
        uint256 feeAmount;
    }

    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (QuoteResult memory quote);

    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountOut
    ) external view returns (uint256 amountInRequired, uint256 priceImpactBps);

    function quoteExactInputMultiHop(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts, uint256 totalImpactBps);

    function quoteExactOutputMultiHop(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts, uint256 totalImpactBps);

    function getMinimumOutputAmount(
        uint256 amountOut,
        uint256 slippageToleranceBps
    ) external pure returns (uint256 minAmountOut);

    function getMaximumInputAmount(
        uint256 amountIn,
        uint256 slippageToleranceBps
    ) external pure returns (uint256 maxAmountIn);
}
