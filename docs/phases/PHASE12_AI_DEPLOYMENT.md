# Phase 12 — AI Chatbot Assistant Deployment & Security Guardrails

## 1. AI Integration Topology
- Connects to Phase 12 read API for real-time market queries.
- **Strict Guardrail**: The AI assistant CANNOT hold private keys, cannot sign transactions, and cannot execute trades autonomously. All trade actions present structured calldata to the user's connected wallet for manual signature approval.
