import React, { useState } from 'react';
import { X, Search, Check, Sparkles } from 'lucide-react';
import { TokenMetadata } from '../config/tokens';

interface TokenSelectModalProps {
  isOpen: boolean;
  onClose: () => void;
  tokens: TokenMetadata[];
  onSelectToken: (token: TokenMetadata) => void;
  selectedTokenAddress?: string;
}

export const TokenSelectModal: React.FC<TokenSelectModalProps> = ({
  isOpen,
  onClose,
  tokens,
  onSelectToken,
  selectedTokenAddress
}) => {
  const [search, setSearch] = useState('');

  if (!isOpen) return null;

  const filteredTokens = tokens.filter((t) => {
    const s = search.toLowerCase().trim();
    if (!s) return true;
    return (
      t.symbol.toLowerCase().includes(s) ||
      t.name.toLowerCase().includes(s) ||
      t.address.toLowerCase().includes(s)
    );
  });

  return (
    <div className="modal-backdrop">
      <div className="glass-card max-w-md w-full p-6 relative animate-in fade-in zoom-in duration-200">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-indigo-400" />
            <h3 className="text-lg font-bold text-white">Select a Token</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search Input */}
        <div className="relative mb-4">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3.5" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search name, symbol, or address"
            className="w-full bg-slate-900/90 border border-white/10 rounded-xl py-3 pl-10 pr-4 text-sm text-white placeholder-slate-500 outline-none focus:border-indigo-500 font-mono"
            autoFocus
          />
        </div>

        {/* Token List */}
        <div className="max-h-72 overflow-y-auto space-y-1.5 pr-1">
          {filteredTokens.map((token) => {
            const isSelected = selectedTokenAddress?.toLowerCase() === token.address.toLowerCase();
            return (
              <button
                key={`${token.symbol}-${token.address}`}
                onClick={() => {
                  onSelectToken(token);
                  onClose();
                }}
                className={`w-full flex items-center justify-between p-3 rounded-xl transition-all ${
                  isSelected
                    ? 'bg-indigo-500/20 border border-indigo-500/40 text-white'
                    : 'hover:bg-slate-800/60 border border-transparent text-slate-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  {token.logoUrl ? (
                    <img
                      src={token.logoUrl}
                      alt={token.symbol}
                      className="w-8 h-8 rounded-full border border-white/10 p-0.5 bg-slate-950"
                      onError={(e) => {
                        (e.target as HTMLElement).style.display = 'none';
                      }}
                    />
                  ) : (
                    <div className="w-8 h-8 rounded-full bg-slate-800 border border-white/10 flex items-center justify-center font-bold text-xs text-indigo-400">
                      {token.symbol.slice(0, 3)}
                    </div>
                  )}
                  <div className="text-left">
                    <div className="font-bold text-sm text-white flex items-center gap-1.5">
                      {token.symbol}
                      {token.isNative && (
                        <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.2 rounded bg-indigo-500/20 text-indigo-300">
                          Native
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-slate-400">{token.name}</div>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <div className="text-xs font-mono text-slate-500">
                    {token.isNative || token.address === 'native'
                      ? 'Native Gas Asset'
                      : `${token.address.slice(0, 6)}...${token.address.slice(-4)}`}
                  </div>
                  {isSelected && <Check className="w-4 h-4 text-indigo-400" />}
                </div>
              </button>
            );
          })}

          {filteredTokens.length === 0 && (
            <div className="py-8 text-center text-slate-500 text-sm">
              No matching tokens found for this network
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
