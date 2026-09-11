// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SagePermitRouter} from "../../../src/phase7/core/SagePermitRouter.sol";
import {Permit2} from "../../../src/phase7/core/Permit2.sol";
import {IPermit2} from "../../../src/phase7/interfaces/IPermit2.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {PermitToken} from "../../../src/phase2/token/PermitToken.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract RouterPermitSwapsTest is Test {
    SageFactory internal factory;
    WETH internal weth;
    Permit2 internal permit2;
    SagePermitRouter internal router;

    PermitToken internal tokenA;
    ERC20Token internal tokenB;
    SagePair internal pairAB;

    uint256 internal alicePrivateKey = 0xA11CE;
    address internal alice;

    function setUp() public {
        alice = vm.addr(alicePrivateKey);

        factory = new SageFactory(address(this));
        weth = new WETH();
        permit2 = new Permit2();
        router = new SagePermitRouter(address(factory), address(weth), address(permit2));

        tokenA = new PermitToken("Token A", "TKNA", 18, 10_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        pairAB = SagePair(factory.createPair(address(tokenA), address(tokenB)));

        tokenA.transfer(address(pairAB), 10_000 ether);
        tokenB.transfer(address(pairAB), 20_000 ether);
        pairAB.mint(address(this));

        tokenA.transfer(alice, 1000 ether);

        // Alice approves Permit2
        vm.prank(alice);
        tokenA.approve(address(permit2), type(uint256).max);
    }

    function test_Router_SwapExactTokensWithPermit() public {
        uint256 amountIn = 10 ether;
        uint256 deadline = block.timestamp + 300;
        uint256 nonce = tokenA.nonces(alice);

        bytes32 PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, alice, address(router), amountIn, nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", tokenA.DOMAIN_SEPARATOR(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        vm.prank(alice);
        uint256[] memory amounts = router.swapExactTokensForTokensWithPermit(
            amountIn,
            19 ether,
            path,
            alice,
            deadline,
            v,
            r,
            s
        );

        assertTrue(amounts[1] >= 19 ether);
        assertEq(tokenB.balanceOf(alice), amounts[1]);
    }

    function test_Router_SwapExactTokensWithPermit2() public {
        uint256 amountIn = 10 ether;
        uint256 nonce = 42;
        uint256 deadline = block.timestamp + 300;

        IPermit2.PermitTransferFrom memory permitDetails = IPermit2.PermitTransferFrom({
            permitted: IPermit2.TokenPermissions({token: address(tokenA), amount: amountIn}),
            nonce: nonce,
            deadline: deadline
        });

        bytes32 dataHash = keccak256(
            abi.encode(
                permit2.PERMIT_TRANSFER_FROM_TYPEHASH(),
                keccak256(abi.encode(permit2.TOKEN_PERMISSIONS_TYPEHASH(), address(tokenA), amountIn)),
                address(router),
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), dataHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        vm.prank(alice);
        uint256[] memory amounts = router.swapExactTokensForTokensWithPermit2(
            amountIn,
            19 ether,
            path,
            alice,
            deadline,
            permitDetails,
            signature
        );

        assertTrue(amounts[1] >= 19 ether);
        assertEq(tokenB.balanceOf(alice), amounts[1]);
    }
}
