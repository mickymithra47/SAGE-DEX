// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {TokenAccountingMath} from "../../../src/phase2/libraries/TokenAccountingMath.sol";

contract TokenFuzzTest is Test {
    ERC20Token internal token;

    function setUp() public {
        token = new ERC20Token("Fuzz Token", "FUZZ", 18, 1_000_000_000 ether);
    }

    // Fuzz Property: Total supply conservation across arbitrary transfer chains
    function testFuzz_Token_SupplyConservation(uint256 amount1, uint256 amount2) public {
        amount1 = bound(amount1, 1, 500_000_000 ether);
        amount2 = bound(amount2, 1, amount1);

        address alice = address(0xAAAA);
        address bob = address(0xBBBB);

        token.transfer(alice, amount1);
        vm.prank(alice);
        token.transfer(bob, amount2);

        uint256 sumOfBalances = token.balanceOf(address(this)) + token.balanceOf(alice) + token.balanceOf(bob);
        assertEq(sumOfBalances, token.totalSupply(), "Sum of all balances must equal totalSupply");
    }

    // Fuzz Property: Decimal conversion round-trip invariance (toWad -> fromWad preserves value)
    function testFuzz_Math_DecimalConversionRoundTrip(uint256 rawAmount, uint8 dec) public pure {
        // Test common token decimals: 6, 8, 12, 18
        dec = uint8(bound(uint256(dec), 6, 18));
        rawAmount = bound(rawAmount, 1, 1_000_000_000 * 10 ** dec);

        uint256 inWad = TokenAccountingMath.toWad(rawAmount, dec);
        uint256 backToRaw = TokenAccountingMath.fromWad(inWad, dec);

        assertEq(backToRaw, rawAmount, "Round trip decimal scaling must preserve exact raw token value");
    }

    // Fuzz Property: mulDivUp is always >= mulDivDown
    function testFuzz_Math_MulDivRoundingBounds(uint256 a, uint256 b, uint256 denominator) public pure {
        a = bound(a, 0, 1e25);
        b = bound(b, 0, 1e25);
        denominator = bound(denominator, 1, 1e25);

        uint256 down = TokenAccountingMath.mulDivDown(a, b, denominator);
        uint256 up = TokenAccountingMath.mulDivUp(a, b, denominator);

        assertGe(up, down, "mulDivUp must always equal or exceed mulDivDown");
        assertLe(up - down, 1, "Rounding discrepancy between up and down must not exceed 1 unit");
    }
}
