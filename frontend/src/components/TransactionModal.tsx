import React from 'react';
import { X, CheckCircle2, AlertCircle, RefreshCw, ExternalLink } from 'lucide-react';
import { DecodedError } from '../lib/errorDecoder';

export type TxStatus =
  | 'IDLE'
  | 'SIGNING'
  | 'SUBMITTED'
  | 'PENDING'
  | 'CONFIRMED'
  | 'FAILED'
  | 'REJECTED';

interface TransactionModalProps {
  isOpen: boolean;
  onClose: () => void;
  status: TxStatus;
  txHash: `0x${string}` | null;
  error: DecodedError | null;
  summary: string;
  chainId: number;
}

export const TransactionModal: React.FC<TransactionModalProps> = ({
  isOpen,
  onClose,
  status,
  txHash,
  error,
  summary,
  chainId
}) => {
  if (!isOpen || status === 'IDLE') return null;

  return (
    <div className="modal-backdrop">
      <div className="glass-card max-w-md w-full p-6 text-center relative animate-in fade-in zoom-in duration-200">
        <button
          onClick={onClose}
          className="absolute right-4 top-4 text-slate-400 hover:text-white transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Status Graphic */}
        <div className="my-4 flex justify-center">
          {status === 'SIGNING' || status === 'SUBMITTED' || status === 'PENDING' ? (
            <div className="w-16 h-16 rounded-full bg-indigo-500/10 border border-indigo-500/30 flex items-center justify-center">
              <RefreshCw className="w-8 h-8 text-indigo-400 animate-spin" />
            </div>
          ) : status === 'CONFIRMED' ? (
            <div className="w-16 h-16 rounded-full bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center">
              <CheckCircle2 className="w-8 h-8 text-emerald-400" />
            </div>
          ) : (
            <div className="w-16 h-16 rounded-full bg-rose-500/10 border border-rose-500/30 flex items-center justify-center">
              <AlertCircle className="w-8 h-8 text-rose-400" />
            </div>
          )}
        </div>

        {/* Title */}
        <h3 className="text-xl font-bold text-white mb-2">
          {status === 'SIGNING'
            ? 'Sign in Wallet'
            : status === 'PENDING' || status === 'SUBMITTED'
            ? 'Transaction Submitted'
            : status === 'CONFIRMED'
            ? 'Transaction Confirmed'
            : error?.title || 'Transaction Failed'}
        </h3>

        <p className="text-sm text-slate-400 mb-4">{summary}</p>

        {/* Error Details */}
        {error && (status === 'FAILED' || status === 'REJECTED') && (
          <div className="p-4 rounded-xl bg-rose-500/10 border border-rose-500/20 text-left mb-6 text-xs text-rose-200">
            <div className="font-bold mb-1">{error.title}</div>
            <div className="text-slate-300 mb-2">{error.message}</div>
            {error.actionHint && (
              <div className="text-rose-300 font-semibold">{error.actionHint}</div>
            )}
          </div>
        )}

        {/* Tx Hash Link */}
        {txHash && (
          <div className="mb-6">
            <a
              href={`https://${chainId === 11155111 ? 'sepolia.' : ''}etherscan.io/tx/${txHash}`}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1 text-xs text-indigo-400 hover:text-indigo-300 font-mono"
            >
              <span>View on Explorer: {txHash.slice(0, 10)}...</span>
              <ExternalLink className="w-3 h-3" />
            </a>
          </div>
        )}

        <button
          onClick={onClose}
          className="btn-primary"
        >
          {status === 'CONFIRMED' || status === 'FAILED' || status === 'REJECTED'
            ? 'Close'
            : 'Dismiss Preview'}
        </button>
      </div>
    </div>
  );
};
