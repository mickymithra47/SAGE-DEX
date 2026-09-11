// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {PermitToken} from "../../../src/phase2/token/PermitToken.sol";

contract PermitAndEIP712Test is Test {
    PermitToken internal token;

    uint256 internal ownerPrivateKey = 0xA11CE;
    address internal owner;
    address internal spender = address(0x2222);

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        token = new PermitToken("Permit Token", "PMT", 18, 1_000_000 ether);
        token.transfer(owner, 10_000 ether);
    }

    function _getPermitDigest(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _nonce,
        uint256 _deadline
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                token.PERMIT_TYPEHASH(),
                _owner,
                _spender,
                _value,
                _nonce,
                _deadline
            )
        );
        return keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));
    }

    function test_Permit_ValidSignatureSetsAllowance() public {
        uint256 value = 1000 ether;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(owner, spender, value, deadline, v, r, s);

        assertEq(token.allowance(owner, spender), value);
        assertEq(token.nonces(owner), 1);
    }

    function test_Permit_RevertsOnExpiredDeadline() public {
        uint256 value = 1000 ether;
        uint256 deadline = block.timestamp - 1; // Expired
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.expectRevert(
            abi.encodeWithSelector(PermitToken.ExpiredDeadline.selector, deadline, block.timestamp)
        );
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_Permit_RevertsOnReplayAttempt() public {
        uint256 value = 1000 ether;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // 1. First execution succeeds
        token.permit(owner, spender, value, deadline, v, r, s);

        // 2. Replay with identical signature fails because nonce advanced
        vm.expectRevert();
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_Permit_RevertsOnModifiedAmountOrSpender() public {
        uint256 value = 1000 ether;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // Attacker attempts to submit permit for 2000 ether instead of 1000 ether
        vm.expectRevert();
        token.permit(owner, spender, 2000 ether, deadline, v, r, s);

        // Attacker attempts to change spender to attacker address
        vm.expectRevert();
        token.permit(owner, address(0xBAD), value, deadline, v, r, s);
    }
}
