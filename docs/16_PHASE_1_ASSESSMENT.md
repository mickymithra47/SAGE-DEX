# 16 — Phase 1 Protocol Engineer Assessment & Interview Questions

## Section 1: Deep EVM Architecture (5 Questions)

### Q1: What are the four fields of an Ethereum account in the World State MPT? How do they differ between an EOA and a Contract Account?
**Answer**:
1. `nonce`: Number of transactions sent (EOA) vs number of contracts created via CREATE (Contract).
2. `balance`: Native ETH balance in wei ($10^{-18}$ ETH).
3. `storageRoot`: 256-bit MPT root hash. Empty (`keccak256("")`) for EOAs; points to contract persistent storage for Contracts.
4. `codeHash`: `keccak256` of runtime bytecode. `keccak256("")` for EOAs; hash of deployed bytecode for Contracts.

---

### Q2: Explain the exact execution context differences between `CALL`, `STATICCALL`, and `DELEGATECALL`.
**Answer**:
- `CALL`: Context switches to target. `msg.sender` = calling contract, `address(this)` = target, storage executed = target storage. ETH value can be transferred.
- `STATICCALL`: Context switches to target in read-only mode. `msg.sender` = calling contract, `address(this)` = target. State modification opcodes (`SSTORE`, `LOG`, `CREATE`, `SELFDESTRUCT`, `CALL` with value) immediately throw an EVM exception.
- `DELEGATECALL`: Executes target code in caller's environment. `msg.sender` = original caller, `address(this)` = caller, storage executed = caller's storage slots.

---

### Q3: How is a mapping value located in EVM storage? What is the formula for `mapping(address => uint256)` at Slot 2 for user `0xCAFE`?
**Answer**:
The formula is $\text{slot} = \text{keccak256}(\text{abi.encode}(\text{key}, \text{slotDeclaration}))$.
For user `0xCAFE` and slot 2:
$\text{slot} = \text{keccak256}(\text{bytes32}(\text{uint256}(\text{uint160}(\text{0xCAFE}))) \parallel \text{bytes32}(2))$.

---

### Q4: Why is memory expansion cost quadratic? What is the EVM Yellow Paper formula?
**Answer**:
Memory expansion is quadratic to economically penalize contracts that allocate massive memory buffers, preventing node memory exhaustion attacks.
The gas formula for $a$ words (where 1 word = 32 bytes) is:
$$C_{\text{mem}}(a) = 3a + \left\lfloor \frac{a^2}{512} \right\rfloor$$

---

### Q5: What is Transient Storage (EIP-1153) and why is it revolutionary for DEX singleton architectures?
**Answer**:
Transient storage (`TSTORE`/`TLOAD`) provides key-value storage that persists across all call frames within a single transaction but is completely cleared at transaction completion. It costs only 100 gas (vs 20,000 / 2,900 for persistent `SSTORE`). This enables **Flash Accounting** in DEX singletons (like Uniswap v4 / Sage PoolManager), where multi-hop swaps update transient balance deltas with near-zero gas, requiring token settlement only at the end of the transaction.

---

## Section 2: Smart Contract Security & DeFi Invariants (5 Questions)

### Q6: Explain why `transfer()` and `send()` are deprecated for transferring native ETH to contracts.
**Answer**:
`transfer()` and `send()` forward a hardcoded stipend of only 2,300 gas. In modern EVM forks (EIP-2929), storage reads and writes cost significantly more gas (`SLOAD` warm is 100 gas, cold is 2,100 gas; `SSTORE` is 2,900–20,000 gas). Any contract whose `receive()` function performs state updates, emits events, or interacts with storage will run out of gas and revert. The industry standard is `(bool success, ) = recipient.call{value: amount}("")` combined with Checks-Effects-Interactions and `ReentrancyGuard`.

---

### Q7: Why is `tx.origin` unsafe for authentication? Give an attack example.
**Answer**:
`tx.origin` represents the original EOA that signed the transaction, whereas `msg.sender` is the immediate caller. If a user interacts with a malicious contract (e.g. minting a free NFT), that malicious contract can call a victim's `tx.origin`-protected wallet. The wallet checks `tx.origin == owner` (which is true!) and transfers out the user's funds.

---

### Q8: What is the Checks-Effects-Interactions (CEI) pattern and why does it prevent reentrancy?
**Answer**:
1. **Checks**: Validate conditions (balances, zero addresses, permissions).
2. **Effects**: Update contract storage (deduct balances, advance state) *before* making any external calls.
3. **Interactions**: Perform external calls or token transfers last.
By modifying storage first, any re-entrant call initiated during the external interaction encounters the updated (zeroed/reduced) balance, neutralizing the exploit.

---

### Q9: Explain how a division-before-multiplication precision loss bug works in fee calculation.
**Answer**:
In integer arithmetic, division truncates towards zero. If `fee = (amount / 10000) * feeBps` and `amount = 500` wei, `500 / 10000` truncates to `0`, making `fee = 0 * feeBps = 0`. Multiplying first preserves precision: `(500 * feeBps) / 10000`.

---

### Q10: What is the difference between Example-Based Unit Testing and Invariant-Based Testing?
**Answer**:
- **Example-based unit testing** tests discrete, predetermined input values against expected return values (e.g., test depositing 100 tokens).
- **Invariant-based testing** defines universal mathematical truths that must NEVER be violated (e.g. `vault.totalAssets() <= token.balanceOf(vault)`), and uses a stateful testing engine to execute randomized sequences of actions to prove the invariant holds across all valid state transitions.
