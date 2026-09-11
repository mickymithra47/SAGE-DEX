// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract WETHHandler is Test {
    WETH public immutable weth;
    address[] public actors;

    uint256 public totalDepositedETH;
    uint256 public totalWithdrawnETH;

    constructor(WETH _weth) {
        weth = _weth;

        actors.push(address(0x101));
        actors.push(address(0x102));
        actors.push(address(0x103));

        for (uint256 i = 0; i < actors.length; i++) {
            vm.deal(actors[i], 1_000 ether);
        }
    }

    function deposit(uint256 actorIndex, uint256 amount) external {
        actorIndex = actorIndex % actors.length;
        address actor = actors[actorIndex];
        amount = bound(amount, 1 wei, 100 ether);

        vm.prank(actor);
        weth.deposit{value: amount}();
        totalDepositedETH += amount;
    }

    function withdraw(uint256 actorIndex, uint256 fraction) external {
        actorIndex = actorIndex % actors.length;
        address actor = actors[actorIndex];

        uint256 bal = weth.balanceOf(actor);
        if (bal == 0) return;

        fraction = bound(fraction, 1, 100);
        uint256 amountToWithdraw = (bal * fraction) / 100;
        if (amountToWithdraw == 0) return;

        vm.prank(actor);
        weth.withdraw(amountToWithdraw);
        totalWithdrawnETH += amountToWithdraw;
    }
}

contract WETHInvariantTest is Test {
    WETH internal weth;
    WETHHandler internal handler;

    function setUp() public {
        weth = new WETH();
        handler = new WETHHandler(weth);

        targetContract(address(handler));
    }

    // Invariant 1: WETH contract ETH balance must strictly equal WETH totalSupply (1:1 backing)
    function invariant_WETHSolvency() public view {
        assertEq(
            address(weth).balance,
            weth.totalSupply(),
            "INVARIANT VIOLATION: WETH physical ETH balance must strictly equal totalSupply"
        );
    }

    // Invariant 2: Total withdrawn ETH cannot exceed total deposited ETH
    function invariant_DepositConservation() public view {
        assertLe(
            handler.totalWithdrawnETH(),
            handler.totalDepositedETH(),
            "INVARIANT VIOLATION: Total withdrawn ETH cannot exceed total deposited ETH"
        );
    }
}
