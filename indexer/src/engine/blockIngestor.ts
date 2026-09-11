/**
 * @file blockIngestor.ts
 * @notice Ingests blockchain blocks and events into the database.
 */

import { SageDatabase } from '../db/database.ts';
import type { BlockRecord } from '../db/database.ts';
import { decodePairCreatedEvent } from '../decoders/factoryDecoder.ts';
import { decodeSwapEvent, decodeMintEvent, decodeBurnEvent, decodeSyncEvent } from '../decoders/pairDecoder.ts';
import { decodeTransferEvent } from '../decoders/erc20Decoder.ts';
import { interpretSwap } from '../decoders/swapInterpreter.ts';
import { ReorgHandler } from './reorgHandler.ts';

export interface RawLog {
  address: string;
  topics: string[];
  data: string;
  blockNumber: bigint;
  transactionHash: string;
  logIndex: number;
}

export class BlockIngestor {
  public db: SageDatabase;
  private reorgHandler: ReorgHandler;

  constructor(db: SageDatabase) {
    this.db = db;
    this.reorgHandler = new ReorgHandler(db);
  }

  public processBlock(block: BlockRecord, logs: RawLog[]): { success: boolean; reorgOccurred: boolean } {
    // 1. Check for Reorganization
    const reorgCheck = this.reorgHandler.checkBlockForReorg(block);
    let reorgOccurred = false;

    if (reorgCheck.isReorg && reorgCheck.commonAncestorBlock !== undefined) {
      this.reorgHandler.executeRollback(block.chainId, reorgCheck.commonAncestorBlock);
      reorgOccurred = true;
    }

    // 2. Insert Block
    this.db.insertBlock(block);

    // 3. Process Logs
    for (const log of logs) {
      this.processLog(block.chainId, block.timestamp, log);
    }

    return { success: true, reorgOccurred };
  }

  private processLog(chainId: bigint, timestamp: bigint, log: RawLog): void {
    // A. Check PairCreated
    const pairCreated = decodePairCreatedEvent(
      log.address,
      log.topics,
      log.data,
      log.blockNumber,
      log.transactionHash,
      log.logIndex
    );
    if (pairCreated) {
      // Register tokens if not present
      if (!this.db.getToken(chainId, pairCreated.token0)) {
        this.db.insertToken({
          chainId,
          address: pairCreated.token0,
          symbol: 'TKN0',
          name: 'Token 0',
          decimals: 18
        });
      }
      if (!this.db.getToken(chainId, pairCreated.token1)) {
        this.db.insertToken({
          chainId,
          address: pairCreated.token1,
          symbol: 'TKN1',
          name: 'Token 1',
          decimals: 18
        });
      }

      this.db.insertPool({
        chainId,
        address: pairCreated.pairAddress,
        factory: pairCreated.factoryAddress,
        token0: pairCreated.token0,
        token1: pairCreated.token1,
        createdAtBlock: pairCreated.blockNumber,
        createdAtTimestamp: timestamp,
        createdTxHash: pairCreated.txHash,
        reserve0: 0n,
        reserve1: 0n,
        totalSupply: 0n
      });
      return;
    }

    // B. Check Sync
    const sync = decodeSyncEvent(
      log.address,
      log.topics,
      log.data,
      log.blockNumber,
      log.transactionHash,
      log.logIndex
    );
    if (sync) {
      this.db.updatePoolReserves(chainId, sync.poolAddress, sync.reserve0, sync.reserve1);
      return;
    }

    // C. Check Swap
    const swap = decodeSwapEvent(
      log.address,
      log.topics,
      log.data,
      log.blockNumber,
      log.transactionHash,
      log.logIndex
    );
    if (swap) {
      const pool = this.db.getPool(chainId, swap.poolAddress);
      if (pool) {
        const interpreted = interpretSwap(swap, pool.token0, pool.token1);
        this.db.insertSwap({
          chainId,
          blockNumber: swap.blockNumber,
          txHash: swap.txHash,
          logIndex: swap.logIndex,
          poolAddress: swap.poolAddress,
          sender: swap.sender,
          recipient: swap.recipient,
          amount0In: swap.amount0In,
          amount1In: swap.amount1In,
          amount0Out: swap.amount0Out,
          amount1Out: swap.amount1Out,
          tokenIn: interpreted.tokenIn,
          tokenOut: interpreted.tokenOut,
          amountIn: interpreted.amountIn,
          amountOut: interpreted.amountOut,
          timestamp
        });
      }
      return;
    }

    // D. Check Mint
    const mint = decodeMintEvent(
      log.address,
      log.topics,
      log.data,
      log.blockNumber,
      log.transactionHash,
      log.logIndex
    );
    if (mint) {
      this.db.insertMint({
        type: 'MINT',
        chainId,
        blockNumber: mint.blockNumber,
        txHash: mint.txHash,
        logIndex: mint.logIndex,
        poolAddress: mint.poolAddress,
        sender: mint.sender,
        amount0: mint.amount0,
        amount1: mint.amount1,
        timestamp
      });
      return;
    }

    // E. Check Burn
    const burn = decodeBurnEvent(
      log.address,
      log.topics,
      log.data,
      log.blockNumber,
      log.transactionHash,
      log.logIndex
    );
    if (burn) {
      this.db.insertBurn({
        type: 'BURN',
        chainId,
        blockNumber: burn.blockNumber,
        txHash: burn.txHash,
        logIndex: burn.logIndex,
        poolAddress: burn.poolAddress,
        sender: burn.sender,
        recipient: burn.recipient,
        amount0: burn.amount0,
        amount1: burn.amount1,
        timestamp
      });
      return;
    }

    // F. Check LP Transfer
    const transfer = decodeTransferEvent(
      log.address,
      log.topics,
      log.data,
      log.blockNumber,
      log.transactionHash,
      log.logIndex
    );
    if (transfer) {
      // If from is not 0x0, subtract
      if (transfer.from !== '0x0000000000000000000000000000000000000000') {
        this.db.updateLPPosition(chainId, transfer.tokenAddress, transfer.from, -transfer.value, transfer.blockNumber);
      }
      // If to is not 0x0, add
      if (transfer.to !== '0x0000000000000000000000000000000000000000') {
        this.db.updateLPPosition(chainId, transfer.tokenAddress, transfer.to, transfer.value, transfer.blockNumber);
      }
    }
  }
}
