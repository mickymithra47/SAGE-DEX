# Phase 10 — AI Assistant Data Interface Specification

## 1. Natural Language Query Interface
- Phase 9 AI Assistant accesses Phase 10 read resolvers for:
  - 24-hour pool trading volume and fees
  - Historical price candles and exchange rates
  - User swap history and LP equity summaries
- **Security Boundary**: The AI assistant never accesses private keys, never signs transactions, and never executes trades autonomously.
