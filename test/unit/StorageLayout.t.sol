// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {UnpackedStorage, PackedStorage} from "../../src/02_storage_layout/StoragePackingExperiment.sol";
import {MappingSlotCalculator} from "../../src/02_storage_layout/MappingSlotCalculator.sol";
import {
    ImplementationV1,
    FlawedImplementationV2,
    CorrectImplementationV2,
    CollisionProxy
} from "../../src/02_storage_layout/StorageCollisionDemo.sol";

contract StorageLayoutTest is Test {
    UnpackedStorage internal unpacked;
    PackedStorage internal packed;
    MappingSlotCalculator internal calculator;

    function setUp() public {
        unpacked = new UnpackedStorage();
        packed = new PackedStorage();
        calculator = new MappingSlotCalculator();
    }

    function test_StoragePacking_GasMeasurement() public {
        uint256 gasStart = gasleft();
        unpacked.setAll(100, 200, 300, true);
        uint256 unpackedGas = gasStart - gasleft();

        gasStart = gasleft();
        packed.setSlot0(200, 50, 10, 20);
        uint256 packedGas = gasStart - gasleft();

        // Packed write is significantly cheaper due to fewer SSTORE operations
        assertLt(packedGas, unpackedGas);
    }

    function test_MappingSlotCalculation_MatchesAssemblySload() public {
        address user = address(0xCAFE);
        uint256 amount = 1_000_000 ether;

        calculator.setBalance(user, amount);

        // Compute slot via formula: keccak256(abi.encode(user, 0))
        bytes32 computedSlot = calculator.computeMappingSlot(user, 0);

        // Read raw storage at that computed slot
        bytes32 rawValue = calculator.readStorageSlotAssembly(computedSlot);

        assertEq(uint256(rawValue), amount, "Calculated mapping slot value must match raw SLOAD value");
    }

    function test_NestedMappingSlotCalculation_MatchesAssemblySload() public {
        address owner = address(0xAAAA);
        address spender = address(0xBBBB);
        uint256 allowance = 500 ether;

        calculator.setAllowance(owner, spender, allowance);

        // Allowances mapping is at slot 1
        bytes32 computedSlot = calculator.computeNestedMappingSlot(owner, spender, 1);
        bytes32 rawValue = calculator.readStorageSlotAssembly(computedSlot);

        assertEq(uint256(rawValue), allowance, "Calculated nested mapping slot value must match raw SLOAD");
    }

    function test_DynamicArraySlotCalculation_MatchesAssemblySload() public {
        calculator.pushArray(111);
        calculator.pushArray(222);
        calculator.pushArray(333);

        // Slot 2 stores array length
        bytes32 lengthSlot = bytes32(uint256(2));
        bytes32 rawLength = calculator.readStorageSlotAssembly(lengthSlot);
        assertEq(uint256(rawLength), 3, "Array length in slot 2 must be 3");

        // Element at index 1 is at keccak256(abi.encode(2)) + 1
        bytes32 elementSlot = calculator.computeArrayElementSlot(2, 1);
        bytes32 rawElem = calculator.readStorageSlotAssembly(elementSlot);
        assertEq(uint256(rawElem), 222, "Element slot value must match array[1]");
    }

    function test_StorageCollision_CorruptsState() public {
        ImplementationV1 v1 = new ImplementationV1();
        FlawedImplementationV2 flawedV2 = new FlawedImplementationV2();
        CollisionProxy proxy = new CollisionProxy();

        // 1. Initialize proxy using V1
        proxy.setImplementation(address(v1));
        address(proxy).call(abi.encodeWithSelector(ImplementationV1.initialize.selector, address(0x999), 30));

        // STORAGE COLLISION OCCURRED:
        // ImplementationV1 wrote owner to Slot 0 and feeRate (30) to Slot 1.
        // But in Proxy, Slot 0 was currentImplementation and Slot 1 was owner!
        // Therefore, currentImplementation was corrupted to 0x999, and owner became 0x00...1e (30)!
        assertEq(proxy.currentImplementation(), address(0x999), "Slot 0 (currentImplementation) corrupted by owner write");
        assertEq(proxy.owner(), address(uint160(30)), "Slot 1 (owner) corrupted by feeRate write");

        // 2. Point to flawed V2
        proxy.setImplementation(address(flawedV2));
        address implementationBeforePause = proxy.currentImplementation();
        assertEq(implementationBeforePause, address(flawedV2));

        address(proxy).call(abi.encodeWithSelector(FlawedImplementationV2.pause.selector));

        // Flawed V2 pause() writes boolean 0x01 into the first byte of Slot 0.
        // This mutates the lower byte of the implementation address, corrupting it!
        address implementationAfterPause = proxy.currentImplementation();
        assertTrue(implementationAfterPause != implementationBeforePause, "Implementation pointer was corrupted by boolean write to slot 0");
    }
}
