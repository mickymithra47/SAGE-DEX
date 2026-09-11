// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract PairGasBenchmarksTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal trader = address(0x9999);

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
        pair.mint(address(this));

        token0.transfer(trader, 10_000 ether);
    }

    function test_Benchmark_PairSwap() public {
        vm.startPrank(trader);
        token0.transfer(address(pair), 100 ether);

        uint256 g1 = gasleft();
        pair.swap(0, 90 ether, trader, new bytes(0));
        uint256 swapGas = g1 - gasleft();
        vm.stopPrank();

        emit log_named_uint("SagePair Swap Gas", swapGas);
        assertLt(swapGas, 100_000);
    }

    function test_Benchmark_PairMintAndBurn() public {
        token0.transfer(address(pair), 1000 ether);
        token1.transfer(address(pair), 1000 ether);

        uint256 g1 = gasleft();
        uint256 liq = pair.mint(address(this));
        uint256 mintGas = g1 - gasleft();

        pair.transfer(address(pair), liq);

        uint256 g2 = gasleft();
        pair.burn(address(this));
        uint256 burnGas = g2 - gasleft();

        emit log_named_uint("SagePair Mint Gas", mintGas);
        emit log_named_uint("SagePair Burn Gas", burnGas);
    }
}
