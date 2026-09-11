// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {UnpackedStorage, PackedStorage} from "../../src/02_storage_layout/StoragePackingExperiment.sol";
import {CalldataVsMemory} from "../../src/03_calldata_memory/CalldataVsMemory.sol";
import {Project8_YulOptimizedMath} from "../../src/05_mini_projects/Project8_YulOptimizedMath.sol";

contract GasComparisonTarget {
    error CustomError(uint256 x);

    uint256 public storageVal = 100;
    uint256 public immutable immutableVal = 100;

    function revertWithString(uint256 x) external pure {
        require(x > 1000, "Value must be strictly greater than one thousand");
    }

    function revertWithCustomError(uint256 x) external pure {
        if (x <= 1000) revert CustomError(x);
    }

    function readStorage() external view returns (uint256) {
        return storageVal;
    }

    function readImmutable() external view returns (uint256) {
        return immutableVal;
    }
}

contract GasBenchmarksTest is Test {
    UnpackedStorage internal unpacked;
    PackedStorage internal packed;
    CalldataVsMemory internal calldataVsMemory;
    GasComparisonTarget internal gasTarget;
    Project8_YulOptimizedMath internal yulMath;

    function setUp() public {
        unpacked = new UnpackedStorage();
        packed = new PackedStorage();
        calldataVsMemory = new CalldataVsMemory();
        gasTarget = new GasComparisonTarget();
        yulMath = new Project8_YulOptimizedMath();
    }

    function test_Benchmark_StoragePacking() public {
        // Cold write unpacked
        uint256 g1 = gasleft();
        unpacked.setAll(100, 200, 300, true);
        uint256 unpackedCold = g1 - gasleft();

        // Cold write packed (Slot 0)
        uint256 g2 = gasleft();
        packed.setSlot0(100, 200, 300, 400);
        uint256 packedCold = g2 - gasleft();

        emit log_named_uint("Unpacked 4-Slot Cold SSTORE Gas", unpackedCold);
        emit log_named_uint("Packed 1-Slot Cold SSTORE Gas", packedCold);
        assertLt(packedCold, unpackedCold);
    }

    function test_Benchmark_CustomErrorVsStringRevert() public {
        // Measure string revert
        uint256 g1 = gasleft();
        try gasTarget.revertWithString(50) {} catch {}
        uint256 stringRevertGas = g1 - gasleft();

        // Measure custom error revert
        uint256 g2 = gasleft();
        try gasTarget.revertWithCustomError(50) {} catch {}
        uint256 customErrorGas = g2 - gasleft();

        emit log_named_uint("Require String Revert Gas", stringRevertGas);
        emit log_named_uint("Custom Error Revert Gas", customErrorGas);
        assertLt(customErrorGas, stringRevertGas);
    }

    function test_Benchmark_ImmutableVsStorageRead() public {
        uint256 g1 = gasleft();
        gasTarget.readStorage();
        uint256 storageReadGas = g1 - gasleft();

        uint256 g2 = gasleft();
        gasTarget.readImmutable();
        uint256 immutableReadGas = g2 - gasleft();

        emit log_named_uint("SLOAD Storage Read Gas", storageReadGas);
        emit log_named_uint("Code-embedded Immutable Read Gas", immutableReadGas);
        assertLt(immutableReadGas, storageReadGas);
    }

    function test_Benchmark_YulVsSolidityMath() public {
        uint256 g1 = gasleft();
        yulMath.wmulSolidity(2 ether, 3 ether);
        uint256 solidityMathGas = g1 - gasleft();

        uint256 g2 = gasleft();
        yulMath.wmul(2 ether, 3 ether);
        uint256 yulMathGas = g2 - gasleft();

        emit log_named_uint("Solidity Wmul Gas", solidityMathGas);
        emit log_named_uint("Yul Wmul Gas", yulMathGas);
    }
}
