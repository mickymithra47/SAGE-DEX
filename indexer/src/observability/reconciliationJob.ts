/**
 * @file reconciliationJob.ts
 * @notice Periodic reconciliation job comparing indexed DB reserves with live on-chain Pair.getReserves().
 */

import { SageDatabase } from '../db/database.ts';

export interface MismatchReport {
  poolAddress: string;
  indexedReserve0: bigint;
  onChainReserve0: bigint;
  indexedReserve1: bigint;
  onChainReserve1: bigint;
  delta0: bigint;
  delta1: bigint;
}

export class ReconciliationJob {
  private db: SageDatabase;

  constructor(db: SageDatabase) {
    this.db = db;
  }

  public reconcilePool(
    chainId: bigint,
    poolAddress: string,
    onChainReserve0: bigint,
    onChainReserve1: bigint
  ): { isConsistent: boolean; report?: MismatchReport } {
    const pool = this.db.getPool(chainId, poolAddress);
    if (!pool) {
      return { isConsistent: false };
    }

    const isMatch = pool.reserve0 === onChainReserve0 && pool.reserve1 === onChainReserve1;

    if (!isMatch) {
      const delta0 = pool.reserve0 > onChainReserve0 ? pool.reserve0 - onChainReserve0 : onChainReserve0 - pool.reserve0;
      const delta1 = pool.reserve1 > onChainReserve1 ? pool.reserve1 - onChainReserve1 : onChainReserve1 - pool.reserve1;

      return {
        isConsistent: false,
        report: {
          poolAddress: pool.address,
          indexedReserve0: pool.reserve0,
          onChainReserve0,
          indexedReserve1: pool.reserve1,
          onChainReserve1,
          delta0,
          delta1
        }
      };
    }

    return { isConsistent: true };
  }
}
