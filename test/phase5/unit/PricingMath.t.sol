// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SagePricingLibrary} from "../../../src/phase5/libraries/SagePricingLibrary.sol";

contract PricingMathTest is Test {
    // 1. Spot Price Calculation
    function test_PricingMath_SpotPriceWad() public pure {
        // 100 ETH : 200,000 USDC -> Spot Price = 2,000 USDC / ETH
        uint256 spotPrice = SagePricingLibrary.getSpotPriceWad(100 ether, 200_000 ether);
        assertEq(spotPrice, 2000 ether);
    }

    // 2. Exact-Input vs Exact-Output Math
    function test_PricingMath_AmountOutAndInParity() public pure {
        uint256 rIn = 100 ether;
        uint256 rOut = 200_000 ether;

        uint256 aIn = 10 ether;
        uint256 aOut = SagePricingLibrary.getAmountOut(aIn, rIn, rOut);

        // Compute required input for that exact output
        uint256 requiredIn = SagePricingLibrary.getAmountIn(aOut, rIn, rOut);

        // Required input is <= original input + 1 wei due to ceiling rounding
        assertLe(requiredIn, aIn + 1);
    }

    // 3. Price Impact Calculation
    function test_PricingMath_PriceImpactCalculation() public pure {
        uint256 rIn = 100 ether;
        uint256 rOut = 200_000 ether;

        // Small trade: 0.1 ETH -> Price impact ~39 bps (30 bps fee + curve impact)
        uint256 aOutSmall = SagePricingLibrary.getAmountOut(0.1 ether, rIn, rOut);
        uint256 impactSmall = SagePricingLibrary.calculatePriceImpactBps(0.1 ether, aOutSmall, rIn, rOut);
        assertApproxEqAbs(impactSmall, 40, 10);

        // Large trade: 50 ETH (half the pool) -> Price impact ~33.5% (3350 bps)
        uint256 aOutLarge = SagePricingLibrary.getAmountOut(50 ether, rIn, rOut);
        uint256 impactLarge = SagePricingLibrary.calculatePriceImpactBps(50 ether, aOutLarge, rIn, rOut);
        assertTrue(impactLarge > 3000);
    }

    // 4. Decimal Normalization
    function test_PricingMath_DecimalNormalization() public pure {
        // 100 USDC (6 decimals: 100_000_000) -> 18 decimals WAD
        uint256 normalized = SagePricingLibrary.normalizeDecimals(100_000_000, 6, 18);
        assertEq(normalized, 100 ether);

        // 100 ether (18 decimals) -> 6 decimals
        uint256 scaledDown = SagePricingLibrary.normalizeDecimals(100 ether, 18, 6);
        assertEq(scaledDown, 100_000_000);
    }
}
