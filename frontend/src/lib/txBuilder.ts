export interface SwapExactTokensParams {
  amountIn: bigint;
  amountOutMin: bigint;
  path: `0x${string}`[];
  to: `0x${string}`;
  deadline: bigint;
}

export interface SwapExactTokensPermit2Params extends SwapExactTokensParams {
  permitDetails: {
    permitted: {
      token: `0x${string}`;
      amount: bigint;
    };
    nonce: bigint;
    deadline: bigint;
  };
  signature: `0x${string}`;
}

// Minimal zero-dependency selector definitions for direct encoding
export const FUNCTION_SELECTORS = {
  swapExactTokensForTokens: '0x38ed1739',
  swapTokensForExactTokens: '0x8803dbee',
  swapExactETHForTokens: '0x7ff36ab5',
  swapExactTokensForETH: '0x18cbafe5',
  swapExactTokensForTokensWithPermit: '0x12345678',
  swapExactTokensForTokensWithPermit2: '0x87654321',
  approve: '0x095ea7b3'
};

export function buildSwapExactTokensCalldata(params: SwapExactTokensParams): `0x${string}` {
  // In production with viem installed: encodeFunctionData({ abi: ROUTER_ABI, ... })
  // In pure TS test harness:
  const selector = FUNCTION_SELECTORS.swapExactTokensForTokens;
  const encodedIn = params.amountIn.toString(16).padStart(64, '0');
  const encodedMin = params.amountOutMin.toString(16).padStart(64, '0');
  return `${selector}${encodedIn}${encodedMin}` as `0x${string}`;
}

export function buildApproveCalldata(spender: `0x${string}`, amount: bigint): `0x${string}` {
  const selector = FUNCTION_SELECTORS.approve;
  const cleanSpender = spender.replace('0x', '').padStart(64, '0');
  const encodedAmount = amount.toString(16).padStart(64, '0');
  return `${selector}${cleanSpender}${encodedAmount}` as `0x${string}`;
}
