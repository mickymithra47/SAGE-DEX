// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {SagePricingLibrary} from "../libraries/SagePricingLibrary.sol";
import {UQ112x112} from "../../phase3/libraries/Math.sol";

// ==========================================
// MINI PROJECT 1: AMOUNT OUT CALCULATOR
// ==========================================
contract Project1_AmountOutCalculator {
    function computeAmountOut(uint256 aIn, uint256 rIn, uint256 rOut) external pure returns (uint256) {
        return SagePricingLibrary.getAmountOut(aIn, rIn, rOut);
    }
}

// ==========================================
// MINI PROJECT 2: AMOUNT IN CALCULATOR
// ==========================================
contract Project2_AmountInCalculator {
    function computeAmountIn(uint256 aOut, uint256 rIn, uint256 rOut) external pure returns (uint256) {
        return SagePricingLibrary.getAmountIn(aOut, rIn, rOut);
    }
}

// ==========================================
// MINI PROJECT 3: SPOT PRICE CALCULATOR
// ==========================================
contract Project3_SpotPriceCalculator {
    function computeSpotPrice(uint256 rIn, uint256 rOut) external pure returns (uint256) {
        return SagePricingLibrary.getSpotPriceWad(rIn, rOut);
    }
}

// ==========================================
// MINI PROJECT 4: PRICE IMPACT CALCULATOR
// ==========================================
contract Project4_PriceImpactCalculator {
    function computePriceImpact(uint256 aIn, uint256 aOut, uint256 rIn, uint256 rOut) external pure returns (uint256) {
        return SagePricingLibrary.calculatePriceImpactBps(aIn, aOut, rIn, rOut);
    }
}

// ==========================================
// MINI PROJECT 5: MULTI-HOP QUOTE CALCULATOR
// ==========================================
contract Project5_MultiHopQuoteCalculator {
    function computeMultiHopOut(address factory, uint256 aIn, address[] calldata path) external view returns (uint256[] memory) {
        return SagePricingLibrary.getAmountsOut(factory, aIn, path);
    }
}

// ==========================================
// MINI PROJECT 6: FIXED POINT MATH HELPER
// ==========================================
contract Project6_FixedPointMath {
    using UQ112x112 for uint224;

    function encodeAndDivide(uint112 y, uint112 x) external pure returns (uint224) {
        return UQ112x112.encode(y).qdiv(x);
    }
}

// ==========================================
// MINI PROJECT 7: TWAP ACCUMULATOR
// ==========================================
contract Project7_TWAPAccumulator {
    using UQ112x112 for uint224;

    uint256 public cumulative0;
    uint32 public lastTimestamp;

    function accumulate(uint112 r0, uint112 r1, uint32 currentTimestamp) external {
        if (lastTimestamp != 0 && currentTimestamp > lastTimestamp) {
            uint32 timeElapsed = currentTimestamp - lastTimestamp;
            cumulative0 += uint256(UQ112x112.encode(r1).qdiv(r0)) * timeElapsed;
        }
        lastTimestamp = currentTimestamp;
    }
}

// ==========================================
// MINI PROJECT 8: HISTORICAL OBSERVATION SYSTEM
// ==========================================
contract Project8_HistoricalObservationSystem {
    struct Obs {
        uint32 timestamp;
        uint256 priceCumulative;
    }

    Obs[] public history;

    function recordObservation(uint32 timestamp, uint256 priceCumulative) external {
        history.push(Obs(timestamp, priceCumulative));
    }
}

// ==========================================
// MINI PROJECT 9: TWAP CONSULTATION LIBRARY
// ==========================================
contract Project9_TWAPConsultationLibrary {
    function computeTWAP(uint256 cStart, uint256 cEnd, uint32 elapsed) external pure returns (uint256) {
        return SagePricingLibrary.computeTWAP(cStart, cEnd, elapsed);
    }
}

// ==========================================
// MINI PROJECT 10: ORACLE MANIPULATION SIMULATOR
// ==========================================
contract Project10_OracleManipulationSimulator {
    // Computes TWAP deviation caused by a short flash-trade spike of duration spikeSeconds in window totalSeconds
    function simulateTWAPDistortion(
        uint256 normalPriceWad,
        uint256 manipulatedPriceWad,
        uint32 spikeSeconds,
        uint32 totalWindowSeconds
    ) external pure returns (uint256 distortedTWAPWad) {
        uint256 normalWeight = normalPriceWad * (totalWindowSeconds - spikeSeconds);
        uint256 manipulatedWeight = manipulatedPriceWad * spikeSeconds;
        distortedTWAPWad = (normalWeight + manipulatedWeight) / totalWindowSeconds;
    }
}

// ==========================================
// MINI PROJECT 11: DIFFERENTIAL TESTER
// ==========================================
contract Project11_DifferentialTester {
    function verifyQuoteParity(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 expectedOut
    ) external pure returns (bool isExact) {
        uint256 actualOut = SagePricingLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
        isExact = (actualOut == expectedOut);
    }
}

// ==========================================
// MINI PROJECT 12: COMPLETE PRICING ORACLE HARNESS
// ==========================================
contract Project12_CompletePricingOracleEngine {
    function getSpotAndImpact(
        uint256 aIn,
        uint256 rIn,
        uint256 rOut
    ) external pure returns (uint256 spotPriceWad, uint256 aOut, uint256 impactBps) {
        spotPriceWad = SagePricingLibrary.getSpotPriceWad(rIn, rOut);
        aOut = SagePricingLibrary.getAmountOut(aIn, rIn, rOut);
        impactBps = SagePricingLibrary.calculatePriceImpactBps(aIn, aOut, rIn, rOut);
    }
}
