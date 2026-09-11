# Phase 12 — Step-by-Step Testnet Deployment Guide

## 1. Clean Environment Deployment Procedure

1. **Environment Setup**:
   ```bash
   cp .env.example .env
   # Populate RPC_URL and DEPLOYER_PRIVATE_KEY
   ```

2. **Smart Contract Compilation & Testing**:
   ```bash
   forge build
   forge test
   ```

3. **Deploy to Testnet**:
   ```bash
   forge script script/DeployPhase12Testnet.s.sol --rpc-url $RPC_URL --broadcast --verify
   ```

4. **Initialize PostgreSQL Database & Indexer**:
   ```bash
   psql -U postgres -d akira_indexer -f indexer/src/db/schema.sql
   cd indexer && npm start
   ```

5. **Start API & Frontend**:
   ```bash
   cd frontend && npm run dev
   ```
