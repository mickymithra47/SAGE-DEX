# 03 — EVM Transaction Lifecycle & Execution Pipeline

## 1. What is the Transaction Lifecycle?
The transaction lifecycle describes the complete deterministic journey of a state transition request from off-chain cryptographic signature generation to on-chain finality and receipt generation.

```
┌──────────────┐     1. Signs Tx (ECDSA)     ┌──────────────────────┐
│  User Wallet │ ──────────────────────────> │ EIP-1559 Transaction │
└──────────────┘                             └──────────┬───────────┘
                                                        │ 2. eth_sendRawTransaction
                                                        ▼
┌──────────────┐     4. Block Inclusion      ┌──────────────────────┐
│  Mempool /   │ <────────────────────────── │    JSON-RPC Node     │
│ Block Builder│                             └──────────────────────┘
└──────┬───────┘
       │ 5. Execute in Block Context
       ▼
┌───────────────────────────────────────────────────────────────────┐
│                           EVM ENGINE                              │
│                                                                   │
│  [Validate Upfront Cost: (gasLimit * maxFeePerGas) + value]       │
│  [Increment Sender Nonce]                                         │
│  [Initialize Frame: PC = 0, Stack = [], Memory = 0x80]            │
│  [Execute Bytecode: SLOAD / SSTORE / CALL / STATICCALL / LOG]     │
│  [Compute Refunds: max(0, min(gasUsed * 0.2, gasRefund))]         │
└──────────────────────────────────┬────────────────────────────────┘
                                   │ 6. State Root Transition
                                   ▼
┌───────────────────────────────────────────────────────────────────┐
│                     TRANSACTION RECEIPT                           │
│                                                                   │
│  - Status: 0x1 (Success) / 0x0 (Revert)                           │
│  - Gas Used: e.g., 42,150                                         │
│  - Effective Gas Price: baseFee + priorityFee                     │
│  - Cumulative Gas Used in Block                                   │
│  - Logs / Events Array: [ Topic0, Topic1, Topic2, Data ]          │
│  - Logs Bloom Filter                                              │
└───────────────────────────────────────────────────────────────────┘
```

---

## 2. Why Does the EVM Need This Lifecycle?
Without an explicit, multi-stage lifecycle:
1. **Replay Attacks**: Without sequential nonces, transactions could be captured from the mempool and executed repeatedly, draining user funds.
2. **Network Denial of Service (DoS)**: Upfront gas validation guarantees that senders have sufficient funds to pay for node computation even if the transaction subsequently reverts.
3. **Receipt Determinism**: Off-chain indexers and user interfaces require cryptographic proof (logs bloom and status code) of execution results.

---

## 3. Internal Step-by-Step Breakdown

### Step 1: Transaction Construction & Signing
An EIP-1559 transaction payload includes:
- `chainId`: Prevents cross-chain replay (EIP-155).
- `nonce`: Strict monotonically increasing sequence integer per sender address.
- `maxPriorityFeePerGas`: Maximum tip paid directly to the validator.
- `maxFeePerGas`: Maximum total fee willing to be paid (must satisfy `maxFeePerGas >= baseFee + maxPriorityFeePerGas`).
- `gasLimit`: Maximum computational gas units allowed.
- `to`: 20-byte target contract address or `0x0` for contract creation.
- `value`: Ether amount in wei.
- `data`: ABI-encoded calldata (e.g. 4-byte selector + parameters).
- `v, r, s`: ECDSA signature over the secp256k1 elliptic curve.

### Step 2: RPC Validation & Mempool Admission
The node performs pre-flight verification:
1. Recovers signer address via `ecrecover(digest, v, r, s)`.
2. Checks that `nonce == state.getNonce(signer)`.
3. Verifies `balance >= (gasLimit * maxFeePerGas) + value`.
4. Checks `gasLimit >= 21,000` (intrinsic transaction gas).

### Step 3: Block Execution & EVM State Transition
1. **Intrinsic Gas Deduction**:
   - Base cost: 21,000 gas.
   - Calldata cost: 4 gas per zero byte, 16 gas per non-zero byte.
   - Contract creation cost: +32,000 gas if creating a contract.
2. **Context Instantiation**:
   - `msg.sender = signer`
   - `msg.value = value`
   - `address(this) = to`
   - `gasleft() = gasLimit - intrinsicGas`
3. **Opcode Execution Loop**:
   - Steps through bytecode instructions, mutating stack, memory, and storage slots.
   - Reverts trigger immediate unwinding of state changes in that frame while consuming gas used up to that instruction.

### Step 4: Final Settlement & Receipt
- Unspent gas is returned to `msg.sender`.
- `effectiveGasPrice = min(maxFeePerGas, baseFee + maxPriorityFeePerGas)`.
- Base fee is burned: `burnedETH = gasUsed * baseFee`.
- Tip is credited to miner/validator: `tipETH = gasUsed * (effectiveGasPrice - baseFee)`.
- Transaction receipt is recorded with status (`0x1` for success, `0x0` for failure).

---

## 4. Security & Gas Implications
- **Mempool Visibility & MEV**: Unconfirmed transactions in the public mempool are visible to searchers and block builders who can front-run or sandwich swaps.
- **Nonce Gaps**: If transaction with nonce $N$ is dropped or delayed, transactions with nonce $N+1$ remain blocked in the mempool.

---

## 5. Future AMM / DEX Relevance
Understanding intrinsic gas, calldata byte pricing, and gas refund caps is vital for optimizing DEX routers that handle high transaction throughput.
