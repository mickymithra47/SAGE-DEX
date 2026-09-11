/**
 * @file pairDecoder.ts
 * @notice Decodes SagePair Swap, Mint, Burn, and Sync events.
 */

export const SWAP_TOPIC = '0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822';
export const MINT_TOPIC = '0x4c209b37986879e7c75c607cd3820285587c08d79acd61535b03725c55920b3f';
export const BURN_TOPIC = '0xdccd412f0b1252819cb1fd330b93224ca42612892bb3f4f789976e6d81936496';
export const SYNC_TOPIC = '0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1';

export interface DecodedSwap {
  poolAddress: string;
  sender: string;
  recipient: string;
  amount0In: bigint;
  amount1In: bigint;
  amount0Out: bigint;
  amount1Out: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
}

export interface DecodedMint {
  poolAddress: string;
  sender: string;
  amount0: bigint;
  amount1: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
}

export interface DecodedBurn {
  poolAddress: string;
  sender: string;
  recipient: string;
  amount0: bigint;
  amount1: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
}

export interface DecodedSync {
  poolAddress: string;
  reserve0: bigint;
  reserve1: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
}

export function decodeSwapEvent(
  poolAddress: string,
  topics: string[],
  data: string,
  blockNumber: bigint,
  txHash: string,
  logIndex: number
): DecodedSwap | null {
  if (!topics || topics[0] !== SWAP_TOPIC || topics.length < 3) return null;

  const sender = '0x' + topics[1].slice(-40).toLowerCase();
  const recipient = '0x' + topics[2].slice(-40).toLowerCase();

  const clean = data.replace('0x', '');
  const amount0In = BigInt('0x' + clean.slice(0, 64));
  const amount1In = BigInt('0x' + clean.slice(64, 128));
  const amount0Out = BigInt('0x' + clean.slice(128, 192));
  const amount1Out = BigInt('0x' + clean.slice(192, 256));

  return {
    poolAddress: poolAddress.toLowerCase(),
    sender,
    recipient,
    amount0In,
    amount1In,
    amount0Out,
    amount1Out,
    blockNumber,
    txHash,
    logIndex
  };
}

export function decodeMintEvent(
  poolAddress: string,
  topics: string[],
  data: string,
  blockNumber: bigint,
  txHash: string,
  logIndex: number
): DecodedMint | null {
  if (!topics || topics[0] !== MINT_TOPIC || topics.length < 2) return null;

  const sender = '0x' + topics[1].slice(-40).toLowerCase();
  const clean = data.replace('0x', '');
  const amount0 = BigInt('0x' + clean.slice(0, 64));
  const amount1 = BigInt('0x' + clean.slice(64, 128));

  return {
    poolAddress: poolAddress.toLowerCase(),
    sender,
    amount0,
    amount1,
    blockNumber,
    txHash,
    logIndex
  };
}

export function decodeBurnEvent(
  poolAddress: string,
  topics: string[],
  data: string,
  blockNumber: bigint,
  txHash: string,
  logIndex: number
): DecodedBurn | null {
  if (!topics || topics[0] !== BURN_TOPIC || topics.length < 3) return null;

  const sender = '0x' + topics[1].slice(-40).toLowerCase();
  const recipient = '0x' + topics[2].slice(-40).toLowerCase();
  const clean = data.replace('0x', '');
  const amount0 = BigInt('0x' + clean.slice(0, 64));
  const amount1 = BigInt('0x' + clean.slice(64, 128));

  return {
    poolAddress: poolAddress.toLowerCase(),
    sender,
    recipient,
    amount0,
    amount1,
    blockNumber,
    txHash,
    logIndex
  };
}

export function decodeSyncEvent(
  poolAddress: string,
  topics: string[],
  data: string,
  blockNumber: bigint,
  txHash: string,
  logIndex: number
): DecodedSync | null {
  if (!topics || topics[0] !== SYNC_TOPIC) return null;

  const clean = data.replace('0x', '');
  const reserve0 = BigInt('0x' + clean.slice(0, 64));
  const reserve1 = BigInt('0x' + clean.slice(64, 128));

  return {
    poolAddress: poolAddress.toLowerCase(),
    reserve0,
    reserve1,
    blockNumber,
    txHash,
    logIndex
  };
}
