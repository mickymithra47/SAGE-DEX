// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageLPAccountingEngine} from "../../src/phase4/core/SageLPAccountingEngine.sol";

contract DeployPhase4 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("Deploying Phase 4 LP Accounting Engine from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        SageLPAccountingEngine engine = new SageLPAccountingEngine();
        console2.log("SageLPAccountingEngine deployed at:", address(engine));

        vm.stopBroadcast();
        console2.log("Phase 4 deployment complete.");
    }
}
