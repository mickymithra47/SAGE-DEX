# AUDIT_DEPENDENCIES.md
# SAGE PROTOCOL — PACKAGE & DEPENDENCY AUDIT
**Scope**: `lib/`, `frontend/package.json`, `indexer/package.json`  

---

## 1. Foundry & Solidity Dependencies (`lib/`)

| Package | Version / Commit | Purpose | Audit Assessment |
| :--- | :--- | :--- | :---: |
| **`forge-std`** | v1.9.5 | Foundry test framework & cheatcodes | **CLEAN / SECURE** |

- Zero unnecessary external third-party Solidity libraries.
- Standard libraries (`SafeTokenTransfer`, `Math`, `UQ112x112`, `SageMath`) are self-contained within `src/` to eliminate supply-chain injection vectors.

---

## 2. Frontend Dependencies (`frontend/package.json`)

```json
{
  "dependencies": {
    "@tanstack/react-query": "^5.59.0",
    "clsx": "^2.1.1",
    "lucide-react": "^0.453.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "viem": "^2.21.26",
    "wagmi": "^2.12.19"
  },
  "devDependencies": {
    "@types/react": "^18.3.11",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.2",
    "typescript": "^5.6.3",
    "vite": "^5.4.9",
    "vitest": "^2.1.3"
  }
}
```

- **Assessment**:
  - `viem` (v2.21.26) and `wagmi` (v2.12.19) are modern, secure, and type-safe.
  - Zero vulnerable or abandoned packages.
  - `vitest` provides fast ESM-native test execution.

---

## 3. Indexer Dependencies (`indexer/package.json`)

```json
{
  "name": "sage-indexer",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "start": "node --experimental-strip-types src/index.ts",
    "test": "node --experimental-strip-types test/runTests.js"
  },
  "devDependencies": {
    "@types/node": "^22.7.5",
    "typescript": "^5.6.3"
  }
}
```

- **Assessment**:
  - Extremely lightweight footprint with zero production runtime dependencies (utilizing Node.js 22 native type-stripping).
  - **Missing Dependency**: For Phase 13 production deployment, `pg` / `kysely` (PostgreSQL client) and `dotenv` should be installed to transition from the in-memory database to live PostgreSQL persistence.
