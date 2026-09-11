import React from 'react';
import { Sliders, Wallet, CheckCircle2, ChevronDown, AlertTriangle } from 'lucide-react';
import { getChainConfig, isSupportedChain } from '../config/chains';

interface HeaderProps {
  account: `0x${string}` | null;
  chainId: number;
  onConnect: () => void;
  onDisconnect: () => void;
  onOpenSettings: () => void;
  onOpenNetworkSelect: () => void;
  activeTab: 'swap' | 'liquidity';
  setActiveTab: (tab: 'swap' | 'liquidity') => void;
}

export const Header: React.FC<HeaderProps> = ({
  account,
  chainId,
  onConnect,
  onDisconnect,
  onOpenSettings,
  onOpenNetworkSelect,
  activeTab,
  setActiveTab
}) => {
  const chainConfig = getChainConfig(chainId);
  const isSupported = isSupportedChain(chainId);

  return (
    <header className="flex items-center justify-between py-6 px-4 border-b border-white/5 backdrop-blur-md">
      {/* Brand & Tabs */}
      <div className="flex items-center gap-8">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-indigo-500 to-cyan-400 flex items-center justify-center font-extrabold text-white text-lg shadow-lg shadow-indigo-500/25">
            S
          </div>
          <span className="font-extrabold text-xl tracking-tight bg-gradient-to-r from-white via-slate-200 to-slate-400 bg-clip-text text-transparent">
            SAGE
          </span>
          <span className="text-xs uppercase tracking-widest px-2 py-0.5 rounded-full bg-indigo-500/10 text-indigo-400 font-semibold border border-indigo-500/20">
            DEX
          </span>
        </div>

        <nav className="flex items-center gap-6 text-sm font-medium">
          <button
            onClick={() => setActiveTab('swap')}
            className={activeTab === 'swap' ? 'tab-active' : 'tab-inactive'}
          >
            Swap
          </button>
          <button
            onClick={() => setActiveTab('liquidity')}
            className={activeTab === 'liquidity' ? 'tab-active' : 'tab-inactive'}
          >
            Liquidity
          </button>
        </nav>
      </div>

      {/* Network & Wallet Controls */}
      <div className="flex items-center gap-3">
        {/* Network Selector Button */}
        <button
          onClick={onOpenNetworkSelect}
          className={`flex items-center gap-2 px-3 py-1.5 rounded-xl border text-xs font-medium transition-all ${
            isSupported
              ? 'bg-slate-900/80 border-white/10 hover:border-indigo-500/50 text-slate-300'
              : 'bg-rose-500/10 border-rose-500/30 text-rose-300 hover:bg-rose-500/20'
          }`}
          title="Switch Network"
        >
          {isSupported ? (
            <>
              {chainConfig?.logoUrl ? (
                <img src={chainConfig.logoUrl} alt={chainConfig.shortName} className="w-4 h-4 rounded-full" />
              ) : (
                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              )}
              <span>{chainConfig?.shortName || `Chain ${chainId}`}</span>
            </>
          ) : (
            <>
              <AlertTriangle className="w-3.5 h-3.5 text-rose-400" />
              <span>Unsupported Network</span>
            </>
          )}
          <ChevronDown className="w-3 h-3 text-slate-400" />
        </button>

        {/* Settings Button */}
        <button
          onClick={onOpenSettings}
          className="p-2.5 rounded-xl bg-slate-900/80 border border-white/10 text-slate-400 hover:text-white hover:border-indigo-500/50 transition-all"
          title="Transaction Settings"
        >
          <Sliders className="w-4 h-4" />
        </button>

        {/* Wallet Button */}
        {account ? (
          <div className="flex items-center gap-2">
            <button
              onClick={onDisconnect}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-indigo-500/10 border border-indigo-500/30 text-indigo-300 hover:bg-indigo-500/20 transition-all text-sm font-mono"
            >
              <CheckCircle2 className="w-4 h-4 text-emerald-400" />
              {account.slice(0, 6)}...{account.slice(-4)}
            </button>
          </div>
        ) : (
          <button
            onClick={onConnect}
            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-indigo-500 to-indigo-600 hover:from-indigo-600 hover:to-indigo-700 text-white font-medium text-sm transition-all shadow-lg shadow-indigo-500/25"
          >
            <Wallet className="w-4 h-4" />
            Connect Wallet
          </button>
        )}
      </div>
    </header>
  );
};
