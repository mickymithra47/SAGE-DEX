// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SagePricingLibrary} from "../../../src/phase5/libraries/SagePricingLibrary.sol";

contract PricingFuzzTest is Test {
    // Fuzz Property 1: getAmountOut is strictly < reserveOut
    function testFuzz_Pricing_AmountOutBounded(uint256 amountIn, uint112 reserveIn, uint112 reserveOut) public pure {
        vm.assume(reserveIn > 1000 && reserveOut > 1000);
        amountIn = bound(amountIn, 1, type(uint112).max);

        uint256 amountOut = SagePricingLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
        assertLt(amountOut, reserveOut, "AmountOut must be strictly less than reserveOut");
    }

    // Fuzz Property 2: Price impact is strictly <= 10,000 BPS (100.00%)
    function testFuzz_Pricing_PriceImpactBounded(uint256 amountIn, uint112 reserveIn, uint112 reserveOut) public pure {
        vm.assume(reserveIn > 1000 && reserveOut > 1000);
        amountIn = bound(amountIn, 1, 100_000 ether);

        uint256 amountOut = SagePricingLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
        uint256 impact = SagePricingLibrary.calculatePriceImpactBps(amountIn, amountOut, reserveIn, reserveOut);
        assertLe(impact, 10_000, "Price impact must not exceed 10,000 basis points");
    }
}
