/**
 * @file erc20Decoder.ts
 * @notice Decodes ERC-20 / LP token Transfer events.
 */

export const TRANSFER_TOPIC = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

export interface DecodedTransfer {
  tokenAddress: string;
  from: string;
  to: string;
  value: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
}

export function decodeTransferEvent(
  tokenAddress: string,
  topics: string[],
  data: string,
  blockNumber: bigint,
  txHash: string,
  logIndex: number
): DecodedTransfer | null {
  if (!topics || topics[0] !== TRANSFER_TOPIC || topics.length < 3) return null;

  const from = '0x' + topics[1].slice(-40).toLowerCase();
  const to = '0x' + topics[2].slice(-40).toLowerCase();
  const value = BigInt(data);

  return {
    tokenAddress: tokenAddress.toLowerCase(),
    from,
    to,
    value,
    blockNumber,
    txHash,
    logIndex
  };
}
