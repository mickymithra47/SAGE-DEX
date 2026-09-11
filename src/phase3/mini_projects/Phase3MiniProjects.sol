// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../phase2/interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {Math} from "../libraries/Math.sol";
import {SageMath} from "../libraries/SageMath.sol";
import {SageERC20} from "../core/SageERC20.sol";
import {SagePair} from "../core/SagePair.sol";
import {SageFactory} from "../core/SageFactory.sol";
import {ISageCallee} from "../interfaces/ISageAMM.sol";

// ==========================================
// MINI PROJECT 1: MATH LIBRARY & SQRT
// ==========================================
contract Project1_MathLibrary {
    function calculateSqrt(uint256 y) external pure returns (uint256) {
        return Math.sqrt(y);
    }

    function calculateMin(uint256 x, uint256 y) external pure returns (uint256) {
        return Math.min(x, y);
    }
}

// ==========================================
// MINI PROJECT 2: SWAP CALCULATOR
// ==========================================
contract Project2_SwapCalculator {
    function computeAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256) {
        return SageMath.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function computeAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256) {
        return SageMath.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function computePriceImpactBps(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 impactBps) {
        uint256 amountOut = SageMath.getAmountOut(amountIn, reserveIn, reserveOut);
        // Ideal spot output = (amountIn * reserveOut) / reserveIn
        uint256 idealOut = (amountIn * reserveOut) / reserveIn;
        if (idealOut > amountOut) {
            impactBps = ((idealOut - amountOut) * 10_000) / idealOut;
        }
    }
}

// ==========================================
// MINI PROJECT 3: LIQUIDITY CALCULATOR
// ==========================================
contract Project3_LiquidityCalculator {
    function quoteDeposit(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB) {
        return SageMath.quote(amountA, reserveA, reserveB);
    }

    function computeInitialLiquidity(uint256 amount0, uint256 amount1) external pure returns (uint256 liquidity) {
        uint256 initial = Math.sqrt(amount0 * amount1);
        require(initial > 1000, "Below minimum liquidity");
        liquidity = initial - 1000;
    }

    function computeSubsequentLiquidity(
        uint256 amount0,
        uint256 amount1,
        uint256 reserve0,
        uint256 reserve1,
        uint256 totalSupply
    ) external pure returns (uint256) {
        return Math.min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1);
    }
}

// ==========================================
// MINI PROJECT 4: MINIMAL PAIR CONTRACT
// ==========================================
contract Project4_MinimalPair {
    using SafeTokenTransfer for IERC20;

    address public token0;
    address public token1;
    uint256 public reserve0;
    uint256 public reserve1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
        if (amount0Out > 0) IERC20(token0).safeTransfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).safeTransfer(to, amount1Out);

        uint256 bal0 = IERC20(token0).balanceOf(address(this));
        uint256 bal1 = IERC20(token1).balanceOf(address(this));

        require(bal0 * bal1 >= reserve0 * reserve1, "K Invariant Violation");

        reserve0 = bal0;
        reserve1 = bal1;
    }
}

// ==========================================
// MINI PROJECT 5: FACTORY + PAIR SYSTEM
// ==========================================
contract Project5_FactoryPairSystem {
    SageFactory public factory;

    constructor() {
        factory = new SageFactory(msg.sender);
    }

    function deployPair(address tokenA, address tokenB) external returns (address pair) {
        return factory.createPair(tokenA, tokenB);
    }

    function getPairAddress(address tokenA, address tokenB) external view returns (address) {
        return factory.getPair(tokenA, tokenB);
    }
}

// ==========================================
// MINI PROJECT 6: LP SHARE ACCOUNTING
// ==========================================
contract Project6_LPShareAccounting is SageERC20 {
    address public immutable token0;
    address public immutable token1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function mintShares(address to, uint256 amount0, uint256 amount1, uint256 r0, uint256 r1) external returns (uint256 shares) {
        if (totalSupply == 0) {
            shares = Math.sqrt(amount0 * amount1) - 1000;
            _mint(address(0), 1000); // Lock 1000 to zero address
        } else {
            shares = Math.min((amount0 * totalSupply) / r0, (amount1 * totalSupply) / r1);
        }
        _mint(to, shares);
    }
}

// ==========================================
// MINI PROJECT 7: COMPLETE SWAP ENGINE
// ==========================================
contract Project7_CompleteSwapEngine is ISageCallee {
    using SafeTokenTransfer for IERC20;

    bool public flashSwapCalled;

    function executeSwap(
        SagePair pair,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        address to
    ) external returns (uint256 amountOut) {
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        bool isZero = tokenIn == pair.token0();
        (uint112 rIn, uint112 rOut) = isZero ? (r0, r1) : (r1, r0);

        amountOut = SageMath.getAmountOut(amountIn, rIn, rOut);
        require(amountOut >= amountOutMin, "Slippage");

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(pair), amountIn);
        if (isZero) {
            pair.swap(0, amountOut, to, new bytes(0));
        } else {
            pair.swap(amountOut, 0, to, new bytes(0));
        }
    }

    // Flash swap callback execution
    function sageCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        flashSwapCalled = true;
        address tokenToRepay = abi.decode(data, (address));
        uint256 repayAmount = amount0 > 0 ? (amount0 * 1004) / 1000 : (amount1 * 1004) / 1000;
        IERC20(tokenToRepay).safeTransfer(msg.sender, repayAmount);
    }
}

// ==========================================
// MINI PROJECT 8: COMPLETE LIQUIDITY LIFECYCLE
// ==========================================
contract Project8_CompleteLiquidityLifecycle {
    using SafeTokenTransfer for IERC20;

    function addLiquidityDirect(
        SagePair pair,
        uint256 amount0,
        uint256 amount1,
        address to
    ) external returns (uint256 liquidity) {
        IERC20(pair.token0()).safeTransferFrom(msg.sender, address(pair), amount0);
        IERC20(pair.token1()).safeTransferFrom(msg.sender, address(pair), amount1);
        liquidity = pair.mint(to);
    }

    function removeLiquidityDirect(
        SagePair pair,
        uint256 liquidity,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        IERC20(address(pair)).safeTransferFrom(msg.sender, address(pair), liquidity);
        (amount0, amount1) = pair.burn(to);
    }
}

// ==========================================
// MINI PROJECT 9: ADVERSARIAL AMM LABORATORY
// ==========================================
contract Project9_AdversarialAMMLab {
    using SafeTokenTransfer for IERC20;

    // Probes swap resilience against Fee-on-Transfer tokens
    function probeFeeOnTransferSwap(
        SagePair pair,
        address fotToken,
        uint256 transferAmount
    ) external returns (uint256 balanceDeltaInPool) {
        uint256 balBefore = IERC20(fotToken).balanceOf(address(pair));
        IERC20(fotToken).safeTransferFrom(msg.sender, address(pair), transferAmount);
        uint256 balAfter = IERC20(fotToken).balanceOf(address(pair));
        balanceDeltaInPool = balAfter - balBefore;
    }
}

// ==========================================
// MINI PROJECT 10: STATEFUL INVARIANT AMM
// ==========================================
contract Project10_StatefulInvariantAMM {
    function verifyKInvariant(
        uint256 balance0,
        uint256 balance1,
        uint256 amount0In,
        uint256 amount1In,
        uint112 reserve0,
        uint112 reserve1
    ) external pure returns (bool satisfiesK) {
        uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
        uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
        satisfiesK = (balance0Adjusted * balance1Adjusted >= uint256(reserve0) * reserve1 * (1000 ** 2));
    }
}
