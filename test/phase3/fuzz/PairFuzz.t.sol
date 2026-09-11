// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {Math} from "../../../src/phase3/libraries/Math.sol";

contract PairFuzzTest is Test {
    // Fuzz Property 1: getAmountOut is always strictly less than reserveOut (liquidity exhaustion defense)
    function testFuzz_AMM_AmountOutBoundedByReserve(uint256 amountIn, uint112 reserveIn, uint112 reserveOut) public pure {
        vm.assume(reserveIn > 1000 && reserveOut > 1000);
        amountIn = bound(amountIn, 1, 1e30);

        uint256 amountOut = SageMath.getAmountOut(amountIn, reserveIn, reserveOut);
        assertLt(amountOut, reserveOut, "AmountOut must strictly never exhaust total reserveOut");
    }

    // Fuzz Property 2: getAmountIn round-trip invariance satisfies constant product
    function testFuzz_AMM_AmountInRoundTrip(uint256 amountOut, uint112 reserveIn, uint112 reserveOut) public pure {
        vm.assume(reserveIn > 10_000 && reserveOut > 10_000);
        amountOut = bound(amountOut, 1, uint256(reserveOut) / 2); // Bounded to 50% pool depth

        uint256 amountIn = SageMath.getAmountIn(amountOut, reserveIn, reserveOut);
        uint256 computedOut = SageMath.getAmountOut(amountIn, reserveIn, reserveOut);

        assertGe(computedOut, amountOut, "Calculated amountIn must satisfy requested amountOut");
    }

    // Fuzz Property 3: Integer sqrt invariance
    function testFuzz_Math_SqrtInvariance(uint256 y) public pure {
        y = bound(y, 0, type(uint128).max);
        uint256 root = Math.sqrt(y);

        assertLe(root * root, y, "root^2 must be <= y");
        if (root < type(uint128).max) {
            assertGt((root + 1) * (root + 1), y, "(root+1)^2 must be > y");
        }
    }
}
