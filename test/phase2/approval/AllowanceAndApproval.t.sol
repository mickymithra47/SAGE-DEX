// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {Project2_AllowanceERC20} from "../../../src/phase2/mini_projects/Phase2MiniProjects.sol";

contract AllowanceAndApprovalTest is Test {
    ERC20Token internal token;
    Project2_AllowanceERC20 internal allowanceToken;

    address internal alice = address(0x1111);
    address internal spender = address(0x2222);
    address internal bob = address(0x3333);

    function setUp() public {
        token = new ERC20Token("Test Token", "TEST", 18, 1_000_000 ether);
        allowanceToken = new Project2_AllowanceERC20(1_000_000 ether);

        token.transfer(alice, 10_000 ether);
        allowanceToken.transfer(alice, 10_000 ether);
    }

    function test_Approval_InfiniteAllowanceDoesNotDecrement() public {
        vm.prank(alice);
        allowanceToken.approve(spender, type(uint256).max);

        vm.prank(spender);
        allowanceToken.transferFrom(alice, bob, 500 ether);

        // Infinite allowance remains unchanged (avoids warm/cold SSTORE gas)
        assertEq(allowanceToken.allowance(alice, spender), type(uint256).max);
        assertEq(allowanceToken.balanceOf(bob), 500 ether);
    }

    function test_Approval_IncreaseAndDecreaseAllowance() public {
        vm.startPrank(alice);
        token.approve(spender, 500 ether);
        assertEq(token.allowance(alice, spender), 500 ether);

        token.increaseAllowance(spender, 200 ether);
        assertEq(token.allowance(alice, spender), 700 ether);

        token.decreaseAllowance(spender, 300 ether);
        assertEq(token.allowance(alice, spender), 400 ether);
        vm.stopPrank();
    }

    function test_Approval_RevertsOnDecreasingBeyondCurrentAllowance() public {
        vm.prank(alice);
        token.approve(spender, 100 ether);

        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20Token.InsufficientAllowance.selector, spender, 100 ether, 200 ether)
        );
        token.decreaseAllowance(spender, 200 ether);
    }
}
