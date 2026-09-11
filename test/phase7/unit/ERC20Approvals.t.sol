// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract ERC20ApprovalsTest is Test {
    ERC20Token internal token;
    address internal alice = address(0xA11CE);
    address internal spender = address(0xB0B);

    function setUp() public {
        token = new ERC20Token("Token A", "TKNA", 18, 1_000_000 ether);
        token.transfer(alice, 10_000 ether);
    }

    function test_Approvals_ExactAmount() public {
        vm.prank(alice);
        token.approve(spender, 500 ether);

        assertEq(token.allowance(alice, spender), 500 ether);

        vm.prank(spender);
        token.transferFrom(alice, spender, 500 ether);

        assertEq(token.balanceOf(spender), 500 ether);
        assertEq(token.allowance(alice, spender), 0, "Allowance should be fully consumed");
    }

    function test_Approvals_Revocation() public {
        vm.prank(alice);
        token.approve(spender, 500 ether);

        // Alice revokes allowance to 0
        vm.prank(alice);
        token.approve(spender, 0);

        assertEq(token.allowance(alice, spender), 0);

        vm.prank(spender);
        vm.expectRevert();
        token.transferFrom(alice, spender, 1 ether);
    }
}
