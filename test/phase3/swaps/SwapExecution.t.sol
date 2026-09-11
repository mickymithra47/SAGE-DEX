// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {FlashSwapArbitrageur} from "../../../src/phase3/attack_lab/Phase3AttackLab.sol";

contract SwapExecutionTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal trader = address(0xCCCC);

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        // Fund initial pool liquidity (10,000 token0 and 10,000 token1)
        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 10_000 ether);
        pair.mint(address(this));

        token0.transfer(trader, 10_000 ether);
        token1.transfer(trader, 10_000 ether);
    }

    function test_Swap_Direction0To1() public {
        uint256 amount0In = 100 ether;
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        uint256 expectedOut1 = SageMath.getAmountOut(amount0In, r0, r1);

        vm.startPrank(trader);
        token0.transfer(address(pair), amount0In);
        pair.swap(0, expectedOut1, trader, new bytes(0));
        vm.stopPrank();

        assertEq(token1.balanceOf(trader), 10_000 ether + expectedOut1);
        (uint112 newR0, uint112 newR1, ) = pair.getReserves();
        assertEq(newR0, r0 + amount0In);
        assertEq(newR1, r1 - expectedOut1);
    }

    function test_Swap_Direction1To0() public {
        uint256 amount1In = 200 ether;
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        uint256 expectedOut0 = SageMath.getAmountOut(amount1In, r1, r0);

        vm.startPrank(trader);
        token1.transfer(address(pair), amount1In);
        pair.swap(expectedOut0, 0, trader, new bytes(0));
        vm.stopPrank();

        assertEq(token0.balanceOf(trader), 10_000 ether + expectedOut0);
        (uint112 newR0, uint112 newR1, ) = pair.getReserves();
        assertEq(newR0, r0 - expectedOut0);
        assertEq(newR1, r1 + amount1In);
    }

    function test_Swap_FlashSwapExecution() public {
        FlashSwapArbitrageur borrower = new FlashSwapArbitrageur();
        token0.transfer(address(borrower), 100 ether); // Provide gas/fee buffer

        uint256 flashAmount = 500 ether;
        borrower.executeFlashBorrow(pair, flashAmount, address(token0));

        assertTrue(borrower.flashSwapExecuted());
    }

    function test_Swap_RevertsOnKInvariantViolation() public {
        vm.startPrank(trader);
        // Attempt to withdraw 500 ether of token1 without transferring sufficient input tokens
        token0.transfer(address(pair), 1 wei);
        vm.expectRevert(abi.encodeWithSelector(SagePair.KInvariantViolation.selector));
        pair.swap(0, 500 ether, trader, new bytes(0));
        vm.stopPrank();
    }
}
