// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {CallDemoTarget, CallDemoCaller} from "../../src/01_evm_calls/CallDemo.sol";
import {StaticcallTarget, StaticcallDemoCaller} from "../../src/01_evm_calls/StaticcallDemo.sol";
import {DelegatecallLogic, DelegatecallProxy} from "../../src/01_evm_calls/DelegatecallDemo.sol";
import {CreateFactory, Create2Deployer, ChildInstance} from "../../src/01_evm_calls/CreateDemo.sol";

contract EVMCallsTest is Test {
    CallDemoTarget internal callTarget;
    CallDemoCaller internal caller;

    StaticcallTarget internal staticTarget;
    StaticcallDemoCaller internal staticCaller;

    DelegatecallLogic internal logic;
    DelegatecallProxy internal proxy;

    CreateFactory internal createFactory;
    Create2Deployer internal create2Deployer;

    function setUp() public {
        callTarget = new CallDemoTarget();
        caller = new CallDemoCaller();

        staticTarget = new StaticcallTarget(42);
        staticCaller = new StaticcallDemoCaller();

        logic = new DelegatecallLogic();
        proxy = new DelegatecallProxy();

        createFactory = new CreateFactory();
        create2Deployer = new Create2Deployer();

        vm.deal(address(caller), 10 ether);
        vm.deal(address(this), 10 ether);
    }

    // --- CALL TESTS ---
    function test_Call_ExecutesAndChangesTargetState() public {
        vm.prank(address(caller));
        (bool success, bytes memory data) = caller.performCall{value: 1 ether}(
            address(callTarget),
            "Hello EVM"
        );

        assertTrue(success);
        assertEq(callTarget.valueReceived(), 1 ether);
        assertEq(callTarget.lastCaller(), address(caller));
        assertEq(callTarget.message(), "Hello EVM");

        (address returnedSender, uint256 returnedValue, ) = abi.decode(data, (address, uint256, uint256));
        assertEq(returnedSender, address(caller));
        assertEq(returnedValue, 1 ether);
    }

    function test_Call_CapturesRevertData() public {
        (bool success, bytes memory data) = caller.performRevertingCall(
            address(callTarget),
            "Expected Failure"
        );

        assertFalse(success);
        bytes4 errorSelector = bytes4(data);
        assertEq(errorSelector, CallDemoTarget.TargetReverted.selector);
    }

    // --- STATICCALL TESTS ---
    function test_Staticcall_ReadsStateSuccessfully() public view {
        uint256 result = staticCaller.performStaticcall(address(staticTarget), 2);
        // (42 * 2) + 100 = 184
        assertEq(result, 184);
    }

    function test_Staticcall_RevertsOnStateMutationAttempt() public {
        (bool success, ) = staticCaller.attemptStateMutationViaStaticcall(address(staticTarget), 999);
        assertFalse(success, "STATICCALL must fail when target attempts state mutation");
        assertEq(staticTarget.stateVariable(), 100, "State must remain unchanged");
    }

    // --- DELEGATECALL TESTS ---
    function test_Delegatecall_MutatesProxyStorageWithCallerSender() public {
        address user = address(0xABCD);
        vm.deal(user, 1 ether);

        vm.prank(user);
        proxy.executeDelegatecall(address(logic), 777);

        // Proxy storage was modified
        assertEq(proxy.value(), 777);
        // msg.sender was preserved as `user`
        assertEq(proxy.sender(), user);
        // address(this) inside execution was the proxy, not logic contract
        assertEq(proxy.currentAddress(), address(proxy));

        // Logic contract storage remains 0
        assertEq(logic.value(), 0);
        assertEq(logic.sender(), address(0));
    }

    // --- CREATE vs CREATE2 TESTS ---
    function test_Create_DeploysChild() public {
        address child = createFactory.deployChild(12345);
        assertTrue(child != address(0));
        assertEq(ChildInstance(child).value(), 12345);
        assertEq(ChildInstance(child).creator(), address(createFactory));
    }

    function test_Create2_DeterministicAddressMatchesPrecomputation() public {
        bytes32 salt = bytes32(uint256(99999));
        uint256 initVal = 54321;

        address expectedAddress = create2Deployer.computeAddress(salt, initVal);
        address actualAddress = create2Deployer.deploy(salt, initVal);

        assertEq(actualAddress, expectedAddress, "CREATE2 deployed address must match precomputed hash");
        assertEq(ChildInstance(actualAddress).value(), 54321);
    }
}
