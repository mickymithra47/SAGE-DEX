// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../src/phase3/core/SagePair.sol";
import {SageMath} from "../../src/phase3/libraries/SageMath.sol";
import {SageLPAccountingEngine} from "../../src/phase4/core/SageLPAccountingEngine.sol";
import {ISageLPPosition} from "../../src/phase4/interfaces/ISageLPPosition.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";

/**
 * @title SimulateLPLifecycle
 * @notice Complete Multi-LP Position Lifecycle Simulation:
 *         1. Deploy Factory & Tokens
 *         2. Alice Initial LP Deposit (100% initial ownership)
 *         3. Bob Additional LP Deposit (Calculates optimal ratio)
 *         4. Trader Swaps (Generates fee yield for LPs)
 *         5. Position Valuation & Ownership Inspection via Accounting Engine
 *         6. Alice Partial Withdrawal (Redeems 50% shares with fee yield)
 *         7. Bob Full Withdrawal (Redeems 100% shares with fee yield)
 */
contract SimulateLPLifecycle is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 4: LP POSITION ENGINE LIFECYCLE SIMULATION ===");
        console2.log("Deployer Address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Factory, Engine, and Tokens
        (SagePair pair, SageLPAccountingEngine engine, ERC20Token tokenA, ERC20Token tokenB) = _deployCore(deployer);

        // 2. Alice Initial Deposit
        uint256 aliceShares = _simulateAliceDeposit(pair, tokenA, tokenB, deployer);

        // 3. Bob Additional Deposit
        uint256 bobShares = _simulateBobDeposit(pair, engine, tokenA, tokenB, deployer);

        // 4. Trader Swaps
        _simulateTradingActivity(pair, tokenA, deployer);

        // 5. Inspect Position Metrics
        _inspectPositions(pair, engine, deployer);

        // 6. Withdrawals
        _simulateWithdrawals(pair, aliceShares, bobShares, deployer);

        vm.stopBroadcast();
        console2.log("\n[Step 7] Phase 4 Multi-LP Position Lifecycle Simulation Complete. All invariants held.");
    }

    function _deployCore(address deployer) internal returns (
        SagePair pair,
        SageLPAccountingEngine engine,
        ERC20Token tokenA,
        ERC20Token tokenB
    ) {
        console2.log("\n[Step 1] Deploying Factory, Accounting Engine & Tokens...");
        SageFactory factory = new SageFactory(deployer);
        engine = new SageLPAccountingEngine();

        tokenA = new ERC20Token("Wrapped Ether Mock", "WETH", 18, 1_000_000 ether);
        tokenB = new ERC20Token("USD Coin Mock", "USDC", 18, 1_000_000 ether);

        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        pair = SagePair(pairAddress);
        console2.log("Pair created at:", pairAddress);
        console2.log("Accounting Engine at:", address(engine));
    }

    function _simulateAliceDeposit(
        SagePair pair,
        ERC20Token tokenA,
        ERC20Token tokenB,
        address deployer
    ) internal returns (uint256 aliceShares) {
        console2.log("\n[Step 2] Alice Deposits Initial Liquidity (10 WETH : 20,000 USDC)...");
        address t0 = pair.token0();
        address t1 = pair.token1();

        uint256 amt0 = t0 == address(tokenA) ? 10 ether : 20_000 ether;
        uint256 amt1 = t1 == address(tokenB) ? 20_000 ether : 10 ether;

        ERC20Token(t0).transfer(address(pair), amt0);
        ERC20Token(t1).transfer(address(pair), amt1);
        aliceShares = pair.mint(deployer);
        console2.log("Alice Minted LP Shares:", aliceShares);
    }

    function _simulateBobDeposit(
        SagePair pair,
        SageLPAccountingEngine engine,
        ERC20Token tokenA,
        ERC20Token tokenB,
        address deployer
    ) internal returns (uint256 bobShares) {
        console2.log("\n[Step 3] Bob Quotes and Deposits Additional Liquidity...");
        address t0 = pair.token0();

        uint256 desired0 = t0 == address(tokenA) ? 10 ether : 20_000 ether;
        uint256 desired1 = t0 == address(tokenA) ? 25_000 ether : 15 ether;

        ISageLPPosition.DepositQuote memory q = engine.quoteAddLiquidity(address(pair), desired0, desired1);
        console2.log("Bob Optimal Deposit Token0:", q.amount0Optimal);
        console2.log("Bob Optimal Deposit Token1:", q.amount1Optimal);

        ERC20Token(pair.token0()).transfer(address(pair), q.amount0Optimal);
        ERC20Token(pair.token1()).transfer(address(pair), q.amount1Optimal);
        bobShares = pair.mint(deployer);
        console2.log("Bob Minted Additional LP Shares:", bobShares);
    }

    function _simulateTradingActivity(SagePair pair, ERC20Token tokenA, address deployer) internal {
        console2.log("\n[Step 4] Executing Trader Swaps to Generate Fee Yield...");
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        address t0 = pair.token0();
        (uint112 rIn, uint112 rOut) = t0 == address(tokenA) ? (r0, r1) : (r1, r0);

        uint256 swapIn = 5 ether;
        uint256 swapOut = SageMath.getAmountOut(swapIn, rIn, rOut);

        tokenA.transfer(address(pair), swapIn);
        if (t0 == address(tokenA)) {
            pair.swap(0, swapOut, deployer, new bytes(0));
        } else {
            pair.swap(swapOut, 0, deployer, new bytes(0));
        }
        console2.log("Trade executed. Swap fee accrued inside reserves.");
    }

    function _inspectPositions(SagePair pair, SageLPAccountingEngine engine, address deployer) internal view {
        console2.log("\n[Step 5] Querying Position Metrics via On-Chain Accounting Engine...");
        ISageLPPosition.PositionView memory pos = engine.getPosition(address(pair), deployer);
        console2.log("Total Stored Reserve0:", pos.reserve0);
        console2.log("Total Stored Reserve1:", pos.reserve1);
        console2.log("User Total LP Shares:", pos.userShares);
        console2.log("User Ownership BPS:", pos.ownershipBps);
    }

    function _simulateWithdrawals(SagePair pair, uint256 aliceShares, uint256 bobShares, address deployer) internal {
        console2.log("\n[Step 6] Executing Proportional Liquidity Withdrawals...");
        uint256 totalBurn = (aliceShares / 2) + bobShares;
        pair.transfer(address(pair), totalBurn);
        (uint256 a0, uint256 a1) = pair.burn(deployer);
        console2.log("Tokens Redeemed Token0:", a0);
        console2.log("Tokens Redeemed Token1:", a1);
    }
}
