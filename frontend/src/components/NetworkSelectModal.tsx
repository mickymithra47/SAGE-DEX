import React from 'react';
import { X, Check, Globe } from 'lucide-react';
import { getV1EVMChains, getChainConfig, ChainConfig } from '../config/chains';

interface NetworkSelectModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentChainId: number;
  onSelectChain: (chainId: number) => void;
}

export const NetworkSelectModal: React.FC<NetworkSelectModalProps> = ({
  isOpen,
  onClose,
  currentChainId,
  onSelectChain
}) => {
  if (!isOpen) return null;

  const v1Chains = getV1EVMChains();
  const anvilConfig = getChainConfig(31337);
  const displayChains: ChainConfig[] = [...v1Chains];
  if (anvilConfig && !displayChains.some((c) => c.id === 31337)) {
    displayChains.push(anvilConfig);
  }

  return (
    <div className="modal-backdrop">
      <div className="glass-card max-w-md w-full p-6 relative animate-in fade-in zoom-in duration-200">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Globe className="w-5 h-5 text-indigo-400" />
            <h3 className="text-lg font-bold text-white">Select Network</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        <p className="text-xs text-slate-400 mb-4">
          Select an active SAGE DEX EVM network. SAGE aggregates liquidity and routes trades across these chains.
        </p>

        {/* Network List */}
        <div className="space-y-2">
          {displayChains.map((chain) => {
            const isSelected = currentChainId === chain.id;
            return (
              <button
                key={chain.id}
                onClick={() => {
                  onSelectChain(chain.id);
                  onClose();
                }}
                className={`w-full flex items-center justify-between p-3.5 rounded-xl transition-all ${
                  isSelected
                    ? 'bg-indigo-500/20 border border-indigo-500/40 text-white'
                    : 'bg-slate-900/60 hover:bg-slate-800/80 border border-white/5 text-slate-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  {chain.logoUrl ? (
                    <img
                      src={chain.logoUrl}
                      alt={chain.shortName}
                      className="w-8 h-8 rounded-full border border-white/10 p-0.5 bg-slate-950"
                      onError={(e) => {
                        (e.target as HTMLElement).style.display = 'none';
                      }}
                    />
                  ) : (
                    <div className="w-8 h-8 rounded-full bg-slate-800 border border-white/10 flex items-center justify-center font-bold text-xs text-indigo-400">
                      {chain.shortName.slice(0, 2)}
                    </div>
                  )}
                  <div className="text-left">
                    <div className="font-bold text-sm text-white flex items-center gap-2">
                      {chain.name}
                      {chain.isV1Launch && (
                        <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                          V1 Active
                        </span>
                      )}
                      {chain.isTestnet && (
                        <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.5 rounded bg-amber-500/10 text-amber-400 border border-amber-500/20">
                          Devnet
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-slate-400">
                      Native: {chain.nativeCurrency.symbol} • Chain ID: {chain.id}
                    </div>
                  </div>
                </div>

                {isSelected && (
                  <div className="w-6 h-6 rounded-full bg-indigo-500/20 flex items-center justify-center text-indigo-400">
                    <Check className="w-4 h-4" />
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
