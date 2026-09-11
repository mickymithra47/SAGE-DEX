// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../src/phase3/core/SagePair.sol";
import {SageMath} from "../../src/phase3/libraries/SageMath.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";

/**
 * @title SimulateAMMLifecycle
 * @notice Phase 3 AMM V2 Core Full Lifecycle Simulation
 */
contract SimulateAMMLifecycle is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 3: AMM V2 CORE LIFECYCLE SIMULATION ===");
        console2.log("Deployer Address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Factory & Tokens
        (SagePair pair, ERC20Token tokenA, ERC20Token tokenB) = _deployAndCreatePair(deployer);

        // 2. Initial Liquidity Minting
        _depositInitialLiquidity(pair, tokenA, tokenB, deployer);

        // 3. Exact-Input Swap Execution
        _executeSwap(pair, tokenA, deployer);

        // 4. Reserve Reconciliation
        (uint112 postR0, uint112 postR1, ) = pair.getReserves();
        console2.log("\n[Step 4] Post-Swap Reserves:");
        console2.log("Reserve0:", postR0);
        console2.log("Reserve1:", postR1);

        vm.stopBroadcast();
        console2.log("\n[Step 5] Phase 3 AMM V2 Core Lifecycle Simulation Complete.");
    }

    function _deployAndCreatePair(address deployer) internal returns (SagePair pair, ERC20Token tokenA, ERC20Token tokenB) {
        console2.log("\n[Step 1] Deploying Factory & Pair Tokens...");
        SageFactory factory = new SageFactory(deployer);
        tokenA = new ERC20Token("Wrapped Ether Mock", "WETH", 18, 1_000_000 ether);
        tokenB = new ERC20Token("USD Coin Mock", "USDC", 18, 1_000_000 ether);

        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        pair = SagePair(pairAddress);
        console2.log("Factory deployed at:", address(factory));
        console2.log("Pair created via CREATE2 at:", pairAddress);
    }

    function _depositInitialLiquidity(SagePair pair, ERC20Token tokenA, ERC20Token tokenB, address deployer) internal {
        console2.log("\n[Step 2] Depositing Initial Liquidity (100 WETH : 200,000 USDC)...");
        address t0 = pair.token0();
        address t1 = pair.token1();

        uint256 amt0 = t0 == address(tokenA) ? 100 ether : 200_000 ether;
        uint256 amt1 = t1 == address(tokenB) ? 200_000 ether : 100 ether;

        ERC20Token(t0).transfer(address(pair), amt0);
        ERC20Token(t1).transfer(address(pair), amt1);
        uint256 initialLP = pair.mint(deployer);
        console2.log("LP Shares Minted:", initialLP);
        console2.log("Minimum Liquidity Locked to Zero Address:", pair.balanceOf(address(0)));
    }

    function _executeSwap(SagePair pair, ERC20Token tokenA, address deployer) internal {
        console2.log("\n[Step 3] Executing Token Swap (Swap 10 WETH for USDC)...");
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        address t0 = pair.token0();
        (uint112 rIn, uint112 rOut) = t0 == address(tokenA) ? (r0, r1) : (r1, r0);

        uint256 swapAmountIn = 10 ether;
        uint256 expectedOut = SageMath.getAmountOut(swapAmountIn, rIn, rOut);
        console2.log("Calculated Swap Output with 0.3% fee:", expectedOut);

        tokenA.transfer(address(pair), swapAmountIn);
        if (t0 == address(tokenA)) {
            pair.swap(0, expectedOut, deployer, new bytes(0));
        } else {
            pair.swap(expectedOut, 0, deployer, new bytes(0));
        }
        console2.log("Swap completed successfully. Invariant strictly preserved.");
    }
}
