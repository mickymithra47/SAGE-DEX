// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20, IERC20Metadata, IERC20Permit} from "../../phase2/interfaces/IERC20.sol";

/**
 * @title ISageERC20
 * @notice Interface for the Sage AMM LP Share Token
 */
interface ISageERC20 is IERC20Metadata, IERC20Permit {}

/**
 * @title ISageCallee
 * @notice Callback interface for Flash Swaps
 */
interface ISageCallee {
    function sageCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

/**
 * @title ISagePair
 * @notice Interface for the Sage AMM Constant-Product Pair Contract
 */
interface ISagePair is ISageERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function initialize(address token0, address token1) external;
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

/**
 * @title ISageFactory
 * @notice Interface for the Sage AMM Factory Contract
 */
interface ISageFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 allPairsLength);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256 index) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
