// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {YulArithmetic} from "../../src/04_yul_lab/YulArithmetic.sol";
import {YulStorageOps, YulCallForwarder, YulVsSolidityBenchmark} from "../../src/04_yul_lab/YulStorageOps.sol";
import {CallDemoTarget} from "../../src/01_evm_calls/CallDemo.sol";

contract YulLabTest is Test {
    YulArithmetic internal yulMath;
    YulStorageOps internal yulStorage;
    YulVsSolidityBenchmark internal benchmark;

    function setUp() public {
        yulMath = new YulArithmetic();
        yulStorage = new YulStorageOps();
        benchmark = new YulVsSolidityBenchmark();
    }

    function test_YulArithmetic_SafeAdd() public view {
        uint256 result = yulMath.safeAdd(100, 200);
        assertEq(result, 300);
    }

    function test_YulArithmetic_SafeAddRevertsOnOverflow() public {
        vm.expectRevert(YulArithmetic.MathOverflow.selector);
        yulMath.safeAdd(type(uint256).max, 1);
    }

    function test_YulArithmetic_MulDivDown() public view {
        uint256 res = yulMath.mulDivDown(10 ether, 5 ether, 2 ether);
        assertEq(res, 25 ether);
    }

    function test_YulArithmetic_BitwisePacking() public view {
        uint128 high = 0x11112222333344445555666677778888;
        uint128 low = 0x9999AAAABBBBCCCCDDDDEEEEFFFF0000;

        bytes32 packed = yulMath.packTwoUint128(high, low);
        (uint128 unpackedHigh, uint128 unpackedLow) = yulMath.unpackTwoUint128(packed);

        assertEq(unpackedHigh, high);
        assertEq(unpackedLow, low);
    }

    function test_YulStorage_DirectSloadSstore() public {
        bytes32 testSlot = keccak256("sage.test.slot");
        bytes32 testVal = bytes32(uint256(0xCAFEBABE));

        yulStorage.setSlot(testSlot, testVal);
        bytes32 retrieved = yulStorage.getSlot(testSlot);

        assertEq(retrieved, testVal);
    }

    function test_YulStorage_TransientStorageTloadTstore() public {
        bytes32 testSlot = keccak256("sage.transient.slot");
        bytes32 testVal = bytes32(uint256(0xDEADBEEF));

        yulStorage.setTransientSlot(testSlot, testVal);
        bytes32 retrieved = yulStorage.getTransientSlot(testSlot);

        assertEq(retrieved, testVal);
    }

    function test_YulCallForwarder_BubblesRevertsAndReturns() public {
        CallDemoTarget target = new CallDemoTarget();
        YulCallForwarder forwarder = new YulCallForwarder(address(target));

        // Call target via forwarder
        (bool success, bytes memory data) = address(forwarder).call(
            abi.encodeWithSelector(CallDemoTarget.execute.selector, "Forwarded Msg")
        );
        assertTrue(success);

        (address caller, uint256 val, ) = abi.decode(data, (address, uint256, uint256));
        assertEq(caller, address(this));
        assertEq(val, 0);
    }
}
