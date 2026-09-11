// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";
import {RevertingETHRecipient} from "../../../src/phase6/attack_lab/Phase6AttackLab.sol";

contract RouterAttackLabTest is Test {
    SageFactory internal factory;
    SageRouter internal router;
    WETH internal weth;

    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    SagePair internal pairAB;
    SagePair internal pairEthA;

    address internal alice = address(0xA11CE);

    function setUp() public {
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        pairAB = SagePair(factory.createPair(address(tokenA), address(tokenB)));
        pairEthA = SagePair(factory.createPair(address(weth), address(tokenA)));

        tokenA.transfer(address(pairAB), 10_000 ether);
        tokenB.transfer(address(pairAB), 20_000 ether);
        pairAB.mint(address(this));

        weth.deposit{value: 100 ether}();
        weth.transfer(address(pairEthA), 100 ether);
        tokenA.transfer(address(pairEthA), 200_000 ether);
        pairEthA.mint(address(this));

        tokenA.transfer(alice, 1000 ether);
    }

    // ATTACK 1: EXPIRED DEADLINE SWAP REJECTION
    function test_Attack1_ExpiredDeadlineReverts() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), 100 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        // Block timestamp is 1000; deadline is 999 (expired)
        vm.warp(1000);
        vm.expectRevert(SageRouter.Expired.selector);
        router.swapExactTokensForTokens(10 ether, 1 ether, path, alice, 999);
        vm.stopPrank();
    }

    // ATTACK 2: SLIPPAGE BREACH REJECTION
    function test_Attack2_SlippageBreachReverts() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), 100 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        // Expect 100 tokenB out (impossible, max pool can give for 10 tokenA is ~19.96 tokenB)
        vm.expectRevert(SageRouter.InsufficientOutput.selector);
        router.swapExactTokensForTokens(10 ether, 100 ether, path, alice, block.timestamp + 300);
        vm.stopPrank();
    }

    // ATTACK 8: REVERTING ETH RECIPIENT REVERTS ATOMICALLY
    function test_Attack8_RevertingETHRecipientReverts() public {
        RevertingETHRecipient reverter = new RevertingETHRecipient();
        tokenA.transfer(address(reverter), 1000 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(weth);

        vm.prank(address(reverter));
        tokenA.approve(address(router), 1000 ether);

        vm.expectRevert(SageRouter.TransferFailed.selector);
        reverter.attemptSwapExactTokensForETH(router, 1000 ether, 0.1 ether, path);
    }

    // ATTACK 10: ZERO RECIPIENT REJECTION
    function test_Attack10_ZeroRecipientReverts() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), 100 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        vm.expectRevert(SageRouter.InvalidRecipient.selector);
        router.swapExactTokensForTokens(10 ether, 1 ether, path, address(0), block.timestamp + 300);
        vm.stopPrank();
    }
}
