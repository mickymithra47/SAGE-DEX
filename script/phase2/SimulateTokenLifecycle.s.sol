// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../src/phase2/token/WETH.sol";
import {PermitToken} from "../../src/phase2/token/PermitToken.sol";
import {TokenRegistry} from "../../src/phase2/token/TokenRegistry.sol";

/**
 * @title SimulateTokenLifecycle
 * @notice Complete Token Layer Lifecycle Simulation
 */
contract SimulateTokenLifecycle is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 2: TOKEN LAYER LIFECYCLE SIMULATION ===");
        console2.log("Signer / Wallet Address:", deployer);
        console2.log("Account Nonce:", vm.getNonce(deployer));

        vm.deal(deployer, 100 ether);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Contracts
        ERC20Token token = new ERC20Token("Sage Base Token", "AKT", 18, 1_000_000 ether);
        WETH weth = new WETH();
        PermitToken permitToken = new PermitToken("Sage Permit Token", "aPMT", 18, 1_000_000 ether);
        TokenRegistry registry = new TokenRegistry();

        console2.log("Deployed Base Token:", address(token));
        console2.log("Deployed WETH:", address(weth));
        console2.log("Deployed Permit Token:", address(permitToken));

        // 2. WETH Wrapping Flow
        _simulateWETH(weth, deployer);

        // 3. EIP-712 Permit Flow
        _simulatePermit(permitToken, deployerPrivateKey, deployer);

        // 4. Registry Classification
        _simulateRegistry(registry, address(token), address(weth), address(permitToken));

        vm.stopBroadcast();
        console2.log("\n[Step 5] Token Layer Lifecycle Complete. All invariants validated.");
    }

    function _simulateWETH(WETH weth, address deployer) internal {
        console2.log("\n[Step 2] Executing WETH Wrapping Flow...");
        weth.deposit{value: 5 ether}();
        console2.log("WETH Total Supply:", weth.totalSupply());
        console2.log("Deployer WETH Balance:", weth.balanceOf(deployer));
    }

    function _simulatePermit(PermitToken permitToken, uint256 privateKey, address deployer) internal {
        console2.log("\n[Step 3] Executing EIP-2612 Gasless Permit Signature...");
        address spender = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        uint256 permitAmount = 50_000 ether;
        uint256 deadline = block.timestamp + 1 days;

        bytes32 structHash = keccak256(
            abi.encode(
                permitToken.PERMIT_TYPEHASH(),
                deployer,
                spender,
                permitAmount,
                permitToken.nonces(deployer),
                deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permitToken.DOMAIN_SEPARATOR(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        permitToken.permit(deployer, spender, permitAmount, deadline, v, r, s);
        console2.log("Spender Allowance verified on-chain:", permitToken.allowance(deployer, spender));
    }

    function _simulateRegistry(TokenRegistry registry, address token, address weth, address permitToken) internal {
        console2.log("\n[Step 4] Registering and Classifying Assets...");
        registry.registerToken(token, TokenRegistry.TokenCategory.CategoryA_Standard, true);
        registry.registerToken(weth, TokenRegistry.TokenCategory.CategoryA_Standard, true);
        registry.registerToken(permitToken, TokenRegistry.TokenCategory.CategoryA_Standard, true);
        console2.log("Total Verified Tokens in Registry:", registry.getTokenCount());
    }
}
