/**
 * @file errorDecoder.ts
 * @notice Decodes protocol custom errors into actionable, human-readable user interface alerts.
 */

export interface DecodedError {
  title: string;
  message: string;
  actionHint?: string;
}

export const ERROR_MAPPINGS: Record<string, DecodedError> = {
  Expired: {
    title: 'Transaction Expired',
    message: 'The transaction remained pending past its deadline.',
    actionHint: 'Please submit a fresh transaction with an updated deadline.'
  },
  InsufficientOutput: {
    title: 'Slippage Tolerance Breached',
    message: 'The realized output amount fell below your minimum received threshold.',
    actionHint: 'Consider increasing your slippage tolerance slightly in settings.'
  },
  ExcessiveInput: {
    title: 'Input Amount Exceeded',
    message: 'The required input tokens exceeded your maximum input threshold.',
    actionHint: 'Try refreshing the quote and resubmitting.'
  },
  InvalidPath: {
    title: 'Invalid Route',
    message: 'The selected swap path is malformed or contains identical tokens.',
    actionHint: 'Please select two distinct, valid tokens.'
  },
  PairNotFound: {
    title: 'Pool Does Not Exist',
    message: 'No active liquidity pool exists for this token pair on-chain.',
    actionHint: 'You may create the pair or provide initial liquidity in the Liquidity tab.'
  },
  InvalidRecipient: {
    title: 'Invalid Recipient Address',
    message: 'Output tokens cannot be sent to the zero address or the router contract.',
    actionHint: 'Ensure your connected wallet is active and valid.'
  },
  TransferFailed: {
    title: 'Token Transfer Failed',
    message: 'The token or native ETH transfer failed during execution.',
    actionHint: 'Check your wallet balance, gas fee allowance, or token blacklist status.'
  },
  InvalidSignature: {
    title: 'Signature Verification Failed',
    message: 'The EIP-712 or Permit2 signature could not be verified for this spender.',
    actionHint: 'Please sign a new authorization in your wallet.'
  },
  InvalidNonce: {
    title: 'Signature Already Used',
    message: 'This signature nonce has already been consumed or invalidated on-chain.',
    actionHint: 'Generate a new signature to proceed.'
  },
  SignatureExpired: {
    title: 'Permit Signature Expired',
    message: 'The off-chain authorization passed its validity timestamp.',
    actionHint: 'Sign a fresh authorization with current timestamp.'
  },
  InsufficientAllowance: {
    title: 'Insufficient Token Allowance',
    message: 'The router or Permit2 does not have approval to spend the requested amount.',
    actionHint: 'Click Approve to authorize token spending.'
  }
};

export function decodeContractError(rawError: any): DecodedError {
  if (!rawError) {
    return {
      title: 'Unknown Error',
      message: 'An unexpected error occurred during execution.'
    };
  }

  const errorString = String(rawError?.message || rawError?.data || rawError);

  for (const [errorName, decoded] of Object.entries(ERROR_MAPPINGS)) {
    if (errorString.includes(errorName)) {
      return decoded;
    }
  }

  // Handle common wallet rejection
  if (errorString.includes('User rejected') || errorString.includes('User denied')) {
    return {
      title: 'Signature Rejected',
      message: 'You cancelled the transaction or signature in your wallet.',
      actionHint: 'No funds were transferred.'
    };
  }

  // Handle generic revert
  return {
    title: 'Execution Reverted',
    message: rawError?.shortMessage || 'The smart contract reverted the transaction.',
    actionHint: 'Verify pool reserves, token allowances, and slippage settings.'
  };
}
