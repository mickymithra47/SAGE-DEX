// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageQuoter} from "../../src/phase5/core/SageQuoter.sol";
import {SageOracleEngine} from "../../src/phase5/core/SageOracleEngine.sol";

contract DeployPhase5 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address deployer = vm.addr(deployerPrivateKey);
        address factoryAddress = vm.envOr("FACTORY_ADDRESS", address(0x5FbDB2315678afecb367f032d93F642f64180aa3));

        console2.log("Deploying Phase 5 Quoter and Oracle Engine from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        SageQuoter quoter = new SageQuoter(factoryAddress);
        SageOracleEngine oracle = new SageOracleEngine();

        console2.log("SageQuoter deployed at:", address(quoter));
        console2.log("SageOracleEngine deployed at:", address(oracle));

        vm.stopBroadcast();
        console2.log("Phase 5 deployment complete.");
    }
}
