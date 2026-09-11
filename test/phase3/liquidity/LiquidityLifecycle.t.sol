// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract LiquidityLifecycleTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal alice = address(0xAAAA);
    address internal bob = address(0xBBBB);

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(alice, 100_000 ether);
        token1.transfer(alice, 100_000 ether);
        token0.transfer(bob, 100_000 ether);
        token1.transfer(bob, 100_000 ether);
    }

    function test_Liquidity_InitialMintWithMinimumLiquidityLock() public {
        vm.startPrank(alice);
        token0.transfer(address(pair), 1000 ether);
        token1.transfer(address(pair), 4000 ether);

        uint256 liquidity = pair.mint(alice);
        vm.stopPrank();

        // Expected sqrt(1000 * 4000) * 1e18 - 1000 = 2000 ether - 1000
        uint256 expectedLiquidity = 2000 ether - 1000;
        assertEq(liquidity, expectedLiquidity);
        assertEq(pair.balanceOf(alice), expectedLiquidity);
        // MINIMUM_LIQUIDITY (1000 units) permanently locked at address(0)
        assertEq(pair.balanceOf(address(0)), 1000);
        assertEq(pair.totalSupply(), 2000 ether);

        (uint112 r0, uint112 r1, ) = pair.getReserves();
        assertEq(r0, 1000 ether);
        assertEq(r1, 4000 ether);
    }

    function test_Liquidity_SubsequentProportionalMint() public {
        // 1. Initial mint by Alice
        vm.startPrank(alice);
        token0.transfer(address(pair), 1000 ether);
        token1.transfer(address(pair), 1000 ether);
        pair.mint(alice);
        vm.stopPrank();

        // 2. Subsequent mint by Bob (500 token0 and 500 token1 -> 50% shares)
        vm.startPrank(bob);
        token0.transfer(address(pair), 500 ether);
        token1.transfer(address(pair), 500 ether);
        uint256 bobLiquidity = pair.mint(bob);
        vm.stopPrank();

        assertEq(bobLiquidity, 500 ether);
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        assertEq(r0, 1500 ether);
        assertEq(r1, 1500 ether);
    }

    function test_Liquidity_BurnLiquidityReturnsProportionalTokens() public {
        vm.startPrank(alice);
        token0.transfer(address(pair), 1000 ether);
        token1.transfer(address(pair), 1000 ether);
        uint256 liquidity = pair.mint(alice);

        // Transfer LP tokens to pair before burning
        pair.transfer(address(pair), liquidity);
        (uint256 amount0, uint256 amount1) = pair.burn(alice);
        vm.stopPrank();

        // Burned almost all assets except MINIMUM_LIQUIDITY locked fraction
        assertEq(amount0, 1000 ether - 1000);
        assertEq(amount1, 1000 ether - 1000);
    }
}
