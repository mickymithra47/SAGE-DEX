export interface ChainContracts {
  factory: `0x${string}`;
  router: `0x${string}`;
  permit2: `0x${string}`;
  weth: `0x${string}`;
}

export const CONTRACTS: Record<number, ChainContracts> = {
  // Anvil Local Fork / Devnet
  31337: {
    factory: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
    router: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
    permit2: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9',
    weth: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512'
  },
  // Sepolia Testnet
  11155111: {
    factory: '0x1111111111111111111111111111111111111111',
    router: '0x2222222222222222222222222222222222222222',
    permit2: '0x3333333333333333333333333333333333333333',
    weth: '0x4444444444444444444444444444444444444444'
  }
};

import { SUPPORTED_CHAINS } from './chains';

export { SUPPORTED_CHAINS };

export function getContractsForChain(chainId: number): ChainContracts | undefined {
  return CONTRACTS[chainId];
}
