// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Permit2} from "../../../src/phase7/core/Permit2.sol";
import {IPermit2} from "../../../src/phase7/interfaces/IPermit2.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract AuthorizationGasBenchmarksTest is Test {
    Permit2 internal permit2;
    ERC20Token internal token;
    uint256 internal alicePrivateKey = 0xA11CE;
    address internal alice;
    address internal spender = address(0xB0B);

    function setUp() public {
        alice = vm.addr(alicePrivateKey);
        permit2 = new Permit2();
        token = new ERC20Token("Token A", "TKNA", 18, 1_000_000 ether);

        token.transfer(alice, 10_000 ether);

        vm.prank(alice);
        token.approve(address(permit2), type(uint256).max);
    }

    function test_Benchmark_Permit2SignatureTransfer() public {
        uint256 amount = 100 ether;
        uint256 nonce = 100;
        uint256 deadline = block.timestamp + 300;

        IPermit2.PermitTransferFrom memory permitDetails = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({token: address(token), amount: amount}),
            nonce: nonce,
            deadline: deadline
        });

        bytes32 dataHash = keccak256(
            abi.encode(
                permit2.PERMIT_TRANSFER_FROM_TYPEHASH(),
                keccak256(abi.encode(permit2.TOKEN_PERMISSIONS_TYPEHASH(), address(token), amount)),
                spender,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(spender);
        permit2.permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({to: spender, requestedAmount: amount}),
            alice,
            signature
        );
    }
}
