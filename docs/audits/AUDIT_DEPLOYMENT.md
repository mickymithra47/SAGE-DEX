# AUDIT_DEPLOYMENT.md
# SAGE PROTOCOL — TESTNET DEPLOYMENT & VERIFICATION AUDIT
**Scope**: `deployments/testnet.json`, `script/DeployPhase12Testnet.s.sol`, `PHASE12_CONTRACT_ADDRESSES.md`  

---

## 1. Testnet Deployment Manifest Audit

`deployments/testnet.json` records the following configuration:
- **Network**: `sepolia`
- **Chain ID**: `11155111`
- **Compiler Version**: `0.8.26`

| Contract Name | Reported Address in `testnet.json` | Actual On-Chain Status / Nature of Address |
| :--- | :--- | :--- |
| **`WETH`** | `0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9` | **Canonical Sepolia WETH9** (Valid address) |
| **`SageFactory`** | `0x5FbDB2315678afecb367f032d93F642f64180aa3` | **Deterministic Anvil/Hardhat Local Address** (Nonce 0 of `0xf39Fd...`) |
| **`SageRouter`** | `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512` | **Deterministic Anvil/Hardhat Local Address** (Nonce 1 of `0xf39Fd...`) |
| **`Permit2`** | `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0` | **Deterministic Anvil/Hardhat Local Address** (Nonce 2 of `0xf39Fd...`) |
| **`SagePermitRouter`**| `0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9`| **Deterministic Anvil/Hardhat Local Address** (Nonce 3 of `0xf39Fd...`) |
| **`SageOracleEngine`**| `0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9`| **Deterministic Anvil/Hardhat Local Address** (Nonce 4 of `0xf39Fd...`) |
| **`TokenA_aUSD`** | `0x5FC8d32690cc91D4c39d9d3abcBD16989F875707` | **Deterministic Anvil/Hardhat Local Address** (Nonce 5 of `0xf39Fd...`) |
| **`TokenB_USDC`** | `0x0165878A594ca255338adfa4d48449f69242Eb8F` | **Deterministic Anvil/Hardhat Local Address** (Nonce 6 of `0xf39Fd...`) |
| **`TokenC_WBTC`** | `0xa513E6E4b8f2a923D98304ec87F64353C4D5C853` | **Deterministic Anvil/Hardhat Local Address** (Nonce 7 of `0xf39Fd...`) |
| **`Pair_aUSD_USDC`** | `0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6` | **Deterministic Anvil/Hardhat Local Address** (Nonce 8 of `0xf39Fd...`) |
| **`Pair_aUSD_WBTC`** | `0x8A791620dd6260079BF849Dc5567aDC3F2FdC318` | **Deterministic Anvil/Hardhat Local Address** (Nonce 9 of `0xf39Fd...`) |

---

## 2. Critical Audit Finding: False Sepolia Deployment Record

### [CRITICAL] Recorded Addresses Are Local Anvil Deterministic Addresses
- **Finding**: Every contract address (except WETH) in `deployments/testnet.json` matches the exact standard deterministic address computed when deploying contracts sequentially from the default Anvil / Hardhat test account `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` starting at nonce 0:
  - Nonce 0: `0x5FbDB2315678afecb367f032d93F642f64180aa3` (`SageFactory`)
  - Nonce 1: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512` (`SageRouter`)
  - Nonce 2: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0` (`Permit2`)
  - Nonce 3: `0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9` (`SagePermitRouter`)
  - Nonce 4: `0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9` (`SageOracleEngine`)
  - Nonce 5: `0x5FC8d32690cc91D4c39d9d3abcBD16989F875707` (`TokenA`)
  - Nonce 6: `0x0165878A594ca255338adfa4d48449f69242Eb8F` (`TokenB`)
  - Nonce 7: `0xa513E6E4b8f2a923D98304ec87F64353C4D5C853` (`TokenC`)
- **Conclusion**:
  - The contracts were **NOT** broadcasted or verified on the public Ethereum Sepolia network (`11155111`).
  - They were generated locally during local simulation testing with default development keys and labeled as a Sepolia deployment in documentation.

---

## 3. Mandatory Steps for Genuine Testnet Deployment

To genuinely deploy to Sepolia prior to Phase 13:
1. Fund a dedicated deployer EOA on Sepolia testnet.
2. Run Forge broadcast script against an active Sepolia RPC:
   ```bash
   forge script script/DeployPhase12Testnet.s.sol:DeployPhase12Testnet \
     --rpc-url $SEPOLIA_RPC_URL \
     --broadcast \
     --verify \
     --etherscan-api-key $ETHERSCAN_API_KEY
   ```
3. Update `deployments/testnet.json` with the actual on-chain contract addresses and block numbers.
4. Verify all contract bytecodes and constructors on Sepolia Etherscan.
