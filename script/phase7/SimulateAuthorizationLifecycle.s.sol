// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../src/phase3/core/SagePair.sol";
import {Permit2} from "../../src/phase7/core/Permit2.sol";
import {SagePermitRouter} from "../../src/phase7/core/SagePermitRouter.sol";
import {IPermit2} from "../../src/phase7/interfaces/IPermit2.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";
import {PermitToken} from "../../src/phase2/token/PermitToken.sol";
import {WETH} from "../../src/phase2/token/WETH.sol";

/**
 * @title SimulateAuthorizationLifecycle
 * @notice Complete Authorization & Signature-Based Swap Lifecycle Simulation
 */
contract SimulateAuthorizationLifecycle is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("=== PHASE 7: APPROVALS & PERMIT2 LIFECYCLE SIMULATION ===");
        console2.log("Deployer / Signer Address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Core
        (
            SageFactory factory,
            Permit2 permit2,
            SagePermitRouter router,
            PermitToken tokenA,
            ERC20Token tokenB
        ) = _deployCore(deployer);

        // 2. Seed Pool
        _seedPool(factory, tokenA, tokenB, deployer);

        // 3. EIP-2612 Atomic Permit + Swap (10 Token A -> Token B)
        _simulateEIP2612Swap(router, tokenA, tokenB, deployer, deployerPrivateKey);

        // 4. Permit2 Signature Transfer + Swap (10 Token A -> Token B)
        _simulatePermit2Swap(router, permit2, tokenA, tokenB, deployer, deployerPrivateKey);

        vm.stopBroadcast();
        console2.log("\n[Step 5] Phase 7 Authorization & Permit2 Lifecycle Simulation Complete.");
    }

    function _deployCore(address deployer) internal returns (
        SageFactory factory,
        Permit2 permit2,
        SagePermitRouter router,
        PermitToken tokenA,
        ERC20Token tokenB
    ) {
        console2.log("\n[Step 1] Deploying Factory, Permit2, SagePermitRouter & Tokens...");
        factory = new SageFactory(deployer);
        WETH weth = new WETH();
        permit2 = new Permit2();
        router = new SagePermitRouter(address(factory), address(weth), address(permit2));

        tokenA = new PermitToken("Token A Permit", "TKNA", 18, 1_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 1_000_000 ether);
    }

    function _seedPool(
        SageFactory factory,
        PermitToken tokenA,
        ERC20Token tokenB,
        address deployer
    ) internal {
        console2.log("\n[Step 2] Initializing and Seeding Liquidity Pool...");
        SagePair pair = SagePair(factory.createPair(address(tokenA), address(tokenB)));

        tokenA.transfer(address(pair), 10_000 ether);
        tokenB.transfer(address(pair), 20_000 ether);
        pair.mint(deployer);
    }

    function _simulateEIP2612Swap(
        SagePermitRouter router,
        PermitToken tokenA,
        ERC20Token tokenB,
        address deployer,
        uint256 pk
    ) internal {
        console2.log("\n[Step 3] Executing Atomic EIP-2612 Permit + Swap (10 TKNA -> TKNB)...");
        uint256 deadline = block.timestamp + 300;

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                deployer,
                address(router),
                10 ether,
                tokenA.nonces(deployer),
                deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", tokenA.DOMAIN_SEPARATOR(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        uint256[] memory amounts = router.swapExactTokensForTokensWithPermit(
            10 ether,
            19 ether,
            path,
            deployer,
            deadline,
            v,
            r,
            s
        );
        console2.log("Received Token B via EIP-2612:", amounts[1] / 1e18);
    }

    function _simulatePermit2Swap(
        SagePermitRouter router,
        Permit2 permit2,
        PermitToken tokenA,
        ERC20Token tokenB,
        address deployer,
        uint256 pk
    ) internal {
        console2.log("\n[Step 4] Executing Atomic Permit2 Signature Swap (10 TKNA -> TKNB)...");
        tokenA.approve(address(permit2), type(uint256).max);

        uint256 deadline = block.timestamp + 300;

        IPermit2.PermitTransferFrom memory permitDetails = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({token: address(tokenA), amount: 10 ether}),
            nonce: 99,
            deadline: deadline
        });

        bytes32 dataHash = keccak256(
            abi.encode(
                permit2.PERMIT_TRANSFER_FROM_TYPEHASH(),
                keccak256(abi.encode(permit2.TOKEN_PERMISSIONS_TYPEHASH(), address(tokenA), 10 ether)),
                address(router),
                uint256(99),
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        uint256[] memory amounts = router.swapExactTokensForTokensWithPermit2(
            10 ether,
            19 ether,
            path,
            deployer,
            deadline,
            permitDetails,
            abi.encodePacked(r, s, v)
        );
        console2.log("Received Token B via Permit2:", amounts[1] / 1e18);
    }
}
