import { useState, useEffect } from 'react';
import { Header } from './components/Header';
import { SwapCard } from './components/SwapCard';
import { LiquidityCard } from './components/LiquidityCard';
import { SlippageModal } from './components/SlippageModal';
import { TransactionModal, TxStatus } from './components/TransactionModal';
import { NetworkSelectModal } from './components/NetworkSelectModal';
import { getTokensForChain, TokenMetadata } from './config/tokens';
import { getAmountOut, calculatePriceImpactBps, calculateMinimumOutput, formatUnits, parseUnits } from './lib/math';
import { DecodedError } from './lib/errorDecoder';

export function App() {
  const [chainId, setChainId] = useState<number>(31337);
  const [isNetworkModalOpen, setIsNetworkModalOpen] = useState(false);
  const tokens = getTokensForChain(chainId);

  // Active Tab
  const [activeTab, setActiveTab] = useState<'swap' | 'liquidity'>('swap');

  // Wallet State
  const [account, setAccount] = useState<`0x${string}` | null>(null);

  // Settings State
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [slippageBps, setSlippageBps] = useState(50); // 0.5%
  const [deadlineMinutes, setDeadlineMinutes] = useState(5);
  const [approvalType, setApprovalType] = useState<'exact' | 'unlimited'>('exact');

  // Token & Amount State
  const [tokenIn, setTokenIn] = useState<TokenMetadata>(tokens[2] || tokens[0]); // USDC
  const [tokenOut, setTokenOut] = useState<TokenMetadata>(tokens[1] || tokens[0]); // WETH
  const [amountIn, setAmountIn] = useState<string>('10');
  const [amountOut, setAmountOut] = useState<string>('');

  // Handle Network Switching
  const handleSelectChain = (newChainId: number) => {
    setChainId(newChainId);
    const newTokens = getTokensForChain(newChainId);
    if (newTokens.length >= 2) {
      setTokenIn(newTokens[0]);
      setTokenOut(newTokens[1]);
    } else if (newTokens.length === 1) {
      setTokenIn(newTokens[0]);
      setTokenOut(newTokens[0]);
    }
  };

  // Balances
  const [balanceIn] = useState<string>('1000.00');
  const [balanceOut] = useState<string>('5.50');
  const [needsApproval, setNeedsApproval] = useState<boolean>(true);
  const [isQuoting, setIsQuoting] = useState<boolean>(false);
  const [priceImpactBps, setPriceImpactBps] = useState<number>(12); // 0.12%
  const [minimumReceived, setMinimumReceived] = useState<string>('0.0049');

  // Transaction Status State
  const [txModalOpen, setTxModalOpen] = useState<boolean>(false);
  const [txStatus, setTxStatus] = useState<TxStatus>('IDLE');
  const [txHash, setTxHash] = useState<`0x${string}` | null>(null);
  const [txError] = useState<DecodedError | null>(null);
  const [txSummary, setTxSummary] = useState<string>('');
  const [isActionPending, setIsActionPending] = useState<boolean>(false);

  // Liquidity State
  const [amountA, setAmountA] = useState<string>('');
  const [amountB, setAmountB] = useState<string>('');
  const [lpBalance] = useState<string>('14.14');

  // Connect Wallet Simulation / Injected
  const handleConnect = async () => {
    if (typeof window !== 'undefined' && (window as any).ethereum) {
      try {
        const accounts = await (window as any).ethereum.request({ method: 'eth_requestAccounts' });
        if (accounts && accounts.length > 0) {
          setAccount(accounts[0]);
        }
      } catch {
        // Fallback to devnet address
        setAccount('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      }
    } else {
      // Mock wallet for testing
      setAccount('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
    }
  };

  const handleDisconnect = () => {
    setAccount(null);
  };

  // Switch Token Direction
  const handleSwitchTokens = () => {
    const prevIn = tokenIn;
    const prevOut = tokenOut;
    setTokenIn(prevOut);
    setTokenOut(prevIn);
    setAmountIn(amountOut);
  };

  // Dynamic Quote Calculation
  useEffect(() => {
    if (!amountIn || Number(amountIn) <= 0) {
      setAmountOut('');
      return;
    }

    setIsQuoting(true);
    const timer = setTimeout(() => {
      try {
        const parsedIn = parseUnits(amountIn, tokenIn.decimals);
        // Simulation reserves: 10,000 : 20,000
        const rIn = parseUnits('10000', tokenIn.decimals);
        const rOut = parseUnits('20000', tokenOut.decimals);

        const out = getAmountOut(parsedIn, rIn, rOut);
        const formattedOut = formatUnits(out, tokenOut.decimals, 6);
        setAmountOut(formattedOut);

        const impact = calculatePriceImpactBps(parsedIn, out, rIn, rOut);
        setPriceImpactBps(impact);

        const minOut = calculateMinimumOutput(out, slippageBps);
        setMinimumReceived(formatUnits(minOut, tokenOut.decimals, 6));
      } catch {
        setAmountOut('0');
      } finally {
        setIsQuoting(false);
      }
    }, 200);

    return () => clearTimeout(timer);
  }, [amountIn, tokenIn, tokenOut, slippageBps]);

  // Execute Approve
  const handleApprove = async () => {
    setIsActionPending(true);
    setTxStatus('SIGNING');
    setTxSummary(`Approving ${tokenIn.symbol} for Sage Router`);
    setTxModalOpen(true);

    setTimeout(() => {
      setTxStatus('CONFIRMED');
      setNeedsApproval(false);
      setIsActionPending(false);
      setTxSummary(`Successfully approved ${tokenIn.symbol}!`);
    }, 1200);
  };

  // Execute Permit2 Sign
  const handleSignPermit2 = async () => {
    setIsActionPending(true);
    setTxStatus('SIGNING');
    setTxSummary(`Signing EIP-712 Permit2 authorization for ${tokenIn.symbol}`);
    setTxModalOpen(true);

    setTimeout(() => {
      setTxStatus('CONFIRMED');
      setNeedsApproval(false);
      setIsActionPending(false);
      setTxSummary(`Permit2 signature successfully authorized!`);
    }, 1000);
  };

  // Execute Swap
  const handleSwap = async () => {
    setIsActionPending(true);
    setTxStatus('SIGNING');
    setTxSummary(`Swapping ${amountIn} ${tokenIn.symbol} for minimum ${minimumReceived} ${tokenOut.symbol}`);
    setTxModalOpen(true);

    setTimeout(() => {
      setTxStatus('CONFIRMED');
      setTxHash('0x9a8f4c21b34e567890abcdef1234567890abcdef1234567890abcdef12345678');
      setIsActionPending(false);
      setTxSummary(`Successfully swapped ${amountIn} ${tokenIn.symbol} for ${amountOut} ${tokenOut.symbol}!`);
    }, 1500);
  };

  // Add / Remove Liquidity
  const handleAddLiquidity = async () => {
    setIsActionPending(true);
    setTxStatus('SIGNING');
    setTxSummary(`Supplying ${amountA} ${tokenIn.symbol} and ${amountB} ${tokenOut.symbol}`);
    setTxModalOpen(true);

    setTimeout(() => {
      setTxStatus('CONFIRMED');
      setIsActionPending(false);
      setTxSummary(`Successfully supplied liquidity! LP tokens minted.`);
    }, 1200);
  };

  const handleRemoveLiquidity = async () => {
    setIsActionPending(true);
    setTxStatus('SIGNING');
    setTxSummary(`Removing liquidity and burning LP tokens`);
    setTxModalOpen(true);

    setTimeout(() => {
      setTxStatus('CONFIRMED');
      setIsActionPending(false);
      setTxSummary(`Liquidity removed and underlying tokens returned.`);
    }, 1200);
  };

  return (
    <div className="min-h-screen flex flex-col justify-between">
      <div>
        <Header
          account={account}
          chainId={chainId}
          onConnect={handleConnect}
          onDisconnect={handleDisconnect}
          onOpenSettings={() => setIsSettingsOpen(true)}
          onOpenNetworkSelect={() => setIsNetworkModalOpen(true)}
          activeTab={activeTab}
          setActiveTab={setActiveTab}
        />

        <main className="app-container">
          <div className="swap-container">
            {activeTab === 'swap' ? (
              <SwapCard
                tokenIn={tokenIn}
                tokenOut={tokenOut}
                amountIn={amountIn}
                amountOut={amountOut}
                setAmountIn={setAmountIn}
                onSwitchTokens={handleSwitchTokens}
                availableTokens={tokens}
                onSelectTokenIn={setTokenIn}
                onSelectTokenOut={setTokenOut}
                balanceIn={balanceIn}
                balanceOut={balanceOut}
                priceImpactBps={priceImpactBps}
                minimumReceived={minimumReceived}
                route={[tokenIn.symbol, tokenOut.symbol]}
                isQuoting={isQuoting}
                needsApproval={needsApproval}
                needsPermit2={true}
                approvalType={approvalType}
                onApprove={handleApprove}
                onSignPermit2={handleSignPermit2}
                onSwap={handleSwap}
                isActionPending={isActionPending}
                account={account}
                onConnect={handleConnect}
              />
            ) : (
              <LiquidityCard
                tokenA={tokenIn}
                tokenB={tokenOut}
                amountA={amountA}
                amountB={amountB}
                setAmountA={setAmountA}
                setAmountB={setAmountB}
                balanceA={balanceIn}
                balanceB={balanceOut}
                lpBalance={lpBalance}
                poolShare="0.45%"
                onAddLiquidity={handleAddLiquidity}
                onRemoveLiquidity={handleRemoveLiquidity}
                isActionPending={isActionPending}
                account={account}
                onConnect={handleConnect}
              />
            )}
          </div>
        </main>
      </div>

      <footer className="py-6 text-center text-xs text-slate-500 font-mono border-t border-white/5">
        SAGE DEX Protocol • EVM Cancun Engine • Solidity 0.8.26 • Zero-Precision Loss
      </footer>

      {/* Network Select Modal */}
      <NetworkSelectModal
        isOpen={isNetworkModalOpen}
        onClose={() => setIsNetworkModalOpen(false)}
        currentChainId={chainId}
        onSelectChain={handleSelectChain}
      />

      {/* Settings Modal */}
      <SlippageModal
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
        slippageBps={slippageBps}
        setSlippageBps={setSlippageBps}
        deadlineMinutes={deadlineMinutes}
        setDeadlineMinutes={setDeadlineMinutes}
        approvalType={approvalType}
        setApprovalType={setApprovalType}
      />

      {/* Transaction Progress Modal */}
      <TransactionModal
        isOpen={txModalOpen}
        onClose={() => setTxModalOpen(false)}
        status={txStatus}
        txHash={txHash}
        error={txError}
        summary={txSummary}
        chainId={chainId}
      />
    </div>
  );
}

export default App;
