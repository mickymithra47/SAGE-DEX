// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageRouter} from "../../src/phase6/core/SageRouter.sol";

contract DeployPhase6 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address deployer = vm.addr(deployerPrivateKey);
        address factoryAddress = vm.envOr("FACTORY_ADDRESS", address(0x5FbDB2315678afecb367f032d93F642f64180aa3));
        address wethAddress = vm.envOr("WETH_ADDRESS", address(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512));

        console2.log("Deploying Phase 6 SageRouter from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        SageRouter router = new SageRouter(factoryAddress, wethAddress);
        console2.log("SageRouter deployed at:", address(router));

        vm.stopBroadcast();
        console2.log("Phase 6 deployment complete.");
    }
}
