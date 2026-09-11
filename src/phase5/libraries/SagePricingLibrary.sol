// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageFactory, ISagePair} from "../../phase3/interfaces/ISageAMM.sol";
import {SageMath} from "../../phase3/libraries/SageMath.sol";

/**
 * @title SagePricingLibrary
 * @notice Pure mathematical library for AMM spot pricing, multi-hop route quoting,
 *         analytical price impact modeling, decimal normalization, and TWAP derivations.
 */
library SagePricingLibrary {
    error InvalidPath();
    error InsufficientInput();
    error InsufficientOutput();
    error InsufficientLiquidity();
    error ZeroAddress();
    error InvalidLookback();

    uint256 internal constant WAD = 1e18;
    uint256 internal constant BPS = 10_000;
    uint256 internal constant Q112 = 2 ** 112;

    // Calculates spot price of tokenIn in terms of tokenOut scaled by 1e18 (WAD)
    function getSpotPriceWad(uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 spotPriceWad) {
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();
        spotPriceWad = (reserveOut * WAD) / reserveIn;
    }

    // Single-hop exact-input amountOut with 0.3% fee (floor division)
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        return SageMath.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    // Single-hop exact-output amountIn with 0.3% fee (ceiling division)
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        return SageMath.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    // Multi-hop exact-input quote along an arbitrary token path
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        if (path.length < 2) revert InvalidPath();
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;

        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = ISageFactory(factory).getPair(path[i], path[i + 1]);
            if (pair == address(0)) revert InvalidPath();

            (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
            address token0 = ISagePair(pair).token0();
            (uint256 reserveIn, uint256 reserveOut) = path[i] == token0 ? (r0, r1) : (r1, r0);

            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // Multi-hop exact-output quote along an arbitrary token path (reverse traversal)
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        if (path.length < 2) revert InvalidPath();
        amounts = new uint256[](path.length);
        amounts[path.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {
            address pair = ISageFactory(factory).getPair(path[i - 1], path[i]);
            if (pair == address(0)) revert InvalidPath();

            (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
            address token0 = ISagePair(pair).token0();
            (uint256 reserveIn, uint256 reserveOut) = path[i - 1] == token0 ? (r0, r1) : (r1, r0);

            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    // Calculates analytical price impact in basis points (e.g. 150 = 1.50%)
    function calculatePriceImpactBps(
        uint256 amountIn,
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 impactBps) {
        if (amountIn == 0 || reserveIn == 0 || reserveOut == 0) return 0;

        uint256 spotPriceWad = getSpotPriceWad(reserveIn, reserveOut);
        uint256 executionPriceWad = (amountOut * WAD) / amountIn;

        if (spotPriceWad > executionPriceWad) {
            impactBps = ((spotPriceWad - executionPriceWad) * BPS) / spotPriceWad;
        } else {
            impactBps = 0;
        }
    }

    // Normalizes token amounts across mismatched decimal scales (e.g. 6 decimals USDC <-> 18 decimals WETH)
    function normalizeDecimals(
        uint256 amount,
        uint8 fromDecimals,
        uint8 toDecimals
    ) internal pure returns (uint256 normalizedAmount) {
        if (fromDecimals == toDecimals) return amount;
        if (fromDecimals < toDecimals) {
            normalizedAmount = amount * (10 ** (toDecimals - fromDecimals));
        } else {
            normalizedAmount = amount / (10 ** (fromDecimals - toDecimals));
        }
    }

    // Computes TWAP price in 18-decimal WAD from cumulative price observations in Q112x112
    function computeTWAP(
        uint256 cumulativeStart,
        uint256 cumulativeEnd,
        uint32 timeElapsed
    ) internal pure returns (uint256 twapPriceWad) {
        if (timeElapsed == 0) revert InvalidLookback();
        // Unchecked subtraction handles standard uint256 modulo overflow in cumulative accumulators
        unchecked {
            uint256 deltaCumulative = cumulativeEnd - cumulativeStart;
            // deltaCumulative / timeElapsed = avg price in Q112x112
            // Multiply by 1e18 and divide by 2^112
            twapPriceWad = (deltaCumulative * WAD) / (timeElapsed * Q112);
        }
    }
}
