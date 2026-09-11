// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Project2_ERC20Token} from "../../src/05_mini_projects/Project2_ERC20Token.sol";
import {Project3_Vault} from "../../src/05_mini_projects/Project3_Vault.sol";
import {Project8_YulOptimizedMath} from "../../src/05_mini_projects/Project8_YulOptimizedMath.sol";
import {SecureFeeCalculator} from "../../src/06_security_lab/PrecisionLoss/PrecisionLossLab.sol";

contract ProtocolFuzzTest is Test {
    Project2_ERC20Token internal token;
    Project3_Vault internal vault;
    Project8_YulOptimizedMath internal yulMath;
    SecureFeeCalculator internal feeCalc;

    function setUp() public {
        token = new Project2_ERC20Token("Fuzz Token", "FZT", 18, 1_000_000_000 ether);
        vault = new Project3_Vault(token, "Fuzz Vault", "vFZT");
        yulMath = new Project8_YulOptimizedMath();
        feeCalc = new SecureFeeCalculator();
    }

    // Fuzz test ERC20 supply conservation: balance(Alice) + balance(Bob) == initialTransfer
    function testFuzz_ERC20_TransferConservation(uint256 amount) public {
        // Bound amount between 1 wei and total supply
        amount = bound(amount, 1, 1_000_000_000 ether);

        address alice = address(0xAA11);
        address bob = address(0xBB22);

        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);

        uint256 sendToBob = amount / 2;
        vm.prank(alice);
        token.transfer(bob, sendToBob);

        assertEq(token.balanceOf(alice) + token.balanceOf(bob), amount, "Sum of balances must conserve supply");
    }

    // Fuzz test Vault share roundtrip: user withdrawing immediately after deposit never extracts more than deposited
    function testFuzz_Vault_NoFreeValueExtraction(uint256 depositAmount) public {
        depositAmount = bound(depositAmount, 1e6, 1_000_000 ether);

        address user = address(0x9999);
        token.transfer(user, depositAmount);

        vm.startPrank(user);
        token.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, user);

        uint256 assetsReceived = vault.withdraw(shares, user, user);
        vm.stopPrank();

        assertLe(assetsReceived, depositAmount, "User cannot extract more assets than deposited");
    }

    // Fuzz test Fixed Point WAD multiplication symmetry: wmul(x, y) == wmul(y, x)
    function testFuzz_YulMath_WmulCommutative(uint256 x, uint256 y) public view {
        // Prevent overflow by bounding product
        x = bound(x, 0, 1e25);
        y = bound(y, 0, 1e25);

        uint256 res1 = yulMath.wmul(x, y);
        uint256 res2 = yulMath.wmul(y, x);

        assertEq(res1, res2, "WAD multiplication must be commutative");
    }

    // Fuzz test fee calculation bounds: fee <= amount when feeBps <= 10000
    function testFuzz_FeeCalculation_UpperBound(uint256 amount, uint256 feeBps) public view {
        amount = bound(amount, 0, type(uint128).max);
        feeBps = bound(feeBps, 0, 10_000);

        uint256 fee = feeCalc.calculateFeeDown(amount, feeBps);
        assertLe(fee, amount, "Fee must never exceed principal amount");
    }
}
