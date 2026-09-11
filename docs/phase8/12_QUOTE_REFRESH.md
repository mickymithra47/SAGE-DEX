# 12 — Quote Debounce & Refresh Mechanics

## 1. Debounce Strategy
- When user types input amount, quote query is debounced by 200ms to prevent RPC spam.
- Triggers immediate re-fetch on:
  - Token selection change
  - Token switch direction
  - Network switch
  - Block timestamp update
