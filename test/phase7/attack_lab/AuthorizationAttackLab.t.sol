// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Permit2} from "../../../src/phase7/core/Permit2.sol";
import {IPermit2} from "../../../src/phase7/interfaces/IPermit2.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {SpenderFrontRunningAttacker} from "../../../src/phase7/attack_lab/Phase7AttackLab.sol";

contract AuthorizationAttackLabTest is Test {
    Permit2 internal permit2;
    ERC20Token internal token;
    uint256 internal alicePrivateKey = 0xA11CE;
    address internal alice;
    address internal router = address(0x4040);

    function setUp() public {
        alice = vm.addr(alicePrivateKey);
        permit2 = new Permit2();
        token = new ERC20Token("Token A", "TKNA", 18, 1_000_000 ether);

        token.transfer(alice, 10_000 ether);

        vm.prank(alice);
        token.approve(address(permit2), type(uint256).max);
    }

    // ATTACK 1: SIGNATURE REPLAY WITHIN SAME TRANSACTION OR SECOND SUBMISSION
    function test_Attack1_SignatureReplayRejected() public {
        uint256 amount = 100 ether;
        uint256 nonce = 5;
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
                router,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // First execution succeeds
        vm.prank(router);
        permit2.permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({to: router, requestedAmount: amount}),
            alice,
            signature
        );

        // Replay attempt reverts because nonce was consumed
        vm.prank(router);
        vm.expectRevert(Permit2.InvalidNonce.selector);
        permit2.permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({to: router, requestedAmount: amount}),
            alice,
            signature
        );
    }

    // ATTACK 5: WRONG SPENDER FRONT-RUNNING ATTEMPT REJECTED
    function test_Attack5_WrongSpenderFrontRunningRejected() public {
        uint256 amount = 100 ether;
        uint256 nonce = 6;
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
                router, // Signature was specifically signed for router
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Attacker attempts to steal tokens by executing the intercepted signature
        SpenderFrontRunningAttacker attacker = new SpenderFrontRunningAttacker(permit2);
        vm.expectRevert(Permit2.InvalidSignature.selector);
        attacker.interceptSignature(permitDetails, alice, signature);
    }

    // ATTACK 7: EXPIRED SIGNATURE REJECTION
    function test_Attack7_ExpiredSignatureRejected() public {
        uint256 amount = 100 ether;
        uint256 nonce = 7;
        uint256 deadline = block.timestamp + 100;

        IPermit2.PermitTransferFrom memory permitDetails = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({token: address(token), amount: amount}),
            nonce: nonce,
            deadline: deadline
        });

        bytes32 dataHash = keccak256(
            abi.encode(
                permit2.PERMIT_TRANSFER_FROM_TYPEHASH(),
                keccak256(abi.encode(permit2.TOKEN_PERMISSIONS_TYPEHASH(), address(token), amount)),
                router,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Warp time past deadline
        vm.warp(block.timestamp + 200);

        vm.prank(router);
        vm.expectRevert(Permit2.SignatureExpired.selector);
        permit2.permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({to: router, requestedAmount: amount}),
            alice,
            signature
        );
    }
}
