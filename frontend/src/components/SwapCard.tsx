import React, { useState } from 'react';
import { ArrowDown, ChevronDown, Sparkles, RefreshCw } from 'lucide-react';
import { TokenMetadata } from '../config/tokens';
import { TokenSelectModal } from './TokenSelectModal';

interface SwapCardProps {
  tokenIn: TokenMetadata;
  tokenOut: TokenMetadata;
  amountIn: string;
  amountOut: string;
  setAmountIn: (val: string) => void;
  onSwitchTokens: () => void;
  availableTokens: TokenMetadata[];
  onSelectTokenIn: (token: TokenMetadata) => void;
  onSelectTokenOut: (token: TokenMetadata) => void;
  balanceIn: string;
  balanceOut: string;
  priceImpactBps: number;
  minimumReceived: string;
  route: string[];
  isQuoting: boolean;
  needsApproval: boolean;
  needsPermit2?: boolean;
  approvalType: 'exact' | 'unlimited';
  onApprove: () => void;
  onSignPermit2: () => void;
  onSwap: () => void;
  isActionPending: boolean;
  account: string | null;
  onConnect: () => void;
}

export const SwapCard: React.FC<SwapCardProps> = ({
  tokenIn,
  tokenOut,
  amountIn,
  amountOut,
  setAmountIn,
  onSwitchTokens,
  availableTokens,
  onSelectTokenIn,
  onSelectTokenOut,
  balanceIn,
  balanceOut,
  priceImpactBps,
  minimumReceived,
  route,
  isQuoting,
  needsApproval,
  needsPermit2: _needsPermit2,
  approvalType,
  onApprove,
  onSignPermit2,
  onSwap,
  isActionPending,
  account,
  onConnect
}) => {
  const [isSelectInOpen, setIsSelectInOpen] = useState(false);
  const [isSelectOutOpen, setIsSelectOutOpen] = useState(false);

  const isInsufficientBalance = Boolean(
    account && amountIn && balanceIn && Number(amountIn) > Number(balanceIn)
  );

  return (
    <div className="glass-card p-6 w-full shadow-2xl relative">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="font-bold text-lg text-white">Swap Tokens</h2>
        <div className="text-xs text-slate-400 font-mono">v2 Constant-Product</div>
      </div>

      {/* Pay Input Box */}
      <div className="bg-slate-950/70 border border-white/10 rounded-2xl p-4 mb-2 hover:border-white/20 transition-all">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-semibold text-slate-400">You Pay</span>
          <div className="flex items-center gap-2 text-xs font-mono text-slate-400">
            <span>Balance: {balanceIn || '0.00'}</span>
            <button
              onClick={() => setAmountIn(balanceIn || '0')}
              className="text-indigo-400 hover:text-indigo-300 font-bold uppercase"
            >
              Max
            </button>
          </div>
        </div>

        <div className="flex items-center justify-between gap-4">
          <input
            type="text"
            value={amountIn}
            onChange={(e) => setAmountIn(e.target.value)}
            placeholder="0.0"
            className="w-full bg-transparent text-3xl font-bold font-mono text-white outline-none"
          />

          <button
            onClick={() => setIsSelectInOpen(true)}
            className="flex items-center gap-2 px-3 py-2 rounded-xl bg-slate-900 border border-white/10 hover:border-indigo-500/50 transition-all shrink-0"
          >
            <div className="w-6 h-6 rounded-full bg-indigo-500/20 text-indigo-400 flex items-center justify-center text-xs font-bold">
              {tokenIn.symbol.slice(0, 3)}
            </div>
            <span className="font-bold text-sm text-white">{tokenIn.symbol}</span>
            <ChevronDown className="w-4 h-4 text-slate-400" />
          </button>
        </div>
      </div>

      {/* Flip Button */}
      <div className="flex justify-center -my-3 relative z-10">
        <button
          onClick={onSwitchTokens}
          className="p-2.5 rounded-xl bg-slate-900 border border-white/10 hover:border-indigo-500 hover:rotate-180 transition-all duration-300 shadow-lg"
          title="Switch token direction"
        >
          <ArrowDown className="w-4 h-4 text-indigo-400" />
        </button>
      </div>

      {/* Receive Input Box */}
      <div className="bg-slate-950/70 border border-white/10 rounded-2xl p-4 mt-2 mb-4 hover:border-white/20 transition-all">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-semibold text-slate-400">You Receive (Estimated)</span>
          <span className="text-xs font-mono text-slate-400">Balance: {balanceOut || '0.00'}</span>
        </div>

        <div className="flex items-center justify-between gap-4">
          <input
            type="text"
            value={isQuoting ? 'Fetching quote...' : amountOut}
            readOnly
            placeholder="0.0"
            className="w-full bg-transparent text-3xl font-bold font-mono text-white outline-none"
          />

          <button
            onClick={() => setIsSelectOutOpen(true)}
            className="flex items-center gap-2 px-3 py-2 rounded-xl bg-slate-900 border border-white/10 hover:border-indigo-500/50 transition-all shrink-0"
          >
            <div className="w-6 h-6 rounded-full bg-cyan-500/20 text-cyan-400 flex items-center justify-center text-xs font-bold">
              {tokenOut.symbol.slice(0, 3)}
            </div>
            <span className="font-bold text-sm text-white">{tokenOut.symbol}</span>
            <ChevronDown className="w-4 h-4 text-slate-400" />
          </button>
        </div>
      </div>

      {/* Quote Details Accordion */}
      {amountOut && Number(amountOut) > 0 && (
        <div className="p-4 rounded-xl bg-slate-950/40 border border-white/5 space-y-2 mb-6 text-xs">
          <div className="flex items-center justify-between text-slate-400">
            <span>Price Impact</span>
            <span
              className={
                priceImpactBps < 100
                  ? 'badge-impact-low'
                  : 'badge-impact-high'
              }
            >
              {(priceImpactBps / 100).toFixed(2)}%
            </span>
          </div>

          <div className="flex items-center justify-between text-slate-400">
            <span>Minimum Received</span>
            <span className="font-mono text-slate-200">
              {minimumReceived} {tokenOut.symbol}
            </span>
          </div>

          <div className="flex items-center justify-between text-slate-400">
            <span>Route</span>
            <span className="font-mono text-indigo-400">
              {route.join(' → ')}
            </span>
          </div>
        </div>
      )}

      {/* Main Execution Actions */}
      {!account ? (
        <button onClick={onConnect} className="btn-primary">
          Connect Wallet to Swap
        </button>
      ) : isInsufficientBalance ? (
        <button disabled className="btn-primary opacity-60">
          Insufficient {tokenIn.symbol} Balance
        </button>
      ) : !amountIn || Number(amountIn) === 0 ? (
        <button disabled className="btn-primary opacity-60">
          Enter an Amount
        </button>
      ) : needsApproval ? (
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={onApprove}
            disabled={isActionPending}
            className="btn-primary bg-indigo-600 hover:bg-indigo-700"
          >
            {isActionPending ? (
              <RefreshCw className="w-4 h-4 animate-spin" />
            ) : (
              `Approve ${tokenIn.symbol} (${approvalType})`
            )}
          </button>
          <button
            onClick={onSignPermit2}
            disabled={isActionPending}
            className="btn-secondary justify-center text-indigo-300 hover:bg-indigo-500/10"
          >
            <Sparkles className="w-4 h-4" />
            Sign Permit2 (Gasless)
          </button>
        </div>
      ) : (
        <button
          onClick={onSwap}
          disabled={isActionPending || isQuoting}
          className="btn-primary"
        >
          {isActionPending ? (
            <RefreshCw className="w-5 h-5 animate-spin" />
          ) : (
            'Execute Swap'
          )}
        </button>
      )}

      {/* Modals */}
      <TokenSelectModal
        isOpen={isSelectInOpen}
        onClose={() => setIsSelectInOpen(false)}
        tokens={availableTokens}
        onSelectToken={onSelectTokenIn}
        selectedTokenAddress={tokenIn.address}
      />
      <TokenSelectModal
        isOpen={isSelectOutOpen}
        onClose={() => setIsSelectOutOpen(false)}
        tokens={availableTokens}
        onSelectToken={onSelectTokenOut}
        selectedTokenAddress={tokenOut.address}
      />
    </div>
  );
};
