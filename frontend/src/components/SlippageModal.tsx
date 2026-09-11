import React from 'react';
import { X, AlertTriangle } from 'lucide-react';

interface SlippageModalProps {
  isOpen: boolean;
  onClose: () => void;
  slippageBps: number;
  setSlippageBps: (bps: number) => void;
  deadlineMinutes: number;
  setDeadlineMinutes: (minutes: number) => void;
  approvalType: 'exact' | 'unlimited';
  setApprovalType: (type: 'exact' | 'unlimited') => void;
}

export const SlippageModal: React.FC<SlippageModalProps> = ({
  isOpen,
  onClose,
  slippageBps,
  setSlippageBps,
  deadlineMinutes,
  setDeadlineMinutes,
  approvalType,
  setApprovalType
}) => {
  if (!isOpen) return null;

  const presets = [
    { label: '0.1%', bps: 10 },
    { label: '0.5%', bps: 50 },
    { label: '1.0%', bps: 100 }
  ];

  return (
    <div className="modal-backdrop">
      <div className="glass-card max-w-md w-full p-6 relative animate-in fade-in zoom-in duration-200">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-bold text-white">Transaction Settings</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Slippage Tolerance */}
        <div className="mb-6">
          <label className="block text-sm font-medium text-slate-300 mb-2">
            Slippage Tolerance
          </label>
          <div className="grid grid-cols-4 gap-2">
            {presets.map((preset) => (
              <button
                key={preset.bps}
                onClick={() => setSlippageBps(preset.bps)}
                className={`py-2 rounded-xl text-sm font-semibold transition-all ${
                  slippageBps === preset.bps
                    ? 'bg-indigo-500 text-white shadow-lg shadow-indigo-500/30'
                    : 'bg-slate-900/90 text-slate-400 hover:text-white border border-white/5'
                }`}
              >
                {preset.label}
              </button>
            ))}
            <div className="relative">
              <input
                type="number"
                value={(slippageBps / 100).toString()}
                onChange={(e) => setSlippageBps(Math.max(1, Math.round(Number(e.target.value || 0) * 100)))}
                className="w-full h-full bg-slate-900/90 border border-white/10 rounded-xl px-3 text-sm font-mono text-white text-center outline-none focus:border-indigo-500"
                placeholder="Custom"
              />
              <span className="absolute right-2 top-2 text-xs text-slate-500 font-mono">%</span>
            </div>
          </div>

          {slippageBps > 300 && (
            <div className="mt-3 flex items-start gap-2 p-3 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-300 text-xs">
              <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
              <span>High slippage increases the risk of front-running / MEV extraction.</span>
            </div>
          )}
        </div>

        {/* Transaction Deadline */}
        <div className="mb-6">
          <label className="block text-sm font-medium text-slate-300 mb-2">
            Transaction Deadline
          </label>
          <div className="flex items-center gap-3">
            <input
              type="number"
              min="1"
              max="60"
              value={deadlineMinutes}
              onChange={(e) => setDeadlineMinutes(Math.max(1, Number(e.target.value || 1)))}
              className="w-24 bg-slate-900/90 border border-white/10 rounded-xl p-2.5 text-sm font-mono text-white text-center outline-none focus:border-indigo-500"
            />
            <span className="text-sm text-slate-400">minutes</span>
          </div>
        </div>

        {/* Approval Preference */}
        <div className="mb-6">
          <label className="block text-sm font-medium text-slate-300 mb-2">
            ERC-20 Approval Policy
          </label>
          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => setApprovalType('exact')}
              className={`p-3 rounded-xl text-left border transition-all ${
                approvalType === 'exact'
                  ? 'bg-indigo-500/10 border-indigo-500 text-white'
                  : 'bg-slate-900/60 border-white/5 text-slate-400 hover:text-white'
              }`}
            >
              <div className="font-semibold text-sm">Exact Amount</div>
              <div className="text-xs text-slate-400 mt-1">Safest. Zero residual risk.</div>
            </button>
            <button
              onClick={() => setApprovalType('unlimited')}
              className={`p-3 rounded-xl text-left border transition-all ${
                approvalType === 'unlimited'
                  ? 'bg-indigo-500/10 border-indigo-500 text-white'
                  : 'bg-slate-900/60 border-white/5 text-slate-400 hover:text-white'
              }`}
            >
              <div className="font-semibold text-sm">Unlimited</div>
              <div className="text-xs text-slate-400 mt-1">One-time approve. Saves gas.</div>
            </button>
          </div>
        </div>

        <button
          onClick={onClose}
          className="btn-primary"
        >
          Save & Close
        </button>
      </div>
    </div>
  );
};
