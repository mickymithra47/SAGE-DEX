# 47 — Database Migrations & Version Control

## 1. Sequential Migration Ledger
- `001_initial_schema.sql`: Core blocks, tokens, pools, and event tables.
- `002_add_candles_and_snapshots.sql`: Aggregated time-series tables.
- `003_add_lp_positions.sql`: Position and ownership indexes.
- All migrations are tracked in `schema_migrations` table.
