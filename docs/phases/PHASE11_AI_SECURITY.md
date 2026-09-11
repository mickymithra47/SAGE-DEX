# Phase 11 — AI Assistant Security & Sandboxing

## 1. AI Sandboxing & Invariants
- **Non-Execution Invariant**: The AI assistant CANNOT execute transactions autonomously.
- **Zero Custody**: The AI assistant never receives private keys, seed phrases, or wallet secrets.
- **Prompt Injection Defense**: Any intent constructed by the AI (e.g. "Swap 10 ETH for USDC") must be reviewed, confirmed, and signed by the user's external wallet.
