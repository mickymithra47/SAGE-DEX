import React, { useState } from 'react';
import { RefreshCw } from 'lucide-react';
import { TokenMetadata } from '../config/tokens';

interface LiquidityCardProps {
  tokenA: TokenMetadata;
  tokenB: TokenMetadata;
  amountA: string;
  amountB: string;
  setAmountA: (val: string) => void;
  setAmountB: (val: string) => void;
  balanceA: string;
  balanceB: string;
  lpBalance: string;
  poolShare: string;
  onAddLiquidity: () => void;
  onRemoveLiquidity: () => void;
  isActionPending: boolean;
  account: string | null;
  onConnect: () => void;
}

export const LiquidityCard: React.FC<LiquidityCardProps> = ({
  tokenA,
  tokenB,
  amountA,
  amountB,
  setAmountA,
  setAmountB,
  balanceA,
  balanceB,
  lpBalance,
  poolShare,
  onAddLiquidity,
  onRemoveLiquidity,
  isActionPending,
  account,
  onConnect
}) => {
  const [activeSubTab, setActiveSubTab] = useState<'add' | 'remove'>('add');
  const [removePercent, setRemovePercent] = useState<number>(25);

  return (
    <div className="glass-card p-6 w-full shadow-2xl relative">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <h2 className="font-bold text-lg text-white">Liquidity Positions</h2>
        <div className="flex items-center gap-2 p-1 bg-slate-900/80 rounded-xl border border-white/10 text-xs">
          <button
            onClick={() => setActiveSubTab('add')}
            className={`px-3 py-1.5 rounded-lg font-semibold transition-all ${
              activeSubTab === 'add' ? 'bg-indigo-500 text-white' : 'text-slate-400 hover:text-white'
            }`}
          >
            Add
          </button>
          <button
            onClick={() => setActiveSubTab('remove')}
            className={`px-3 py-1.5 rounded-lg font-semibold transition-all ${
              activeSubTab === 'remove' ? 'bg-indigo-500 text-white' : 'text-slate-400 hover:text-white'
            }`}
          >
            Remove
          </button>
        </div>
      </div>

      {activeSubTab === 'add' ? (
        <div>
          {/* Token A Input */}
          <div className="bg-slate-950/70 border border-white/10 rounded-2xl p-4 mb-3">
            <div className="flex items-center justify-between mb-2 text-xs text-slate-400">
              <span>Deposit {tokenA.symbol}</span>
              <span>Balance: {balanceA || '0.00'}</span>
            </div>
            <div className="flex items-center justify-between gap-4">
              <input
                type="text"
                value={amountA}
                onChange={(e) => setAmountA(e.target.value)}
                placeholder="0.0"
                className="w-full bg-transparent text-2xl font-bold font-mono text-white outline-none"
              />
              <span className="font-bold text-sm text-slate-300">{tokenA.symbol}</span>
            </div>
          </div>

          {/* Token B Input */}
          <div className="bg-slate-950/70 border border-white/10 rounded-2xl p-4 mb-4">
            <div className="flex items-center justify-between mb-2 text-xs text-slate-400">
              <span>Deposit {tokenB.symbol}</span>
              <span>Balance: {balanceB || '0.00'}</span>
            </div>
            <div className="flex items-center justify-between gap-4">
              <input
                type="text"
                value={amountB}
                onChange={(e) => setAmountB(e.target.value)}
                placeholder="0.0"
                className="w-full bg-transparent text-2xl font-bold font-mono text-white outline-none"
              />
              <span className="font-bold text-sm text-slate-300">{tokenB.symbol}</span>
            </div>
          </div>

          {/* Pool Share Preview */}
          <div className="p-4 rounded-xl bg-slate-950/40 border border-white/5 space-y-2 mb-6 text-xs">
            <div className="flex items-center justify-between text-slate-400">
              <span>Your LP Shares</span>
              <span className="font-mono text-slate-200">{lpBalance || '0.00'} LP</span>
            </div>
            <div className="flex items-center justify-between text-slate-400">
              <span>Current Pool Share</span>
              <span className="font-mono text-emerald-400">{poolShare || '0.00%'}</span>
            </div>
          </div>

          {!account ? (
            <button onClick={onConnect} className="btn-primary">
              Connect Wallet
            </button>
          ) : (
            <button
              onClick={onAddLiquidity}
              disabled={isActionPending || !amountA || !amountB}
              className="btn-primary"
            >
              {isActionPending ? (
                <RefreshCw className="w-5 h-5 animate-spin" />
              ) : (
                'Supply Liquidity'
              )}
            </button>
          )}
        </div>
      ) : (
        <div>
          {/* Remove Liquidity Percent Buttons */}
          <div className="bg-slate-950/70 border border-white/10 rounded-2xl p-5 mb-4">
            <div className="text-xs text-slate-400 mb-3">Amount to Remove</div>
            <div className="text-4xl font-mono font-bold text-white mb-4">
              {removePercent}%
            </div>
            <div className="grid grid-cols-4 gap-2">
              {[25, 50, 75, 100].map((pct) => (
                <button
                  key={pct}
                  onClick={() => setRemovePercent(pct)}
                  className={`py-2 rounded-xl text-sm font-semibold transition-all ${
                    removePercent === pct
                      ? 'bg-indigo-500 text-white'
                      : 'bg-slate-900 border border-white/5 text-slate-400 hover:text-white'
                  }`}
                >
                  {pct}%
                </button>
              ))}
            </div>
          </div>

          <div className="p-4 rounded-xl bg-slate-950/40 border border-white/5 space-y-2 mb-6 text-xs text-slate-400">
            <div className="flex items-center justify-between">
              <span>LP Balance Available</span>
              <span className="font-mono text-slate-200">{lpBalance || '0.00'} LP</span>
            </div>
          </div>

          {!account ? (
            <button onClick={onConnect} className="btn-primary">
              Connect Wallet
            </button>
          ) : (
            <button
              onClick={onRemoveLiquidity}
              disabled={isActionPending || !lpBalance || Number(lpBalance) === 0}
              className="btn-primary"
            >
              {isActionPending ? (
                <RefreshCw className="w-5 h-5 animate-spin" />
              ) : (
                'Remove Liquidity'
              )}
            </button>
          )}
        </div>
      )}
    </div>
  );
};
