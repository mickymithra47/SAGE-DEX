// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {PermitToken} from "../../../src/phase2/token/PermitToken.sol";

contract EIP2612PermitTest is Test {
    PermitToken internal token;
    uint256 internal alicePrivateKey = 0xA11CE;
    address internal alice;
    address internal spender = address(0xB0B);

    function setUp() public {
        alice = vm.addr(alicePrivateKey);
        token = new PermitToken("Token A", "TKNA", 18, 1_000_000 ether);
        token.transfer(alice, 10_000 ether);
    }

    function test_EIP2612_PermitValidation() public {
        uint256 value = 1000 ether;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(alice);

        bytes32 PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, alice, spender, value, nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        // Third party submits permit
        token.permit(alice, spender, value, deadline, v, r, s);

        assertEq(token.allowance(alice, spender), value);
        assertEq(token.nonces(alice), nonce + 1);
    }
}
