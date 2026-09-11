// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract RouterNativeETHTest is Test {
    SageFactory internal factory;
    SageRouter internal router;
    WETH internal weth;

    ERC20Token internal tokenA;
    SagePair internal pairEthA;

    address internal alice = address(0xA11CE);

    function setUp() public {
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);

        pairEthA = SagePair(factory.createPair(address(weth), address(tokenA)));

        // Seed 100 WETH : 200,000 Token A
        weth.deposit{value: 100 ether}();
        weth.transfer(address(pairEthA), 100 ether);
        tokenA.transfer(address(pairEthA), 200_000 ether);
        pairEthA.mint(address(this));

        vm.deal(alice, 50 ether);
    }

    function test_Router_SwapExactETHForTokens() public {
        vm.startPrank(alice);

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(tokenA);

        uint256 balABefore = tokenA.balanceOf(alice);
        uint256[] memory amounts = router.swapExactETHForTokens{value: 1 ether}(
            1900 ether, // min out
            path,
            alice,
            block.timestamp + 300
        );
        vm.stopPrank();

        assertTrue(amounts[1] >= 1900 ether);
        assertEq(tokenA.balanceOf(alice) - balABefore, amounts[1]);
        assertEq(address(router).balance, 0, "Zero trapped ETH in router");
    }

    function test_Router_SwapExactTokensForETH() public {
        tokenA.transfer(alice, 5000 ether);

        vm.startPrank(alice);
        tokenA.approve(address(router), 5000 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(weth);

        uint256 ethBalBefore = alice.balance;
        uint256[] memory amounts = router.swapExactTokensForETH(
            2000 ether,
            0.9 ether, // min ETH out
            path,
            alice,
            block.timestamp + 300
        );
        vm.stopPrank();

        assertTrue(amounts[1] >= 0.9 ether);
        assertEq(alice.balance - ethBalBefore, amounts[1]);
        assertEq(address(router).balance, 0);
    }

    function test_Router_SwapETHForExactTokensWithRefund() public {
        vm.startPrank(alice);

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(tokenA);

        uint256 ethBalBefore = alice.balance;
        uint256 desiredTokenOut = 1900 ether;

        // Alice sends 2.0 ETH but only ~1.0 ETH is needed
        uint256[] memory amounts = router.swapETHForExactTokens{value: 2 ether}(
            desiredTokenOut,
            path,
            alice,
            block.timestamp + 300
        );
        vm.stopPrank();

        assertEq(amounts[1], desiredTokenOut);
        assertTrue(amounts[0] < 2 ether);
        // Alice should have paid amounts[0] ETH (2 ETH - (2 ETH - amounts[0]) refund)
        assertEq(ethBalBefore - alice.balance, amounts[0]);
        assertEq(address(router).balance, 0, "Zero trapped ETH");
    }
}
