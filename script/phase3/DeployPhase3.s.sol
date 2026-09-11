// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../src/phase2/token/WETH.sol";

contract DeployPhase3 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("Deploying Phase 3 AMM V2 Core from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        SageFactory factory = new SageFactory(deployer);
        console2.log("SageFactory deployed at:", address(factory));

        WETH weth = new WETH();
        console2.log("WETH deployed at:", address(weth));

        ERC20Token usdc = new ERC20Token("USD Coin Mock", "USDC", 6, 100_000_000 * 1e6);
        console2.log("USDC deployed at:", address(usdc));

        address pair = factory.createPair(address(weth), address(usdc));
        console2.log("Canonical WETH/USDC Pair deployed at:", pair);

        vm.stopBroadcast();
        console2.log("Phase 3 deployment complete.");
    }
}
