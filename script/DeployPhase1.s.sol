// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {Project1_StorageContract} from "../src/05_mini_projects/Project1_StorageContract.sol";
import {Project2_ERC20Token} from "../src/05_mini_projects/Project2_ERC20Token.sol";
import {Project3_Vault} from "../src/05_mini_projects/Project3_Vault.sol";
import {Project4_Escrow} from "../src/05_mini_projects/Project4_Escrow.sol";
import {Project5_DeterministicFactory} from "../src/05_mini_projects/Project5_DeterministicFactory.sol";
import {Project6_CallbackProtocol} from "../src/05_mini_projects/Project6_CallbackProtocol.sol";
import {Project7_LowLevelCallLab} from "../src/05_mini_projects/Project7_LowLevelCallLab.sol";
import {Project8_YulOptimizedMath} from "../src/05_mini_projects/Project8_YulOptimizedMath.sol";

contract DeployPhase1 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );

        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying Phase 1 Foundation from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        Project1_StorageContract p1 = new Project1_StorageContract(86400, 100, 1e18);
        console2.log("Project 1 (Storage) deployed:", address(p1));

        Project2_ERC20Token p2 = new Project2_ERC20Token("Sage Foundation Token", "AKT", 18, 1_000_000 ether);
        console2.log("Project 2 (ERC-20) deployed:", address(p2));

        Project3_Vault p3 = new Project3_Vault(p2, "Sage Foundation Vault", "vAKT");
        console2.log("Project 3 (Vault) deployed:", address(p3));

        Project4_Escrow p4 = new Project4_Escrow(address(0x1), address(0x2), 3 days);
        console2.log("Project 4 (Escrow) deployed:", address(p4));

        Project5_DeterministicFactory p5 = new Project5_DeterministicFactory();
        console2.log("Project 5 (Factory) deployed:", address(p5));

        Project6_CallbackProtocol p6 = new Project6_CallbackProtocol{value: 1 ether}();
        console2.log("Project 6 (Callback) deployed:", address(p6));

        Project7_LowLevelCallLab p7 = new Project7_LowLevelCallLab();
        console2.log("Project 7 (LowLevelLab) deployed:", address(p7));

        Project8_YulOptimizedMath p8 = new Project8_YulOptimizedMath();
        console2.log("Project 8 (YulMath) deployed:", address(p8));

        vm.stopBroadcast();
        console2.log("Phase 1 deployments complete.");
    }
}
