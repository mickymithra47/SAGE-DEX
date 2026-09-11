import { describe, it, expect } from 'vitest';
import { decodeContractError } from '../src/lib/errorDecoder';

describe('Phase 8 Error Decoder', () => {
  it('decodes Expired error', () => {
    const error = decodeContractError({ message: 'Execution reverted with Expired()' });
    expect(error.title).toBe('Transaction Expired');
  });

  it('decodes InsufficientOutput slippage error', () => {
    const error = decodeContractError({ message: 'revert: InsufficientOutput()' });
    expect(error.title).toBe('Slippage Tolerance Breached');
  });

  it('decodes PairNotFound error', () => {
    const error = decodeContractError({ message: 'revert: PairNotFound()' });
    expect(error.title).toBe('Pool Does Not Exist');
  });

  it('decodes User rejected wallet signature', () => {
    const error = decodeContractError({ message: 'User rejected the request.' });
    expect(error.title).toBe('Signature Rejected');
  });
});
