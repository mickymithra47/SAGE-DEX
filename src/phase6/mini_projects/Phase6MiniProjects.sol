// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageFactory, ISagePair} from "../../phase3/interfaces/ISageAMM.sol";
import {SagePricingLibrary} from "../../phase5/libraries/SagePricingLibrary.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {IERC20, IWETH} from "../../phase2/interfaces/IERC20.sol";

// ==========================================
// MINI PROJECT 1: SINGLE-HOP EXACT-INPUT ROUTER
// ==========================================
contract Project1_SingleHopExactInputRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function swapExactInput(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address to
    ) external returns (uint256 amountOut) {
        address pair = ISageFactory(factory).getPair(tokenIn, tokenOut);
        (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
        (uint256 rIn, uint256 rOut) = tokenIn == ISagePair(pair).token0() ? (r0, r1) : (r1, r0);

        amountOut = SagePricingLibrary.getAmountOut(amountIn, rIn, rOut);
        require(amountOut >= minAmountOut, "InsufficientOutput");

        SafeTokenTransfer.safeTransferFrom(IERC20(tokenIn), msg.sender, pair, amountIn);
        (uint256 out0, uint256 out1) = tokenIn == ISagePair(pair).token0() ? (uint256(0), amountOut) : (amountOut, uint256(0));
        ISagePair(pair).swap(out0, out1, to, new bytes(0));
    }
}

// ==========================================
// MINI PROJECT 2: SINGLE-HOP EXACT-OUTPUT ROUTER
// ==========================================
contract Project2_SingleHopExactOutputRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function swapExactOutput(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 maxAmountIn,
        address to
    ) external returns (uint256 amountIn) {
        address pair = ISageFactory(factory).getPair(tokenIn, tokenOut);
        (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
        (uint256 rIn, uint256 rOut) = tokenIn == ISagePair(pair).token0() ? (r0, r1) : (r1, r0);

        amountIn = SagePricingLibrary.getAmountIn(amountOut, rIn, rOut);
        require(amountIn <= maxAmountIn, "ExcessiveInput");

        SafeTokenTransfer.safeTransferFrom(IERC20(tokenIn), msg.sender, pair, amountIn);
        (uint256 out0, uint256 out1) = tokenIn == ISagePair(pair).token0() ? (uint256(0), amountOut) : (amountOut, uint256(0));
        ISagePair(pair).swap(out0, out1, to, new bytes(0));
    }
}

// ==========================================
// MINI PROJECT 3: MULTI-HOP EXACT-INPUT ROUTER
// ==========================================
contract Project3_MultiHopExactInputRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function swapMultiHopExactInput(
        uint256 amountIn,
        address[] calldata path,
        address to
    ) external returns (uint256[] memory amounts) {
        amounts = SagePricingLibrary.getAmountsOut(factory, amountIn, path);
        address firstPair = ISageFactory(factory).getPair(path[0], path[1]);
        SafeTokenTransfer.safeTransferFrom(IERC20(path[0]), msg.sender, firstPair, amounts[0]);

        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = ISageFactory(factory).getPair(path[i], path[i + 1]);
            address token0 = ISagePair(pair).token0();
            uint256 amountOut = amounts[i + 1];
            (uint256 out0, uint256 out1) = path[i] == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            address recipient = i < path.length - 2 ? ISageFactory(factory).getPair(path[i + 1], path[i + 2]) : to;
            ISagePair(pair).swap(out0, out1, recipient, new bytes(0));
        }
    }
}

// ==========================================
// MINI PROJECT 4: MULTI-HOP EXACT-OUTPUT ROUTER
// ==========================================
contract Project4_MultiHopExactOutputRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function swapMultiHopExactOutput(
        uint256 amountOut,
        address[] calldata path,
        address to
    ) external returns (uint256[] memory amounts) {
        amounts = SagePricingLibrary.getAmountsIn(factory, amountOut, path);
        address firstPair = ISageFactory(factory).getPair(path[0], path[1]);
        SafeTokenTransfer.safeTransferFrom(IERC20(path[0]), msg.sender, firstPair, amounts[0]);

        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = ISageFactory(factory).getPair(path[i], path[i + 1]);
            address token0 = ISagePair(pair).token0();
            uint256 aOut = amounts[i + 1];
            (uint256 out0, uint256 out1) = path[i] == token0 ? (uint256(0), aOut) : (aOut, uint256(0));
            address recipient = i < path.length - 2 ? ISageFactory(factory).getPair(path[i + 1], path[i + 2]) : to;
            ISagePair(pair).swap(out0, out1, recipient, new bytes(0));
        }
    }
}

// ==========================================
// MINI PROJECT 5: SAFE TOKEN TRANSFER HARNESS
// ==========================================
contract Project5_SafeTokenTransferLibrary {
    function executeSafeTransferFrom(address token, address from, address to, uint256 value) external {
        SafeTokenTransfer.safeTransferFrom(IERC20(token), from, to, value);
    }
}

// ==========================================
// MINI PROJECT 6: NATIVE ETH / WETH INTEGRATION
// ==========================================
contract Project6_NativeETHWETHIntegration {
    address public immutable WETH;

    constructor(address _weth) {
        WETH = _weth;
    }

    receive() external payable {}

    function wrapETH() external payable {
        IWETH(WETH).deposit{value: msg.value}();
    }

    function unwrapETH(uint256 amount, address to) external {
        IWETH(WETH).withdraw(amount);
        (bool success, ) = to.call{value: amount}("");
        require(success, "ETHTransferFailed");
    }
}

// ==========================================
// MINI PROJECT 7: SLIPPAGE & DEADLINE PROTECTION
// ==========================================
contract Project7_SlippageDeadlineProtection {
    function verifyBounds(uint256 actual, uint256 minExpected, uint256 deadline) external view {
        require(block.timestamp <= deadline, "Expired");
        require(actual >= minExpected, "SlippageExceeded");
    }
}

// ==========================================
// MINI PROJECT 8: CALLBACK VALIDATION
// ==========================================
contract Project8_CallbackValidation {
    address public immutable expectedPair;

    constructor(address _pair) {
        expectedPair = _pair;
    }

    function validateCaller(address caller) external view returns (bool isValid) {
        isValid = (caller == expectedPair);
    }
}

// ==========================================
// MINI PROJECT 9: MALICIOUS TOKEN TEST HARNESS
// ==========================================
contract Project9_MaliciousTokenLaboratory {
    function safeTransferTest(address token, address to, uint256 value) external {
        SafeTokenTransfer.safeTransfer(IERC20(token), to, value);
    }
}

// ==========================================
// MINI PROJECT 10: ATOMIC FAILURE HARNESS
// ==========================================
contract Project10_AtomicFailureLaboratory {
    function atomicOperation(bool shouldFail) external pure {
        if (shouldFail) revert("AtomicFail");
    }
}

// ==========================================
// MINI PROJECT 11: QUOTE VS EXECUTION DIFFERENTIAL
// ==========================================
contract Project11_QuoteVsExecutionDifferentialTester {
    function checkEquivalence(uint256 quotedOut, uint256 executedOut) external pure returns (bool) {
        return quotedOut == executedOut;
    }
}

// ==========================================
// MINI PROJECT 12: COMPLETE MINIMAL SWAP ROUTER
// ==========================================
contract Project12_CompleteMinimalSwapRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}
