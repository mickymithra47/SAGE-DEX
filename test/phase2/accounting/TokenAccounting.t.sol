// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "../../../src/phase2/interfaces/IERC20.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {Project8_AccountingLab} from "../../../src/phase2/mini_projects/Phase2MiniProjects.sol";

contract TokenAccountingTest is Test {
    ERC20Token internal token;
    Project8_AccountingLab internal lab;

    address internal user = address(0x4444);

    function setUp() public {
        token = new ERC20Token("Reserve Token", "RSV", 18, 1_000_000 ether);
        lab = new Project8_AccountingLab();

        token.transfer(user, 10_000 ether);
    }

    function test_Accounting_SwapDepositTracksInternalReserves() public {
        vm.startPrank(user);
        token.approve(address(lab), 1000 ether);
        uint256 received = lab.swapDeposit(IERC20(address(token)), 1000 ether);
        vm.stopPrank();

        assertEq(received, 1000 ether);
        assertEq(lab.internalReserves(address(token)), 1000 ether);
        assertEq(token.balanceOf(address(lab)), 1000 ether);
    }

    function test_Accounting_DirectDonationDetectedBySync() public {
        // 1. Initial deposit
        vm.startPrank(user);
        token.approve(address(lab), 1000 ether);
        lab.swapDeposit(IERC20(address(token)), 1000 ether);

        // 2. Attacker directly donates 500 ether to manipulate balance
        token.transfer(address(lab), 500 ether);
        vm.stopPrank();

        // Physical balance is now 1500, but internal reserve remains 1000!
        assertEq(token.balanceOf(address(lab)), 1500 ether);
        assertEq(lab.internalReserves(address(token)), 1000 ether);

        // 3. Protocol calls sync() to capture and reconcile excess donation
        uint256 syncedBalance = lab.sync(IERC20(address(token)));
        assertEq(syncedBalance, 1500 ether);
        assertEq(lab.internalReserves(address(token)), 1500 ether);
    }
}
