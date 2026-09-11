// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract FactoryAndPairTest is Test {
    SageFactory internal factory;
    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    ERC20Token internal tokenC;

    address internal feeSetter = address(0xFAFA);
    address internal alice = address(0x1111);

    function setUp() public {
        factory = new SageFactory(feeSetter);
        tokenA = new ERC20Token("Token A", "TKNA", 18, 1_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 1_000_000 ether);
        tokenC = new ERC20Token("Token C", "TKNC", 18, 1_000_000 ether);
    }

    function test_Factory_CreatePairDeterministicOrdering() public {
        address pair = factory.createPair(address(tokenA), address(tokenB));
        assertTrue(pair != address(0));

        (address token0, address token1) = address(tokenA) < address(tokenB)
            ? (address(tokenA), address(tokenB))
            : (address(tokenB), address(tokenA));

        assertEq(SagePair(pair).token0(), token0);
        assertEq(SagePair(pair).token1(), token1);
        assertEq(factory.getPair(address(tokenA), address(tokenB)), pair);
        assertEq(factory.getPair(address(tokenB), address(tokenA)), pair); // Bidirectional lookup
        assertEq(factory.allPairsLength(), 1);
    }

    function test_Factory_RevertsOnDuplicatePair() public {
        factory.createPair(address(tokenA), address(tokenB));

        vm.expectRevert(abi.encodeWithSelector(SageFactory.PairExists.selector));
        factory.createPair(address(tokenA), address(tokenB));

        vm.expectRevert(abi.encodeWithSelector(SageFactory.PairExists.selector));
        factory.createPair(address(tokenB), address(tokenA));
    }

    function test_Factory_RevertsOnIdenticalTokensOrZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(SageFactory.IdenticalAddresses.selector));
        factory.createPair(address(tokenA), address(tokenA));

        vm.expectRevert(abi.encodeWithSelector(SageFactory.ZeroAddress.selector));
        factory.createPair(address(0), address(tokenA));
    }

    function test_Factory_FeeToSetterAccessControl() public {
        vm.prank(feeSetter);
        factory.setFeeTo(alice);
        assertEq(factory.feeTo(), alice);

        // Non-feeSetter reverts
        vm.expectRevert(abi.encodeWithSelector(SageFactory.Unauthorized.selector));
        factory.setFeeTo(address(0xBAD));
    }
}
