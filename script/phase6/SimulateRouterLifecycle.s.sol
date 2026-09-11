// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../src/phase2/token/WETH.sol";

/**
 * @title SimulateRouterLifecycle
 * @notice Complete Swap Execution & Router Lifecycle Simulation:
 *         1. Deploy Factory, WETH, SageRouter, and Tokens (USDC, DAI)
 *         2. Seed Pools: WETH/USDC (100:200,000) and USDC/DAI (100,000:100,000)
 *         3. Execute Single-Hop Exact-Input Swap (ETH -> USDC)
 *         4. Execute Multi-Hop Exact-Input Swap (ETH -> USDC -> DAI)
 *         5. Verify Zero Residual Balance Invariant on SageRouter
 */
contract SimulateRouterLifecycle is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 6: SWAP EXECUTION & ROUTER LIFECYCLE SIMULATION ===");
        console2.log("Deployer Address:", deployer);

        vm.deal(deployer, 1000 ether);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Core
        (SageFactory factory, WETH weth, SageRouter router, ERC20Token usdc, ERC20Token dai) = _deployCore(deployer);

        // 2. Seed Pools
        _seedPools(factory, weth, usdc, dai, deployer);

        // 3. Single-Hop Exact-Input: 1 ETH -> USDC
        _swapSingleHop(router, address(weth), address(usdc), deployer);

        // 4. Multi-Hop Exact-Input: 1 ETH -> USDC -> DAI
        _swapMultiHop(router, address(weth), address(usdc), address(dai), deployer);

        // 5. Verification
        _verifyRouterZeroBalance(address(router), address(usdc), address(dai));

        vm.stopBroadcast();
        console2.log("\n[Step 6] Phase 6 Swap Execution & Router Lifecycle Simulation Complete.");
    }

    function _deployCore(address deployer) internal returns (
        SageFactory factory,
        WETH weth,
        SageRouter router,
        ERC20Token usdc,
        ERC20Token dai
    ) {
        console2.log("\n[Step 1] Deploying Factory, WETH, SageRouter & Tokens...");
        factory = new SageFactory(deployer);
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));
        usdc = new ERC20Token("USD Coin Mock", "USDC", 18, 1_000_000 ether);
        dai = new ERC20Token("Dai Stablecoin Mock", "DAI", 18, 1_000_000 ether);
    }

    function _seedPools(
        SageFactory factory,
        WETH weth,
        ERC20Token usdc,
        ERC20Token dai,
        address deployer
    ) internal {
        console2.log("\n[Step 2] Initializing and Seeding Liquidity Pools...");
        SagePair pairEthUsdc = SagePair(factory.createPair(address(weth), address(usdc)));
        SagePair pairUsdcDai = SagePair(factory.createPair(address(usdc), address(dai)));

        weth.deposit{value: 100 ether}();
        weth.transfer(address(pairEthUsdc), 100 ether);
        usdc.transfer(address(pairEthUsdc), 200_000 ether);
        pairEthUsdc.mint(deployer);

        usdc.transfer(address(pairUsdcDai), 100_000 ether);
        dai.transfer(address(pairUsdcDai), 100_000 ether);
        pairUsdcDai.mint(deployer);
    }

    function _swapSingleHop(SageRouter router, address weth, address usdc, address deployer) internal {
        console2.log("\n[Step 3] Executing SwapExactETHForTokens (1 ETH -> USDC)...");
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;
        uint256[] memory amounts = router.swapExactETHForTokens{value: 1 ether}(
            1900 ether,
            path,
            deployer,
            block.timestamp + 300
        );
        console2.log("Received USDC:", amounts[1] / 1e18);
    }

    function _swapMultiHop(SageRouter router, address weth, address usdc, address dai, address deployer) internal {
        console2.log("\n[Step 4] Executing SwapExactETHForTokens Multi-Hop (1 ETH -> USDC -> DAI)...");
        address[] memory path = new address[](3);
        path[0] = weth;
        path[1] = usdc;
        path[2] = dai;
        uint256[] memory amounts = router.swapExactETHForTokens{value: 1 ether}(
            1800 ether,
            path,
            deployer,
            block.timestamp + 300
        );
        console2.log("Received DAI:", amounts[2] / 1e18);
    }

    function _verifyRouterZeroBalance(address router, address usdc, address dai) internal view {
        require(router.balance == 0, "Router ETH balance must be 0");
        require(ERC20Token(usdc).balanceOf(router) == 0, "Router USDC balance must be 0");
        require(ERC20Token(dai).balanceOf(router) == 0, "Router DAI balance must be 0");
        console2.log("\n[Step 5] Router zero-balance invariant verified successfully.");
    }
}
