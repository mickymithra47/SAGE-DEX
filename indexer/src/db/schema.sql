-- ============================================================
-- SAGE DEX PROTOCOL — PHASE 9 RELATIONAL INDEXER SCHEMA
-- Target Database: PostgreSQL 15+ / SQLite 3
-- ============================================================

-- 1. Blocks & Reorg Cursor
CREATE TABLE IF NOT EXISTS blocks (
    chain_id BIGINT NOT NULL,
    block_number BIGINT NOT NULL,
    block_hash VARCHAR(66) NOT NULL,
    parent_hash VARCHAR(66) NOT NULL,
    timestamp BIGINT NOT NULL,
    is_canonical BOOLEAN DEFAULT TRUE,
    indexed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (chain_id, block_number)
);

CREATE INDEX IF NOT EXISTS idx_blocks_hash ON blocks (chain_id, block_hash);
CREATE INDEX IF NOT EXISTS idx_blocks_canonical ON blocks (chain_id, is_canonical);

-- 2. Token Registry
CREATE TABLE IF NOT EXISTS tokens (
    chain_id BIGINT NOT NULL,
    address VARCHAR(42) NOT NULL,
    symbol VARCHAR(32),
    name VARCHAR(128),
    decimals INT NOT NULL,
    total_supply NUMERIC,
    indexed_at_block BIGINT NOT NULL,
    PRIMARY KEY (chain_id, address)
);

-- 3. Liquidity Pools (Pairs)
CREATE TABLE IF NOT EXISTS pools (
    chain_id BIGINT NOT NULL,
    address VARCHAR(42) NOT NULL,
    factory VARCHAR(42) NOT NULL,
    token0 VARCHAR(42) NOT NULL REFERENCES tokens (chain_id, address),
    token1 VARCHAR(42) NOT NULL REFERENCES tokens (chain_id, address),
    created_at_block BIGINT NOT NULL,
    created_at_timestamp BIGINT NOT NULL,
    created_tx_hash VARCHAR(66) NOT NULL,
    reserve0 NUMERIC DEFAULT 0,
    reserve1 NUMERIC DEFAULT 0,
    total_supply NUMERIC DEFAULT 0,
    PRIMARY KEY (chain_id, address)
);

CREATE INDEX IF NOT EXISTS idx_pools_tokens ON pools (chain_id, token0, token1);

-- 4. Swaps Table
CREATE TABLE IF NOT EXISTS swaps (
    chain_id BIGINT NOT NULL,
    block_number BIGINT NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    log_index INT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    sender VARCHAR(42) NOT NULL,
    recipient VARCHAR(42) NOT NULL,
    amount0_in NUMERIC NOT NULL,
    amount1_in NUMERIC NOT NULL,
    amount0_out NUMERIC NOT NULL,
    amount1_out NUMERIC NOT NULL,
    token_in VARCHAR(42) NOT NULL,
    token_out VARCHAR(42) NOT NULL,
    amount_in NUMERIC NOT NULL,
    amount_out NUMERIC NOT NULL,
    timestamp BIGINT NOT NULL,
    PRIMARY KEY (chain_id, tx_hash, log_index)
);

CREATE INDEX IF NOT EXISTS idx_swaps_pool ON swaps (chain_id, pool_address, block_number DESC);
CREATE INDEX IF NOT EXISTS idx_swaps_recipient ON swaps (chain_id, recipient, block_number DESC);
CREATE INDEX IF NOT EXISTS idx_swaps_sender ON swaps (chain_id, sender, block_number DESC);

-- 5. Mints (Liquidity Additions)
CREATE TABLE IF NOT EXISTS mints (
    chain_id BIGINT NOT NULL,
    block_number BIGINT NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    log_index INT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    sender VARCHAR(42) NOT NULL,
    amount0 NUMERIC NOT NULL,
    amount1 NUMERIC NOT NULL,
    timestamp BIGINT NOT NULL,
    PRIMARY KEY (chain_id, tx_hash, log_index)
);

