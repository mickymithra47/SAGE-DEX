// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageQuoter} from "../interfaces/ISageQuoter.sol";
import {ISageFactory, ISagePair} from "../../phase3/interfaces/ISageAMM.sol";
import {SagePricingLibrary} from "../libraries/SagePricingLibrary.sol";

/**
 * @title SageQuoter
 * @notice View-only on-chain quoter for frontends, off-chain keepers, and future routers.
 */
contract SageQuoter is ISageQuoter {
    error ZeroAddress();
    error PairNotFound();
    error InvalidSlippage();

    address public immutable factory;
    uint256 internal constant BPS = 10_000;
    uint256 internal constant WAD = 1e18;

    constructor(address _factory) {
        if (_factory == address(0)) revert ZeroAddress();
        factory = _factory;
    }

    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view override returns (QuoteResult memory quote) {
        address pair = ISageFactory(factory).getPair(tokenIn, tokenOut);
        if (pair == address(0)) revert PairNotFound();

        (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
        address token0 = ISagePair(pair).token0();
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == token0 ? (r0, r1) : (r1, r0);

        uint256 amountOut = SagePricingLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
        uint256 spotPrice = SagePricingLibrary.getSpotPriceWad(reserveIn, reserveOut);
        uint256 execPrice = (amountOut * WAD) / amountIn;
        uint256 impactBps = SagePricingLibrary.calculatePriceImpactBps(amountIn, amountOut, reserveIn, reserveOut);
        uint256 fee = (amountIn * 3) / 1000;

        quote = QuoteResult({
            amountOut: amountOut,
            spotPriceWad: spotPrice,
            executionPriceWad: execPrice,
            priceImpactBps: impactBps,
            feeAmount: fee
        });
    }

    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountOut
    ) external view override returns (uint256 amountInRequired, uint256 priceImpactBps) {
        address pair = ISageFactory(factory).getPair(tokenIn, tokenOut);
        if (pair == address(0)) revert PairNotFound();

        (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
        address token0 = ISagePair(pair).token0();
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == token0 ? (r0, r1) : (r1, r0);

        amountInRequired = SagePricingLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
        priceImpactBps = SagePricingLibrary.calculatePriceImpactBps(amountInRequired, amountOut, reserveIn, reserveOut);
    }

    function quoteExactInputMultiHop(
        uint256 amountIn,
        address[] calldata path
    ) external view override returns (uint256[] memory amounts, uint256 totalImpactBps) {
        amounts = SagePricingLibrary.getAmountsOut(factory, amountIn, path);

        // Compute composite multi-hop spot price
        uint256 compositeSpotWad = WAD;
        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = ISageFactory(factory).getPair(path[i], path[i + 1]);
            if (pair != address(0)) {
                (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
                (uint256 rIn, uint256 rOut) = path[i] == ISagePair(pair).token0() ? (r0, r1) : (r1, r0);
                uint256 hopSpot = SagePricingLibrary.getSpotPriceWad(rIn, rOut);
                compositeSpotWad = (compositeSpotWad * hopSpot) / WAD;
            }
        }

        uint256 effectiveFinalPrice = (amounts[amounts.length - 1] * WAD) / amountIn;
        if (compositeSpotWad > effectiveFinalPrice) {
            totalImpactBps = ((compositeSpotWad - effectiveFinalPrice) * BPS) / compositeSpotWad;
        }
    }

    function quoteExactOutputMultiHop(
        uint256 amountOut,
        address[] calldata path
    ) external view override returns (uint256[] memory amounts, uint256 totalImpactBps) {
        amounts = SagePricingLibrary.getAmountsIn(factory, amountOut, path);

        // Compute composite multi-hop spot price
        uint256 compositeSpotWad = WAD;
        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = ISageFactory(factory).getPair(path[i], path[i + 1]);
            if (pair != address(0)) {
                (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
                (uint256 rIn, uint256 rOut) = path[i] == ISagePair(pair).token0() ? (r0, r1) : (r1, r0);
                uint256 hopSpot = SagePricingLibrary.getSpotPriceWad(rIn, rOut);
                compositeSpotWad = (compositeSpotWad * hopSpot) / WAD;
            }
        }

        uint256 effectiveFinalPrice = (amountOut * WAD) / amounts[0];
        if (compositeSpotWad > effectiveFinalPrice) {
            totalImpactBps = ((compositeSpotWad - effectiveFinalPrice) * BPS) / compositeSpotWad;
        }
    }

    function getMinimumOutputAmount(
        uint256 amountOut,
        uint256 slippageToleranceBps
    ) external pure override returns (uint256 minAmountOut) {
        if (slippageToleranceBps > BPS) revert InvalidSlippage();
        minAmountOut = (amountOut * (BPS - slippageToleranceBps)) / BPS;
    }

    function getMaximumInputAmount(
        uint256 amountIn,
        uint256 slippageToleranceBps
    ) external pure override returns (uint256 maxAmountIn) {
        if (slippageToleranceBps > BPS) revert InvalidSlippage();
        maxAmountIn = (amountIn * (BPS + slippageToleranceBps)) / BPS;
    }
}
