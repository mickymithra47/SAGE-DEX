// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Project1_StorageContract} from "../../src/05_mini_projects/Project1_StorageContract.sol";
import {Project2_ERC20Token} from "../../src/05_mini_projects/Project2_ERC20Token.sol";
import {Project3_Vault} from "../../src/05_mini_projects/Project3_Vault.sol";
import {Project4_Escrow} from "../../src/05_mini_projects/Project4_Escrow.sol";
import {Project5_DeterministicFactory, GenericChild} from "../../src/05_mini_projects/Project5_DeterministicFactory.sol";
import {Project6_CallbackProtocol, IProtocolCallback} from "../../src/05_mini_projects/Project6_CallbackProtocol.sol";
import {Project7_LowLevelCallLab} from "../../src/05_mini_projects/Project7_LowLevelCallLab.sol";
import {Project8_YulOptimizedMath} from "../../src/05_mini_projects/Project8_YulOptimizedMath.sol";
import {CallDemoTarget} from "../../src/01_evm_calls/CallDemo.sol";

// Mock borrower for Project 6 callback
contract MockBorrower is IProtocolCallback {
    Project6_CallbackProtocol public protocol;
    bool public attemptReentrancy;

    constructor(address payable _protocol) {
        protocol = Project6_CallbackProtocol(_protocol);
    }

    function execute(uint256 amount) external {
        protocol.flashLoan(amount, "");
    }

    function onCallback(uint256 amount, bytes calldata) external override returns (bytes32) {
        if (attemptReentrancy) {
            protocol.flashLoan(amount, "");
        }

        // Repay loan + fee (0.3%)
        uint256 fee = (amount * 30) / 10_000;
        (bool success, ) = payable(address(protocol)).call{value: amount + fee}("");
        require(success, "Repayment failed");

        return protocol.CALLBACK_SUCCESS();
    }

    receive() external payable {}
}

