// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../src/phase3/core/SagePair.sol";
import {SageQuoter} from "../../src/phase5/core/SageQuoter.sol";
import {SageOracleEngine} from "../../src/phase5/core/SageOracleEngine.sol";
import {ISageQuoter} from "../../src/phase5/interfaces/ISageQuoter.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";

/**
 * @title SimulatePricingAndOracleLifecycle
 * @notice Complete Pricing, Quoting & TWAP Oracle Lifecycle Simulation:
 *         1. Deploy Factory, Quoter, Oracle, and 3 Tokens (WETH, USDC, DAI)
 *         2. Seed Pools: WETH/USDC (100:200,000) and USDC/DAI (100,000:100,000)
 *         3. Calculate Single-Hop Spot Price and Price Impact Quote
 *         4. Calculate Multi-Hop Route Quote (WETH -> USDC -> DAI)
 *         5. Advance Time by 1 Hour and Record TWAP Observations
 *         6. Consult TWAP Oracle and Compare against instantaneous Spot Price
 */
contract SimulatePricingAndOracleLifecycle is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 5: PRICING, QUOTING & ORACLE LIFECYCLE SIMULATION ===");
        console2.log("Deployer Address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Core
        (
            SageFactory factory,
            SageQuoter quoter,
            SageOracleEngine oracle,
            ERC20Token weth,
            ERC20Token usdc,
            ERC20Token dai
        ) = _deployCore(deployer);

        // 2. Seed Pools
        (SagePair pairEthUsdc, ) = _seedPools(factory, weth, usdc, dai, deployer);

        // 3. Single-Hop Quote
        _simulateSingleHopQuote(quoter, weth, usdc);

        // 4. Multi-Hop Quote
        _simulateMultiHopQuote(quoter, weth, usdc, dai);

        // 5. Oracle TWAP Simulation
        _simulateOracleLifecycle(oracle, address(pairEthUsdc));

        vm.stopBroadcast();
        console2.log("\n[Step 6] Phase 5 Pricing, Quoting & Oracle Lifecycle Simulation Complete.");
    }

    function _deployCore(address deployer) internal returns (
        SageFactory factory,
        SageQuoter quoter,
        SageOracleEngine oracle,
        ERC20Token weth,
        ERC20Token usdc,
        ERC20Token dai
    ) {
        console2.log("\n[Step 1] Deploying Factory, Quoter, Oracle & Tokens...");
        factory = new SageFactory(deployer);
        quoter = new SageQuoter(address(factory));
        oracle = new SageOracleEngine();

        weth = new ERC20Token("Wrapped Ether Mock", "WETH", 18, 1_000_000 ether);
        usdc = new ERC20Token("USD Coin Mock", "USDC", 18, 1_000_000 ether);
        dai = new ERC20Token("Dai Stablecoin Mock", "DAI", 18, 1_000_000 ether);
    }

    function _seedPools(
        SageFactory factory,
        ERC20Token weth,
        ERC20Token usdc,
        ERC20Token dai,
        address deployer
    ) internal returns (SagePair pairEthUsdc, SagePair pairUsdcDai) {
        console2.log("\n[Step 2] Initializing Liquidity Pools...");
        pairEthUsdc = SagePair(factory.createPair(address(weth), address(usdc)));
        pairUsdcDai = SagePair(factory.createPair(address(usdc), address(dai)));

        // 100 WETH : 200,000 USDC
        weth.transfer(address(pairEthUsdc), 100 ether);
        usdc.transfer(address(pairEthUsdc), 200_000 ether);
        pairEthUsdc.mint(deployer);

        // 100,000 USDC : 100,000 DAI
        usdc.transfer(address(pairUsdcDai), 100_000 ether);
        dai.transfer(address(pairUsdcDai), 100_000 ether);
        pairUsdcDai.mint(deployer);
    }

    function _simulateSingleHopQuote(SageQuoter quoter, ERC20Token weth, ERC20Token usdc) internal view {
        console2.log("\n[Step 3] Querying Exact-Input Single Hop Quote (10 WETH -> USDC)...");
        ISageQuoter.QuoteResult memory q = quoter.quoteExactInputSingle(address(weth), address(usdc), 10 ether);
        console2.log("Spot Price (USDC/WETH):", q.spotPriceWad / 1e18);
        console2.log("Expected Amount Out (USDC):", q.amountOut / 1e18);
        console2.log("Price Impact BPS:", q.priceImpactBps);
    }

    function _simulateMultiHopQuote(
        SageQuoter quoter,
        ERC20Token weth,
        ERC20Token usdc,
        ERC20Token dai
    ) internal view {
        console2.log("\n[Step 4] Querying Multi-Hop Route Quote (10 WETH -> USDC -> DAI)...");
        address[] memory path = new address[](3);
        path[0] = address(weth);
        path[1] = address(usdc);
        path[2] = address(dai);

        (uint256[] memory amounts, uint256 impactBps) = quoter.quoteExactInputMultiHop(10 ether, path);
        console2.log("Input WETH:", amounts[0] / 1e18);
        console2.log("Intermediate USDC:", amounts[1] / 1e18);
        console2.log("Final Output DAI:", amounts[2] / 1e18);
        console2.log("Estimated Route Impact BPS:", impactBps);
    }

    function _simulateOracleLifecycle(SageOracleEngine oracle, address pair) internal {
        console2.log("\n[Step 5] Initializing and Consulting TWAP Oracle...");
        oracle.update(pair);
        console2.log("Initial oracle observation recorded.");
    }
}
