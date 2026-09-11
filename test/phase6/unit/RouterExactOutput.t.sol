// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract RouterExactOutputTest is Test {
    SageFactory internal factory;
    SageRouter internal router;
    WETH internal weth;

    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    ERC20Token internal tokenC;

    SagePair internal pairAB;
    SagePair internal pairBC;

    address internal alice = address(0xA11CE);

    function setUp() public {
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);
        tokenC = new ERC20Token("Token C", "TKNC", 18, 10_000_000 ether);

        pairAB = SagePair(factory.createPair(address(tokenA), address(tokenB)));
        pairBC = SagePair(factory.createPair(address(tokenB), address(tokenC)));

        // Seed Pool A/B: 10,000 A : 20,000 B
        tokenA.transfer(address(pairAB), 10_000 ether);
        tokenB.transfer(address(pairAB), 20_000 ether);
        pairAB.mint(address(this));

        // Seed Pool B/C: 20,000 B : 40,000 C
        tokenB.transfer(address(pairBC), 20_000 ether);
        tokenC.transfer(address(pairBC), 40_000 ether);
        pairBC.mint(address(this));

        tokenA.transfer(alice, 1_000 ether);
    }

    function test_Router_SingleHopExactOutput() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), 100 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        uint256 desiredOut = 19 ether;
        uint256 maxIn = 15 ether;

        uint256 balBBefore = tokenB.balanceOf(alice);
        uint256[] memory amounts = router.swapTokensForExactTokens(
            desiredOut,
            maxIn,
            path,
            alice,
            block.timestamp + 300
        );
        vm.stopPrank();

        assertEq(amounts[1], desiredOut);
        assertLe(amounts[0], maxIn);
        assertEq(tokenB.balanceOf(alice) - balBBefore, desiredOut);
        assertEq(tokenA.balanceOf(address(router)), 0);
    }

    function test_Router_MultiHopExactOutput() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), 100 ether);

        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);

        uint256 desiredOut = 35 ether;
        uint256 maxIn = 20 ether;

        uint256 balCBefore = tokenC.balanceOf(alice);
        uint256[] memory amounts = router.swapTokensForExactTokens(
            desiredOut,
            maxIn,
            path,
            alice,
            block.timestamp + 300
        );
        vm.stopPrank();

        assertEq(amounts.length, 3);
        assertEq(amounts[2], desiredOut);
        assertLe(amounts[0], maxIn);
        assertEq(tokenC.balanceOf(alice) - balCBefore, desiredOut);
        assertEq(tokenA.balanceOf(address(router)), 0);
    }
}
