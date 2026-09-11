// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract LPTransfersTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal alice = address(0xAAAA);
    address internal bob = address(0xBBBB);

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 10_000 ether);
        pair.mint(alice);
    }

    function test_LPTransfer_ShiftsProportionalOwnership() public {
        uint256 totalShares = pair.totalSupply();
        uint256 aliceInitial = pair.balanceOf(alice);

        // Alice transfers 40% of her LP shares to Bob
        uint256 transferAmount = (aliceInitial * 40) / 100;

        vm.prank(alice);
        pair.transfer(bob, transferAmount);

        assertEq(pair.balanceOf(bob), transferAmount);
        assertEq(pair.balanceOf(alice), aliceInitial - transferAmount);

        // Bob now has an active underlying asset claim on the pool without depositing tokens directly
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        uint256 bobClaim0 = (transferAmount * r0) / totalShares;
        uint256 bobClaim1 = (transferAmount * r1) / totalShares;

        assertTrue(bobClaim0 > 0 && bobClaim1 > 0);

        // Bob can burn his acquired shares and withdraw assets
        vm.prank(bob);
        pair.transfer(address(pair), transferAmount);
        (uint256 a0, uint256 a1) = pair.burn(bob);

        assertEq(a0, bobClaim0);
        assertEq(a1, bobClaim1);
    }
}
