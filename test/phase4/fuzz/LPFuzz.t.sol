// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {LPPositionMath} from "../../../src/phase4/libraries/LPPositionMath.sol";

contract LPFuzzTest is Test {
    // Fuzz Property 1: Proportional redemption never returns more than total reserves
    function testFuzz_LP_RedemptionBoundedByReserves(
        uint256 shares,
        uint112 reserve0,
        uint112 reserve1,
        uint112 totalSupply
    ) public pure {
        vm.assume(reserve0 > 1000 && reserve1 > 1000 && totalSupply > 1000);
        shares = bound(shares, 1, totalSupply);

        (uint256 a0, uint256 a1) = LPPositionMath.calculateRedemption(shares, reserve0, reserve1, totalSupply);

        assertLe(a0, reserve0, "Redemption amount0 must not exceed total reserve0");
        assertLe(a1, reserve1, "Redemption amount1 must not exceed total reserve1");
    }

    // Fuzz Property 2: Additional liquidity minted is monotonic with deposited amounts
    function testFuzz_LP_AdditionalLiquidityMonotonic(
        uint256 amount0,
        uint256 amount1,
        uint112 reserve0,
        uint112 reserve1,
        uint112 totalSupply
    ) public pure {
        vm.assume(reserve0 > 1000 && reserve1 > 1000 && totalSupply > 1000);
        amount0 = bound(amount0, 1 ether, 100_000 ether);
        amount1 = bound(amount1, 1 ether, 100_000 ether);

        uint256 shares1 = LPPositionMath.calculateAdditionalLiquidity(amount0, amount1, reserve0, reserve1, totalSupply);
        uint256 shares2 = LPPositionMath.calculateAdditionalLiquidity(amount0 * 2, amount1 * 2, reserve0, reserve1, totalSupply);

        if (shares1 > 0) {
            assertGe(shares2, shares1 * 2 - 1, "Doubling deposit must yield at least double shares");
        } else {
            assertGe(shares2, 0);
        }
    }

    // Fuzz Property 3: Ownership BPS is strictly <= 10,000 (100.00%)
    function testFuzz_LP_OwnershipBpsBounded(uint256 userShares, uint256 totalShares) public pure {
        vm.assume(totalShares > 0);
        userShares = bound(userShares, 0, totalShares);

        uint256 bps = LPPositionMath.calculateOwnershipBps(userShares, totalShares);
        assertLe(bps, 10_000, "Ownership basis points must not exceed 10,000");
    }
}
