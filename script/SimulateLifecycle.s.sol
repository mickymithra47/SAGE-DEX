// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {Project1_StorageContract} from "../src/05_mini_projects/Project1_StorageContract.sol";
import {Project2_ERC20Token} from "../src/05_mini_projects/Project2_ERC20Token.sol";
import {Project3_Vault} from "../src/05_mini_projects/Project3_Vault.sol";

/**
 * @title SimulateLifecycle
 * @notice Complete Transaction Lifecycle Simulation:
 *         1. Wallet Signing & Nonce
 *         2. Transaction Encoded Payload
 *         3. RPC Submission
 *         4. EVM Execution & Opcode Processing
 *         5. Storage Slot Transitions
 *         6. Log & Event Emission
 *         7. State Root & Receipt Generation
 */
contract SimulateLifecycle is Script {
    function run() external {
        // Set up signer
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 1: TRANSACTION LIFECYCLE SIMULATION ===");
        console2.log("Signer / Wallet Address:", deployer);
        console2.log("Account Nonce:", vm.getNonce(deployer));
        console2.log("Account Balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy contracts (CREATE opcode)
        console2.log("\n[Step 1] Deploying Contracts...");
        Project1_StorageContract storageContract = new Project1_StorageContract(86400, 100, 1e18);
        console2.log("Project 1 (Storage) Deployed at:", address(storageContract));

        Project2_ERC20Token token = new Project2_ERC20Token("Sage Token", "AKT", 18, 1_000_000 ether);
        console2.log("Project 2 (ERC-20) Deployed at:", address(token));

        Project3_Vault vault = new Project3_Vault(token, "Sage Vault", "vAKT");
        console2.log("Project 3 (Vault) Deployed at:", address(vault));

        // 2. State Mutation Transaction (SSTORE, LOG)
        console2.log("\n[Step 2] Executing State Mutation Transaction...");
        storageContract.addEntry(500 ether);
        console2.log("Storage Contract Entry Added. Total Entries:", storageContract.entriesCount());

        // 3. ERC-20 Transfer & Approval
        console2.log("\n[Step 3] Executing Token Transfer & Vault Deposit...");
        address recipient = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        token.transfer(recipient, 50_000 ether);
        console2.log("Recipient Token Balance:", token.balanceOf(recipient));

        token.approve(address(vault), 10_000 ether);
        uint256 sharesMinted = vault.deposit(10_000 ether, deployer);
        console2.log("Vault Shares Minted:", sharesMinted);
        console2.log("Vault Total Assets:", vault.totalAssets());

        vm.stopBroadcast();

        console2.log("\n[Step 4] Transaction Lifecycle Complete. All state roots and receipts finalized.");
    }
}
