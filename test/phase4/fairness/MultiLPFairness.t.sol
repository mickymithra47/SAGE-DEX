// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract MultiLPFairnessTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal alice = address(0xAA01); // 10%
    address internal bob = address(0xBB02);   // 20%
    address internal carol = address(0xCC03); // 70%
    address internal trader = address(0xDD04);

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 100_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 100_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(alice, 1_000 ether);
        token1.transfer(alice, 1_000 ether);

        token0.transfer(bob, 2_000 ether);
        token1.transfer(bob, 2_000 ether);

        token0.transfer(carol, 7_000 ether);
        token1.transfer(carol, 7_000 ether);

        token0.transfer(trader, 50_000 ether);
        token1.transfer(trader, 50_000 ether);
    }

    function test_MultiLP_FairFeeDistribution() public {
        // 1. Alice deposits 1,000 / 1,000 (Initial LP)
        vm.startPrank(alice);
        token0.transfer(address(pair), 1_000 ether);
        token1.transfer(address(pair), 1_000 ether);
        uint256 aliceShares = pair.mint(alice);
        vm.stopPrank();

        // 2. Bob deposits 2,000 / 2,000
        vm.startPrank(bob);
        token0.transfer(address(pair), 2_000 ether);
        token1.transfer(address(pair), 2_000 ether);
        uint256 bobShares = pair.mint(bob);
        vm.stopPrank();

        // 3. Carol deposits 7,000 / 7,000
        vm.startPrank(carol);
        token0.transfer(address(pair), 7_000 ether);
        token1.transfer(address(pair), 7_000 ether);
        uint256 carolShares = pair.mint(carol);
        vm.stopPrank();

        // Shares ratio: Alice ~10%, Bob ~20%, Carol ~70%
        uint256 total = pair.totalSupply();
        assertEq((bobShares * 100) / total, 20);
        assertEq((carolShares * 100) / total, 70);

        // 4. Trader executes swaps generating fees
        vm.startPrank(trader);
        token0.transfer(address(pair), 5_000 ether);
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        uint256 out1 = SageMath.getAmountOut(5_000 ether, r0, r1);
        pair.swap(0, out1, trader, new bytes(0));

        // Swap back to balance price
        token1.transfer(address(pair), out1);
        (r0, r1, ) = pair.getReserves();
        uint256 out0 = SageMath.getAmountOut(out1, r1, r0);
        pair.swap(out0, 0, trader, new bytes(0));
        vm.stopPrank();

        // 5. All LPs burn their full shares
        vm.prank(alice);
        pair.transfer(address(pair), aliceShares);
        (uint256 a0Alice, uint256 a1Alice) = pair.burn(alice);

        vm.prank(bob);
        pair.transfer(address(pair), bobShares);
        (uint256 a0Bob, uint256 a1Bob) = pair.burn(bob);

        vm.prank(carol);
        pair.transfer(address(pair), carolShares);
        (uint256 a0Carol, uint256 a1Carol) = pair.burn(carol);

        // Each LP receives strictly more than their original deposit due to trading fee growth
        assertTrue(a0Alice + a1Alice > 2_000 ether - 2000);
        assertTrue(a0Bob + a1Bob > 4_000 ether);
        assertTrue(a0Carol + a1Carol > 14_000 ether);

        // Bob's return is exactly 2x Alice's return, and Carol's is exactly 7x Alice's return
        assertApproxEqRel(a0Bob, a0Alice * 2, 0.01e18);
        assertApproxEqRel(a0Carol, a0Alice * 7, 0.01e18);
    }
}
