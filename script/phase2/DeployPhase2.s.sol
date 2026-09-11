// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../src/phase2/token/WETH.sol";
import {PermitToken} from "../../src/phase2/token/PermitToken.sol";
import {DecimalsToken, TokenRegistry} from "../../src/phase2/token/TokenRegistry.sol";
import {TokenCompatibilityChecker} from "../../src/phase2/libraries/TokenCompatibilityChecker.sol";

contract DeployPhase2 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );

        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying Phase 2 Token Layer from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        ERC20Token token = new ERC20Token("Sage Base Token", "AKT", 18, 1_000_000 ether);
        console2.log("ERC20Token deployed:", address(token));

        WETH weth = new WETH();
        console2.log("WETH deployed:", address(weth));

        PermitToken permitToken = new PermitToken("Sage Permit Token", "aPMT", 18, 1_000_000 ether);
        console2.log("PermitToken deployed:", address(permitToken));

        DecimalsToken usdc = new DecimalsToken("USD Coin Mock", "USDC", 6, 10_000_000 * 1e6);
        console2.log("USDC (6 Decimals) deployed:", address(usdc));

        TokenRegistry registry = new TokenRegistry();
        console2.log("TokenRegistry deployed:", address(registry));

        TokenCompatibilityChecker checker = new TokenCompatibilityChecker();
        console2.log("TokenCompatibilityChecker deployed:", address(checker));

        vm.stopBroadcast();
        console2.log("Phase 2 deployment complete.");
    }
}
