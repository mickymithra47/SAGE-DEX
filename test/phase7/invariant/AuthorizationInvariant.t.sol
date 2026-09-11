// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Permit2} from "../../../src/phase7/core/Permit2.sol";
import {IPermit2} from "../../../src/phase7/interfaces/IPermit2.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract AuthorizationHandler is Test {
    Permit2 public immutable permit2;
    ERC20Token public immutable token;
    uint256 public immutable alicePrivateKey;
    address public immutable alice;
    address public immutable spender;
    uint256 public nonceCounter;

    constructor(
        Permit2 _permit2,
        ERC20Token _token,
        uint256 _pk,
        address _alice,
        address _spender
    ) {
        permit2 = _permit2;
        token = _token;
        alicePrivateKey = _pk;
        alice = _alice;
        spender = _spender;
    }

    function executeSignatureTransfer(uint256 amount) external {
        amount = bound(amount, 1 ether, 100 ether);
        nonceCounter++;
        uint256 nonce = nonceCounter;
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

contract AuthorizationInvariantTest is Test {
    Permit2 internal permit2;
    ERC20Token internal token;
    AuthorizationHandler internal handler;
    uint256 internal alicePrivateKey = 0xA11CE;
    address internal alice;
    address internal spender = address(0xB0B);

    function setUp() public {
        alice = vm.addr(alicePrivateKey);
        permit2 = new Permit2();
        token = new ERC20Token("Token A", "TKNA", 18, 1_000_000_000 ether);

        token.transfer(alice, 500_000_000 ether);

        vm.prank(alice);
        token.approve(address(permit2), type(uint256).max);

        handler = new AuthorizationHandler(permit2, token, alicePrivateKey, alice, spender);
        targetContract(address(handler));
    }

    // Invariant: Total token balance of Alice and Spender is strictly conserved
    function invariant_TokenSupplyConserved() public view {
        uint256 total = token.balanceOf(alice) + token.balanceOf(spender);
        assertEq(total, 500_000_000 ether);
    }
}
