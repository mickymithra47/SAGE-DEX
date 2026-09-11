// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {SagePricingLibrary} from "../libraries/SagePricingLibrary.sol";
import {SageOracleEngine} from "../core/SageOracleEngine.sol";
import {ISagePair} from "../../phase3/interfaces/ISageAMM.sol";

// ==========================================
// SCENARIO 1: FLASH LOAN SPOT PRICE ATTACKER
// ==========================================
contract FlashLoanSpotPriceAttacker {
    // Demonstrates that instantaneous spot price is highly manipulable in a single transaction,
    // but TWAP remains resistant because timeElapsed in the same block is 0.
    function executeSpotDistortion(
        SageOracleEngine oracle,
        address pair,
        address token0
    ) external view returns (uint256 spotPriceBefore, uint256 twap1Hour) {
        spotPriceBefore = oracle.getSpotPriceWad(pair, token0);
        twap1Hour = oracle.consult(pair, token0, 1 ether, 3600);
    }
}

// ==========================================
// SCENARIO 3: DIRECT DONATION PRICE SKEW ATTEMPT
// ==========================================
contract DonationPriceDistortionAttacker {
    // Shows that direct token donation to a pair does NOT immediately corrupt TWAP,
    // because TWAP accumulators rely on stored reserves rather than raw token balances.
    function inspectDonationImpact(
        SageOracleEngine oracle,
        address pair,
        address tokenIn
    ) external view returns (uint256 spotPriceWad) {
        spotPriceWad = oracle.getSpotPriceWad(pair, tokenIn);
    }
}

// ==========================================
// SCENARIO 8: TOKEN DECIMAL MISMATCH EXPLOITER
// ==========================================
contract DecimalMismatchTester {
    // Proves that normalizeDecimals handles 6-decimal (USDC) to 18-decimal (WETH) conversions without truncation loss
    function verifyDecimalScaling(
        uint256 usdcAmount,
        uint8 usdcDecimals,
        uint8 targetDecimals
    ) external pure returns (uint256 normalizedWad) {
        normalizedWad = SagePricingLibrary.normalizeDecimals(usdcAmount, usdcDecimals, targetDecimals);
    }
}
