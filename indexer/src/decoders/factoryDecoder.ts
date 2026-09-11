/**
 * @file factoryDecoder.ts
 * @notice Decodes SageFactory PairCreated events.
 */

export interface DecodedPairCreated {
  factoryAddress: string;
  token0: string;
  token1: string;
  pairAddress: string;
  pairIndex: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
}

export const PAIR_CREATED_TOPIC = '0x0d3648bd0f6ba80134a33ba9275ac585d9d315f0ad8355cddefde31afa28d0e9';

export function decodePairCreatedEvent(
  factoryAddress: string,
  topics: string[],
  data: string,
  blockNumber: bigint,
  txHash: string,
  logIndex: number
): DecodedPairCreated | null {
  if (!topics || topics.length < 3 || topics[0] !== PAIR_CREATED_TOPIC) {
    return null;
  }

  // Topic 1: token0, Topic 2: token1
  const token0 = '0x' + topics[1].slice(-40).toLowerCase();
  const token1 = '0x' + topics[2].slice(-40).toLowerCase();

  // Data: pair (address) and pairIndex (uint256)
  const cleanData = data.replace('0x', '');
  const pairAddress = '0x' + cleanData.slice(24, 64).toLowerCase();
  const pairIndex = BigInt('0x' + cleanData.slice(64, 128));

  return {
    factoryAddress: factoryAddress.toLowerCase(),
    token0,
    token1,
    pairAddress,
    pairIndex,
    blockNumber,
    txHash,
    logIndex
  };
}
