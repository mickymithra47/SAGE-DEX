/**
 * @file reorgHandler.ts
 * @notice Detects chain reorganizations and executes state rollbacks.
 */

import { SageDatabase } from '../db/database.ts';
import type { BlockRecord } from '../db/database.ts';

export interface ReorgDetectionResult {
  isReorg: boolean;
  commonAncestorBlock?: bigint;
}

export class ReorgHandler {
  private db: SageDatabase;

  constructor(db: SageDatabase) {
    this.db = db;
  }

  public checkBlockForReorg(newBlock: BlockRecord): ReorgDetectionResult {
    if (newBlock.blockNumber === 0n) {
      return { isReorg: false };
    }

    const previousIndexedBlock = this.db.getBlock(newBlock.chainId, newBlock.blockNumber - 1n);
    if (!previousIndexedBlock) {
      return { isReorg: false };
    }

    // If parent hash does not match our indexed previous block hash -> Reorg detected
    if (previousIndexedBlock.blockHash.toLowerCase() !== newBlock.parentHash.toLowerCase()) {
      // Find common ancestor
      let ancestor = newBlock.blockNumber - 2n;
      while (ancestor > 0n) {
        const b = this.db.getBlock(newBlock.chainId, ancestor);
        if (b) {
          return { isReorg: true, commonAncestorBlock: ancestor };
        }
        ancestor--;
      }
      return { isReorg: true, commonAncestorBlock: 0n };
    }

    return { isReorg: false };
  }

  public executeRollback(chainId: bigint, rollbackToBlock: bigint): number {
    return this.db.rollbackBlocksAbove(chainId, rollbackToBlock);
  }
}
