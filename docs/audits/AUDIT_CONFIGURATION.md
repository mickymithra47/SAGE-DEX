# AUDIT_CONFIGURATION.md
# SAGE PROTOCOL — CONFIGURATION & SECRETS AUDIT
**Scope**: `.env.example`, `foundry.toml`, `frontend/tsconfig.json`, `indexer/tsconfig.json`  

---

## 1. Secrets & Credentials Scan

A comprehensive security scan of all files in the repository was performed:
- **Private Keys / Mnemonics**: No leaked real private keys or mnemonics found. `.env.example` contains only standard zero-placeholder strings (`0x000...000`).
- **RPC Secrets**: No exposed Infura / Alchemy API private tokens.
- **Database Passwords**: No production database passwords exposed.

---

## 2. Hardcoded Addresses & Network Isolations

| Location | Hardcoded Value | Classification | Assessment |
| :--- | :--- | :---: | :--- |
| `frontend/src/App.tsx#L64` | `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` | **Acceptable Dev Fallback** | Used only when no injected browser wallet (MetaMask) is detected. |
| `frontend/src/config/tokens.ts` | Anvil token addresses for chain `31337` | **Acceptable Constant** | Isolated to local testnet chain ID mapping. |
| `foundry.toml` | EVM Version: `cancun`, Solc: `0.8.26`, Optimizer: `200` | **Production Standard** | Correctly configured for modern EVM Cancun features (transient storage, transient opcodes). |

---

## 3. Foundry Configuration (`foundry.toml`)
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.26"
evm_version = "cancun"
optimizer = true
optimizer_runs = 200
via_ir = false
ffi = false
fs_permissions = [{ access = "read", path = "./" }]

[invariant]
runs = 64
depth = 32
fail_on_revert = false
```

- **Safety**: `ffi = false` strictly prevents external arbitrary process execution during testing.
- **Invariants**: 64 runs $\times$ 32 depth provides adequate local invariant coverage.
