// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {SageFactory} from "../src/phase3/core/SageFactory.sol";
import {SagePair} from "../src/phase3/core/SagePair.sol";
import {SageRouter} from "../src/phase6/core/SageRouter.sol";
import {Permit2} from "../src/phase7/core/Permit2.sol";
import {SagePermitRouter} from "../src/phase7/core/SagePermitRouter.sol";
import {WETH} from "../src/phase2/token/WETH.sol";
import {ERC20Token} from "../src/phase2/token/ERC20Token.sol";
import {SageOracleEngine} from "../src/phase5/core/SageOracleEngine.sol";

/**
 * @title DeployPhase12Testnet
 * @notice Complete reproducible deployment script for the SAGE DEX protocol.
 */
contract DeployPhase12Testnet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("DEPLOYER_PRIVATE_KEY", uint256(0xA11CE));
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=== SAGE DEX PHASE 12 TESTNET DEPLOYMENT ===");
        console.log("Deployer Address:", deployer);
        console.log("Chain ID:", block.chainid);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Canonical Tokens & WETH
        WETH weth = new WETH();
        console.log("WETH deployed at:", address(weth));

        ERC20Token tokenA = new ERC20Token("Sage USD", "aUSD", 18, 100_000_000 ether);
        ERC20Token tokenB = new ERC20Token("USD Coin", "USDC", 6, 100_000_000 * 10**6);
        ERC20Token tokenC = new ERC20Token("Wrapped BTC", "WBTC", 8, 100_000 * 10**8);
        console.log("Token A (18 decimals) deployed at:", address(tokenA));
        console.log("Token B (6 decimals) deployed at:", address(tokenB));
        console.log("Token C (8 decimals) deployed at:", address(tokenC));

        // 2. Deploy Factory
        SageFactory factory = new SageFactory(deployer);
        console.log("SageFactory deployed at:", address(factory));

        // 3. Deploy Router
        SageRouter router = new SageRouter(address(factory), address(weth));
        console.log("SageRouter deployed at:", address(router));

        // 4. Deploy Permit2 & SagePermitRouter
        Permit2 permit2 = new Permit2();
        console.log("Permit2 deployed at:", address(permit2));

        SagePermitRouter permitRouter = new SagePermitRouter(
            address(factory),
            address(weth),
            address(permit2)
        );
        console.log("SagePermitRouter deployed at:", address(permitRouter));

        // 5. Deploy Oracle Engine
        SageOracleEngine oracle = new SageOracleEngine();
        console.log("SageOracleEngine deployed at:", address(oracle));

        // 6. Create Test Pools
        address pairAB = factory.createPair(address(tokenA), address(tokenB));
        address pairAC = factory.createPair(address(tokenA), address(tokenC));
        console.log("Pair aUSD/USDC deployed at:", pairAB);
        console.log("Pair aUSD/WBTC deployed at:", pairAC);

        // 7. Seed Initial Liquidity
        tokenA.transfer(pairAB, 100_000 ether);
        tokenB.transfer(pairAB, 100_000 * 10**6);
        SagePair(pairAB).mint(deployer);
        console.log("Seeded 100k aUSD / 100k USDC liquidity into PairAB");

        tokenA.transfer(pairAC, 600_000 ether);
        tokenC.transfer(pairAC, 10 * 10**8);
        SagePair(pairAC).mint(deployer);
        console.log("Seeded 600k aUSD / 10 WBTC liquidity into PairAC");

        vm.stopBroadcast();

        console.log("=== DEPLOYMENT COMPLETED SUCCESSFULLY ===");
    }
}
