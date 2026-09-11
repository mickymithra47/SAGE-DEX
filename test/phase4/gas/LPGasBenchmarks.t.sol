// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageLPAccountingEngine} from "../../../src/phase4/core/SageLPAccountingEngine.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract LPGasBenchmarksTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    SageLPAccountingEngine internal engine;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal user = address(0x7777);

    function setUp() public {
        factory = new SageFactory(address(this));
        engine = new SageLPAccountingEngine();

        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 10_000 ether);
        pair.mint(user);
    }

    function test_Benchmark_LPAccountingView() public view {
        engine.getPosition(address(pair), user);
    }

    function test_Benchmark_LPTransfer() public {
        vm.prank(user);
        uint256 g1 = gasleft();
        pair.transfer(address(0x8888), 100 ether);
        uint256 transferGas = g1 - gasleft();

        emit log_named_uint("LP Token Transfer Gas", transferGas);
        assertLt(transferGas, 60_000);
    }
}
