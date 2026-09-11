/**
 * @file priceEngine.ts
 * @notice Computes decimal-normalized spot prices and exchange rates across pairs.
 */

export function calculateNormalizedPrice(
  reserve0: bigint,
  decimals0: number,
  reserve1: bigint,
  decimals1: number
): { price0In1: number; price1In0: number } {
  if (reserve0 === 0n || reserve1 === 0n) {
    return { price0In1: 0, price1In0: 0 };
  }

  // price0In1 = (reserve1 / 10^decimals1) / (reserve0 / 10^decimals0)
  //           = (reserve1 * 10^decimals0) / (reserve0 * 10^decimals1)
  const norm0 = Number(reserve0) / 10 ** decimals0;
  const norm1 = Number(reserve1) / 10 ** decimals1;

  const price0In1 = norm1 / norm0;
  const price1In0 = norm0 / norm1;

  return { price0In1, price1In0 };
}