CREATE INDEX IF NOT EXISTS idx_mints_pool ON mints (chain_id, pool_address, block_number DESC);
CREATE INDEX IF NOT EXISTS idx_mints_sender ON mints (chain_id, sender, block_number DESC);

-- 6. Burns (Liquidity Removals)
CREATE TABLE IF NOT EXISTS burns (
    chain_id BIGINT NOT NULL,
    block_number BIGINT NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    log_index INT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    sender VARCHAR(42) NOT NULL,
    recipient VARCHAR(42) NOT NULL,
    amount0 NUMERIC NOT NULL,
    amount1 NUMERIC NOT NULL,
    timestamp BIGINT NOT NULL,
    PRIMARY KEY (chain_id, tx_hash, log_index)
);

CREATE INDEX IF NOT EXISTS idx_burns_pool ON burns (chain_id, pool_address, block_number DESC);
CREATE INDEX IF NOT EXISTS idx_burns_recipient ON burns (chain_id, recipient, block_number DESC);

-- 7. Reserve Syncs
CREATE TABLE IF NOT EXISTS syncs (
    chain_id BIGINT NOT NULL,
    block_number BIGINT NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    log_index INT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    reserve0 NUMERIC NOT NULL,
    reserve1 NUMERIC NOT NULL,
    timestamp BIGINT NOT NULL,
    PRIMARY KEY (chain_id, tx_hash, log_index)
);

CREATE INDEX IF NOT EXISTS idx_syncs_pool ON syncs (chain_id, pool_address, block_number DESC);

-- 8. LP Transfers
CREATE TABLE IF NOT EXISTS lp_transfers (
    chain_id BIGINT NOT NULL,
    block_number BIGINT NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    log_index INT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    from_address VARCHAR(42) NOT NULL,
    to_address VARCHAR(42) NOT NULL,
    amount NUMERIC NOT NULL,
    timestamp BIGINT NOT NULL,
    PRIMARY KEY (chain_id, tx_hash, log_index)
);

CREATE INDEX IF NOT EXISTS idx_lp_transfers_from ON lp_transfers (chain_id, from_address);
CREATE INDEX IF NOT EXISTS idx_lp_transfers_to ON lp_transfers (chain_id, to_address);

-- 9. Reconstructed LP Positions
CREATE TABLE IF NOT EXISTS lp_positions (
    chain_id BIGINT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    user_address VARCHAR(42) NOT NULL,
    lp_balance NUMERIC NOT NULL DEFAULT 0,
    updated_at_block BIGINT NOT NULL,
    PRIMARY KEY (chain_id, pool_address, user_address)
);

CREATE INDEX IF NOT EXISTS idx_lp_positions_user ON lp_positions (chain_id, user_address);

-- 10. OHLCV Candlesticks (1m, 5m, 15m, 1h, 1d)
CREATE TABLE IF NOT EXISTS candles (
    chain_id BIGINT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    interval_type VARCHAR(8) NOT NULL,
    timestamp BIGINT NOT NULL,
    open NUMERIC NOT NULL,
    high NUMERIC NOT NULL,
    low NUMERIC NOT NULL,
    close NUMERIC NOT NULL,
    volume_token0 NUMERIC NOT NULL DEFAULT 0,
    volume_token1 NUMERIC NOT NULL DEFAULT 0,
    tx_count INT NOT NULL DEFAULT 0,
    PRIMARY KEY (chain_id, pool_address, interval_type, timestamp)
);

CREATE INDEX IF NOT EXISTS idx_candles_time ON candles (chain_id, pool_address, interval_type, timestamp DESC);

-- 11. Periodic Pool Snapshots
CREATE TABLE IF NOT EXISTS pool_snapshots (
    chain_id BIGINT NOT NULL,
    pool_address VARCHAR(42) NOT NULL,
    block_number BIGINT NOT NULL,
    timestamp BIGINT NOT NULL,
    reserve0 NUMERIC NOT NULL,
    reserve1 NUMERIC NOT NULL,
    price0 NUMERIC NOT NULL,
    price1 NUMERIC NOT NULL,
    PRIMARY KEY (chain_id, pool_address, block_number)
);
