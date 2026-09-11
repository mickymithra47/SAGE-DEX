// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {Math} from "../../../src/phase3/libraries/Math.sol";

contract AMMMathTest is Test {
    // CASE 1: Small Pool
    function test_Math_Case1_SmallPool() public pure {
        uint256 out = SageMath.getAmountOut(100, 1000, 1000);
        // with 0.3% fee: (100 * 997 * 1000) / (1000 * 1000 + 100 * 997) = 99700000 / 1099700 = 90
        assertEq(out, 90);
    }

    // CASE 2: Large Pool
    function test_Math_Case2_LargePool() public pure {
        uint256 rIn = 1_000_000 ether;
        uint256 rOut = 2_000_000 ether;
        uint256 out = SageMath.getAmountOut(1 ether, rIn, rOut);
        // Marginal price is 2.0; small trade output is exactly 1993998011983982051 wei
        assertEq(out, 1993998011983982051);
    }

    // CASE 3: Small Trade
    function test_Math_Case3_SmallTrade() public pure {
        uint256 out = SageMath.getAmountOut(1 wei, 1 ether, 1 ether);
        // Tiny trade output is 0 wei due to integer truncation
        assertEq(out, 0);
    }

    // CASE 4: Large Trade (High Price Impact)
    function test_Math_Case4_LargeTrade() public pure {
        uint256 rIn = 1000 ether;
        uint256 rOut = 1000 ether;
        // User swaps 1000 ether into 1000 ether pool (100% of reserveIn)
        uint256 out = SageMath.getAmountOut(1000 ether, rIn, rOut);
        // Expect ~499.24 ether (almost 50% price impact + fee)
        assertEq(out, 499248873309964947421);
    }

    // CASE 5: Repeated Trades
    function test_Math_Case5_RepeatedTrades() public pure {
        uint256 rIn = 10_000 ether;
        uint256 rOut = 10_000 ether;

        uint256 out1 = SageMath.getAmountOut(100 ether, rIn, rOut);
        rIn += 100 ether;
        rOut -= out1;

        uint256 out2 = SageMath.getAmountOut(100 ether, rIn, rOut);
        // Second trade gets strictly fewer output tokens due to price slippage
        assertTrue(out2 < out1);
    }

    // CASE 6 & 7: Liquidity Addition & Removal Proportional Math
    function test_Math_Case6_Case7_LiquidityAddAndRemove() public pure {
        uint256 quoteOut = SageMath.quote(500 ether, 1000 ether, 2000 ether);
        assertEq(quoteOut, 1000 ether); // Maintains 1:2 ratio
    }

    // CASE 8: Extreme Imbalance
    function test_Math_Case8_ExtremeImbalance() public pure {
        uint256 out = SageMath.getAmountOut(1 ether, 1 ether, 1_000_000 ether);
        assertEq(out, 499248.873309964947421131 ether);
    }

    function externalGetAmountOut(uint256 amountIn, uint256 rIn, uint256 rOut) external pure returns (uint256) {
        return SageMath.getAmountOut(amountIn, rIn, rOut);
    }

    // CASE 9: Near-Zero Reserves
    function test_Math_Case9_NearZeroReserves() public {
        vm.expectRevert(abi.encodeWithSelector(SageMath.InsufficientLiquidity.selector));
        this.externalGetAmountOut(100, 0, 1000);
    }

    // CASE 10: Large Integer Values (No Overflow)
    function test_Math_Case10_LargeIntegerValues() public pure {
        uint256 rIn = 10_000_000_000 ether;
        uint256 rOut = 20_000_000_000 ether;
        uint256 out = SageMath.getAmountOut(100_000 ether, rIn, rOut);
        assertTrue(out > 0);
    }

    // CASE 11: Rounding Boundaries
    function test_Math_Case11_RoundingBoundaries() public pure {
        uint256 amountIn = SageMath.getAmountIn(500, 1000, 1000);
        // Round up ensures invariant holds
        uint256 amountOut = SageMath.getAmountOut(amountIn, 1000, 1000);
        assertGe(amountOut, 500);
    }

    // CASE 12: Fee Boundaries (30 bps / 0.3%)
    function test_Math_Case12_FeeBoundaries() public pure {
        uint256 amountOut = SageMath.getAmountOut(1000, 1_000_000, 1_000_000);
        // Out should reflect approximately 997 units
        assertEq(amountOut, 996);
    }

    // Square Root Algorithm Validation
    function test_Math_SqrtValidation() public pure {
        assertEq(Math.sqrt(0), 0);
        assertEq(Math.sqrt(1), 1);
        assertEq(Math.sqrt(4), 2);
        assertEq(Math.sqrt(9), 3);
        assertEq(Math.sqrt(100), 10);
        assertEq(Math.sqrt(144), 12);
        assertEq(Math.sqrt(1000000000000000000), 1000000000);
    }
}
