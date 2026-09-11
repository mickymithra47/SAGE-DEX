// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISagePair, ISageCallee, ISageFactory} from "../interfaces/ISageAMM.sol";
import {SageERC20} from "./SageERC20.sol";
import {IERC20} from "../../phase2/interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {Math, UQ112x112} from "../libraries/Math.sol";

/**
 * @title SagePair
 * @notice Canonical Constant-Product AMM (x * y = k) Liquidity Pool Contract.
 */
contract SagePair is ISagePair, SageERC20 {
    using SafeTokenTransfer for IERC20;
    using UQ112x112 for uint224;

    // Custom Errors
    error Locked();
    error Unauthorized();
    error AlreadyInitialized();
    error InsufficientLiquidityMinted();
    error InsufficientLiquidityBurned();
    error InsufficientOutputAmount();
    error InsufficientLiquidity();
    error InsufficientInputAmount();
    error InvalidRecipient();
    error KInvariantViolation();
    error Overflow();

    uint256 public constant override MINIMUM_LIQUIDITY = 1000;

    address public override factory;
    address public override token0;
    address public override token1;

    // Packed Storage Slot (32 bytes total: 14 + 14 + 4)
    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint256 public override price0CumulativeLast;
    uint256 public override price1CumulativeLast;
    uint256 public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private unlocked = 1;

    modifier lock() {
        if (unlocked != 1) revert Locked();
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external override {
        if (msg.sender != factory) revert Unauthorized();
        if (token0 != address(0) || token1 != address(0)) revert AlreadyInitialized();
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view override returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) revert Overflow();

        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed;
        unchecked {
            timeElapsed = blockTimestamp - blockTimestampLast;
        }

        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            unchecked {
                // Price cumulative accumulators for TWAP oracles (UQ112x112 fixed point)
                price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).qdiv(_reserve0)) * timeElapsed;
                price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).qdiv(_reserve1)) * timeElapsed;
            }
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;

        emit Sync(reserve0, reserve1);
    }

    // Low-level liquidity minting (called by router or liquidity provider directly)
    function mint(address to) external override lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        uint256 _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            // First Liquidity Provider: Mint sqrt(amount0 * amount1) and permanently lock MINIMUM_LIQUIDITY to address(0)
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            // Proportional liquidity share minting: min( (a0 * total) / r0, (a1 * total) / r1 )
            liquidity = Math.min((amount0 * _totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
        }

        if (liquidity == 0) revert InsufficientLiquidityMinted();
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        kLast = uint256(reserve0) * reserve1;
        emit Mint(msg.sender, amount0, amount1);
    }

    // Low-level liquidity burning (called by router or LP after transferring LP tokens to pair)
    function burn(address to) external override lock returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        address _token0 = token0;
        address _token1 = token1;
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        uint256 _totalSupply = totalSupply;
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;

        if (amount0 == 0 || amount1 == 0) revert InsufficientLiquidityBurned();

        _burn(address(this), liquidity);
        IERC20(_token0).safeTransfer(to, amount0);
        IERC20(_token1).safeTransfer(to, amount1);

        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        kLast = uint256(reserve0) * reserve1;
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // Low-level token swap execution with optimistic transfer and flash swap support
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external override lock {
        if (amount0Out == 0 && amount1Out == 0) revert InsufficientOutputAmount();
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        if (amount0Out >= _reserve0 || amount1Out >= _reserve1) revert InsufficientLiquidity();

        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = token0;
            address _token1 = token1;
            if (to == _token0 || to == _token1) revert InvalidRecipient();

            // Optimistic token transfer
            if (amount0Out > 0) IERC20(_token0).safeTransfer(to, amount0Out);
            if (amount1Out > 0) IERC20(_token1).safeTransfer(to, amount1Out);

            // Flash swap callback execution
            if (data.length > 0) {
                ISageCallee(to).sageCall(msg.sender, amount0Out, amount1Out, data);
            }

            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }

        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        if (amount0In == 0 && amount1In == 0) revert InsufficientInputAmount();

        // Enforce constant-product invariant with 0.3% (30 bps) fee:
        // (1000 * balance0 - 3 * amount0In) * (1000 * balance1 - 3 * amount1In) >= 1000^2 * reserve0 * reserve1
        {
            uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
            if (balance0Adjusted * balance1Adjusted < uint256(_reserve0) * _reserve1 * (1000 ** 2)) {
                revert KInvariantViolation();
            }
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // Force balances to match stored reserves (sweeps excess unsolicited donations)
    function skim(address to) external override lock {
        address _token0 = token0;
        address _token1 = token1;
        IERC20(_token0).safeTransfer(to, IERC20(_token0).balanceOf(address(this)) - reserve0);
        IERC20(_token1).safeTransfer(to, IERC20(_token1).balanceOf(address(this)) - reserve1);
    }

    // Force stored reserves to match physical token balances
    function sync() external override lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}
