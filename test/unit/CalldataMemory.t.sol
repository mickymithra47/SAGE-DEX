// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {CalldataVsMemory, FreeMemoryPointerDemo} from "../../src/03_calldata_memory/CalldataVsMemory.sol";

contract CalldataMemoryTest is Test {
    CalldataVsMemory internal target;
    FreeMemoryPointerDemo internal fmpDemo;

    function setUp() public {
        target = new CalldataVsMemory();
        fmpDemo = new FreeMemoryPointerDemo();
    }

    function test_CalldataVsMemory_GasEfficiency() public view {
        uint256[] memory data = new uint256[](100);
        for (uint256 i = 0; i < 100; i++) {
            data[i] = i + 1;
        }

        uint256 sumCall = target.sumCalldata(data);
        uint256 sumMem = target.sumMemory(data);

        assertEq(sumCall, sumMem);
        assertEq(sumCall, 5050);
    }

    function test_CalldataSlice_GasEfficiency() public view {
        uint256[] memory data = new uint256[](50);
        for (uint256 i = 0; i < 50; i++) {
            data[i] = 10;
        }

        uint256 total = target.sliceCalldataSum(data, 10, 20);
        assertEq(total, 100); // 10 elements of value 10
    }

    function test_FreeMemoryPointer_AdvancesUponAllocation() public view {
        (uint256 fmpBefore, uint256 fmpAfter) = fmpDemo.inspectFreeMemoryPointer();

        // Standard initial free memory pointer is 0x80 (128 bytes)
        assertEq(fmpBefore, 0x80);
        // After allocating array of length 5 (32 bytes length + 5*32 bytes elements = 192 bytes = 0xc0)
        // 0x80 + 0xc0 = 0x140
        assertEq(fmpAfter, 0x140);
    }

    function test_MemoryExpansion_GasCostFormula() public view {
        // Words: 1000 words = 32,000 bytes
        // Cost = 3 * 1000 + (1000^2 / 512) = 3000 + 1953 = 4953 gas
        uint256 gasCost = fmpDemo.calculateMemoryExpansionGas(1000);
        assertEq(gasCost, 4953);
    }
}
