// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageOracle} from "../interfaces/ISageOracle.sol";
import {ISagePair} from "../../phase3/interfaces/ISageAMM.sol";
import {SagePricingLibrary} from "../libraries/SagePricingLibrary.sol";
import {UQ112x112} from "../../phase3/libraries/Math.sol";

/**
 * @title SageOracleEngine
 * @notice Time-Weighted Average Price (TWAP) observation engine and historical price oracle.
 */
contract SageOracleEngine is ISageOracle {
    using UQ112x112 for uint224;

    error ZeroAddress();
    error Uninitialized();
    error InsufficientHistory();
    error InvalidLookback();

    uint256 internal constant WAD = 1e18;

    // Mapping pair => timestamp => Observation
    mapping(address => mapping(uint32 => Observation)) public observations;
    mapping(address => uint32[]) public observationTimestamps;
    mapping(address => Observation) public latestObservation;

    function update(address pair) external override {
        if (pair == address(0)) revert ZeroAddress();

        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = _getCurrentCumulativePrices(pair);

        Observation memory obs = Observation({
            timestamp: blockTimestamp,
            price0Cumulative: price0Cumulative,
            price1Cumulative: price1Cumulative
        });

        uint32[] storage tsList = observationTimestamps[pair];
        if (tsList.length == 0 || tsList[tsList.length - 1] != blockTimestamp) {
            tsList.push(blockTimestamp);
        }

        observations[pair][blockTimestamp] = obs;
        latestObservation[pair] = obs;
    }

    function consult(
        address pair,
        address tokenIn,
        uint256 amountIn,
        uint32 lookbackPeriodSeconds
    ) external view override returns (uint256 amountOutTWAP) {
        if (pair == address(0)) revert ZeroAddress();
        if (lookbackPeriodSeconds == 0) revert InvalidLookback();

        uint32[] storage tsList = observationTimestamps[pair];
        if (tsList.length == 0) revert Uninitialized();

        (uint256 currentCumulative0, uint256 currentCumulative1, uint32 currentTimestamp) = _getCurrentCumulativePrices(pair);

        uint32 targetTimestamp = currentTimestamp >= lookbackPeriodSeconds ? currentTimestamp - lookbackPeriodSeconds : 0;
        Observation memory pastObs = _findObservationBeforeOrAt(pair, targetTimestamp);

        uint32 timeElapsed = currentTimestamp - pastObs.timestamp;
        if (timeElapsed == 0) revert InsufficientHistory();

        address token0 = ISagePair(pair).token0();
        bool isToken0 = tokenIn == token0;

        uint256 twapPriceWad = isToken0
            ? SagePricingLibrary.computeTWAP(pastObs.price0Cumulative, currentCumulative0, timeElapsed)
            : SagePricingLibrary.computeTWAP(pastObs.price1Cumulative, currentCumulative1, timeElapsed);

        amountOutTWAP = (amountIn * twapPriceWad) / WAD;
    }

    function getSpotPriceWad(address pair, address tokenIn) external view override returns (uint256 spotPriceWad) {
        if (pair == address(0)) revert ZeroAddress();
        (uint112 r0, uint112 r1, ) = ISagePair(pair).getReserves();
        address token0 = ISagePair(pair).token0();
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == token0 ? (r0, r1) : (r1, r0);
        spotPriceWad = SagePricingLibrary.getSpotPriceWad(reserveIn, reserveOut);
    }

    function getLatestObservation(address pair) external view override returns (Observation memory) {
        return latestObservation[pair];
    }

    function _getCurrentCumulativePrices(address pair)
        internal
        view
        returns (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp)
    {
        ISagePair pool = ISagePair(pair);
        (uint112 r0, uint112 r1, uint32 blockTimestampLast) = pool.getReserves();
        price0Cumulative = pool.price0CumulativeLast();
        price1Cumulative = pool.price1CumulativeLast();

        blockTimestamp = uint32(block.timestamp % 2 ** 32);

        // If time has elapsed in the current block, compute pending accumulation
        if (blockTimestampLast != blockTimestamp && r0 != 0 && r1 != 0) {
            unchecked {
                uint32 timeElapsed = blockTimestamp - blockTimestampLast;
                price0Cumulative += uint256(UQ112x112.encode(r1).qdiv(r0)) * timeElapsed;
                price1Cumulative += uint256(UQ112x112.encode(r0).qdiv(r1)) * timeElapsed;
            }
        }
    }

    function _findObservationBeforeOrAt(address pair, uint32 targetTimestamp)
        internal
        view
        returns (Observation memory obs)
    {
        uint32[] storage tsList = observationTimestamps[pair];
        if (tsList.length == 0) revert Uninitialized();

        // Binary search or linear lookup for the closest historical observation <= targetTimestamp
        uint256 low = 0;
        uint256 high = tsList.length - 1;
        uint256 bestIdx = 0;

        while (low <= high) {
            uint256 mid = (low + high) / 2;
            if (tsList[mid] <= targetTimestamp) {
                bestIdx = mid;
                low = mid + 1;
            } else {
                if (mid == 0) break;
                high = mid - 1;
            }
        }

        uint32 chosenTs = tsList[bestIdx];
        obs = observations[pair][chosenTs];
    }
}