contract MiniProjectsTest is Test {
    // Project 1
    Project1_StorageContract internal project1;

    // Project 2 & 3
    Project2_ERC20Token internal token;
    Project3_Vault internal vault;

    // Project 4
    Project4_Escrow internal escrow;
    address internal buyer = address(0x1111);
    address internal seller = address(0x2222);
    address internal arbiter = address(0x3333);

    // Project 5
    Project5_DeterministicFactory internal factory;

    // Project 6
    Project6_CallbackProtocol internal callbackProtocol;
    MockBorrower internal borrower;

    // Project 7
    Project7_LowLevelCallLab internal callLab;

    // Project 8
    Project8_YulOptimizedMath internal yulMath;

    function setUp() public {
        project1 = new Project1_StorageContract(86400, 50, 1e18);

        token = new Project2_ERC20Token("Sage Token", "AKT", 18, 1_000_000 ether);
        vault = new Project3_Vault(token, "Sage Vault", "vAKT");

        vm.deal(buyer, 10 ether);
        vm.deal(seller, 10 ether);
        vm.deal(arbiter, 10 ether);

        vm.prank(buyer);
        escrow = new Project4_Escrow(seller, arbiter, 7 days);

        factory = new Project5_DeterministicFactory();

        callbackProtocol = new Project6_CallbackProtocol{value: 100 ether}();
        borrower = new MockBorrower(payable(address(callbackProtocol)));
        vm.deal(address(borrower), 10 ether);

        callLab = new Project7_LowLevelCallLab();
        yulMath = new Project8_YulOptimizedMath();
    }

    // --- PROJECT 1 TESTS ---
    function test_Project1_StorageAndEvents() public {
        project1.addEntry(100);
        project1.addEntry(200);

        assertEq(project1.entriesCount(), 2);
        assertEq(project1.getEntry(0), 100);
        assertEq(project1.getEntry(1), 200);

        vm.expectRevert(abi.encodeWithSelector(Project1_StorageContract.ArrayOutOfBounds.selector, 5, 2));
        project1.getEntry(5);
    }

    // --- PROJECT 2 TESTS ---
    function test_Project2_ERC20TransfersAndAllowances() public {
        address alice = address(0xAAAA);
        token.transfer(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);

        vm.prank(alice);
        token.approve(address(this), 500 ether);
        assertEq(token.allowance(alice, address(this)), 500 ether);

        token.transferFrom(alice, address(0xBEEF), 500 ether);
        assertEq(token.balanceOf(address(0xBEEF)), 500 ether);
        assertEq(token.balanceOf(alice), 500 ether);
    }

    // --- PROJECT 3 TESTS ---
    function test_Project3_VaultDepositAndWithdraw() public {
        address user = address(0x5555);
        token.transfer(user, 1000 ether);

        vm.startPrank(user);
        token.approve(address(vault), 1000 ether);
        uint256 shares = vault.deposit(1000 ether, user);
        assertGt(shares, 0);
        assertEq(vault.balanceOfShares(user), shares);

        uint256 assetsReceived = vault.withdraw(shares, user, user);
        assertEq(assetsReceived, 1000 ether);
        assertEq(vault.balanceOfShares(user), 0);
        vm.stopPrank();
    }

    // --- PROJECT 4 TESTS ---
    function test_Project4_EscrowSettlementFlow() public {
        vm.prank(buyer);
        escrow.fund{value: 5 ether}();
        assertEq(address(escrow).balance, 5 ether);

        uint256 sellerBalBefore = seller.balance;
        vm.prank(buyer);
        escrow.releaseToSeller();

        assertEq(seller.balance, sellerBalBefore + 5 ether);
        assertEq(uint8(escrow.state()), uint8(Project4_Escrow.EscrowState.Settled));
    }

    // --- PROJECT 5 TESTS ---
    function test_Project5_CREATE2DeploymentAndPrediction() public {
        bytes32 salt = keccak256("test-salt-1");
        address owner = address(0x999);
        uint256 id = 42;

        address expected = factory.computeAddress(salt, owner, id);
        address deployed = factory.deploy(salt, owner, id);

        assertEq(deployed, expected);
        assertEq(GenericChild(deployed).owner(), owner);
        assertEq(GenericChild(deployed).id(), 42);
    }

    // --- PROJECT 6 TESTS ---
    function test_Project6_CallbackExecutionAndFeeCollection() public {
        uint256 balanceBefore = address(callbackProtocol).balance;
        borrower.execute(10 ether);
        uint256 balanceAfter = address(callbackProtocol).balance;

        // Reserve increased by 0.3% fee = 0.03 ether
        assertEq(balanceAfter, balanceBefore + 0.03 ether);
    }

    // --- PROJECT 7 TESTS ---
    function test_Project7_LowLevelCallWithCustomRevertBubbling() public {
        CallDemoTarget target = new CallDemoTarget();
        bytes memory callPayload = abi.encodeWithSelector(CallDemoTarget.execute.selector, "LowLevel");

        bytes memory returnData = callLab.executeCall(address(target), callPayload, 0);
        (address caller, , ) = abi.decode(returnData, (address, uint256, uint256));
        assertEq(caller, address(callLab));

        // Test revert bubbling
        bytes memory revertPayload = abi.encodeWithSelector(CallDemoTarget.willRevert.selector, "Bubbled Error");
        vm.expectRevert(abi.encodeWithSelector(CallDemoTarget.TargetReverted.selector, "Bubbled Error"));
        callLab.executeCall(address(target), revertPayload, 0);
    }

    // --- PROJECT 8 TESTS ---
    function test_Project8_YulMathOperations() public view {
        // WAD mul: (2e18 * 3e18) / 1e18 = 6e18
        uint256 mulRes = yulMath.wmul(2 ether, 3 ether);
        assertEq(mulRes, 6 ether);

        // WAD div: (10e18 * 1e18) / 2e18 = 5e18
        uint256 divRes = yulMath.wdiv(10 ether, 2 ether);
        assertEq(divRes, 5 ether);

        // Sqrt: sqrt(144) = 12
        uint256 sqrtRes = yulMath.sqrtYul(144);
        assertEq(sqrtRes, 12);
    }
}
