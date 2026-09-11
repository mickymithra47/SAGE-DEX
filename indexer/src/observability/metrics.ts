/**
 * @file metrics.ts
 * @notice Observability and metrics collection for Sage Indexer.
 */

export interface IndexerMetricsData {
  blocksProcessedTotal: number;
  eventsProcessedTotal: number;
  indexerLagBlocks: number;
  rpcErrorsTotal: number;
  processingErrorsTotal: number;
  reorgsTotal: number;
  lastIndexedBlock: bigint;
  uptimeSeconds: number;
}

export class IndexerMetrics {
  private blocksProcessed = 0;
  private eventsProcessed = 0;
  private lagBlocks = 0;
  private rpcErrors = 0;
  private processingErrors = 0;
  private reorgs = 0;
  private lastBlock = 0n;
  private startTime = Date.now();

  public incBlocks(count: number = 1): void {
    this.blocksProcessed += count;
  }

  public incEvents(count: number = 1): void {
    this.eventsProcessed += count;
  }

  public setLag(lag: number): void {
    this.lagBlocks = lag;
  }

  public incRpcErrors(): void {
    this.rpcErrors++;
  }

  public incProcessingErrors(): void {
    this.processingErrors++;
  }

  public incReorgs(): void {
    this.reorgs++;
  }

  public setLastBlock(block: bigint): void {
    this.lastBlock = block;
  }

  public getMetrics(): IndexerMetricsData {
    return {
      blocksProcessedTotal: this.blocksProcessed,
      eventsProcessedTotal: this.eventsProcessed,
      indexerLagBlocks: this.lagBlocks,
      rpcErrorsTotal: this.rpcErrors,
      processingErrorsTotal: this.processingErrors,
      reorgsTotal: this.reorgs,
      lastIndexedBlock: this.lastBlock,
      uptimeSeconds: Math.floor((Date.now() - this.startTime) / 1000)
    };
  }
}
