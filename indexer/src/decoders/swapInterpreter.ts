/**
 * @file swapInterpreter.ts
 * @notice Interprets raw Swap event amounts into canonical tokenIn/tokenOut representation.
 */

import type { DecodedSwap } from './pairDecoder.ts';

export interface InterpretedSwap {
  tokenIn: string;
  tokenOut: string;
  amountIn: bigint;
  amountOut: bigint;
  direction: 'TOKEN0_TO_TOKEN1' | 'TOKEN1_TO_TOKEN0';
}

export function interpretSwap(decoded: DecodedSwap, token0: string, token1: string): InterpretedSwap {
  const t0 = token0.toLowerCase();
  const t1 = token1.toLowerCase();

  // Case 1: Token0 In -> Token1 Out
  if (decoded.amount0In > 0n && decoded.amount1Out > 0n) {
    return {
      tokenIn: t0,
      tokenOut: t1,
      amountIn: decoded.amount0In,
      amountOut: decoded.amount1Out,
      direction: 'TOKEN0_TO_TOKEN1'
    };
  }

  // Case 2: Token1 In -> Token0 Out
  if (decoded.amount1In > 0n && decoded.amount0Out > 0n) {
    return {
      tokenIn: t1,
      tokenOut: t0,
      amountIn: decoded.amount1In,
      amountOut: decoded.amount0Out,
      direction: 'TOKEN1_TO_TOKEN0'
    };
  }

  // Fallback / Mixed edge case
  if (decoded.amount0In > 0n) {
    return {
      tokenIn: t0,
      tokenOut: t1,
      amountIn: decoded.amount0In,
      amountOut: decoded.amount1Out,
      direction: 'TOKEN0_TO_TOKEN1'
    };
  } else {
    return {
      tokenIn: t1,
      tokenOut: t0,
      amountIn: decoded.amount1In,
      amountOut: decoded.amount0Out,
      direction: 'TOKEN1_TO_TOKEN0'
    };
  }
}
