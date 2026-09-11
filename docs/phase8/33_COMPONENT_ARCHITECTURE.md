# 33 — UI Component Architecture & Design System

## 1. Component Hierarchy
- `App.tsx`
  - `Header.tsx` (Brand, Network, Account, Settings Trigger)
  - `SwapCard.tsx` (Token Inputs, Quote Display, Action Buttons)
  - `LiquidityCard.tsx` (Add/Remove Liquidity, LP Share Breakdown)
  - `TokenSelectModal.tsx` (Search, Token Whitelist)
  - `SlippageModal.tsx` (BPS Configuration, Deadline)
  - `TransactionModal.tsx` (Progress Tracker, Error Decoding)
