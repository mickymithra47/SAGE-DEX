# 09 — Native ETH vs ERC-20 & Canonical WETH Mechanics

## 1. Native ETH vs ERC-20 Differences

| Dimension | Native ETH | ERC-20 Tokens |
| :--- | :--- | :--- |
| **Protocol Layer** | Base protocol currency ($10^{-18}$ wei) | Application-layer smart contract state |
| **Transfer Mechanism** | Value transfer via `call{value: x}("")` | State mutation via `token.transfer(to, amount)` |
| **Delegated Allowance** | Not supported (no `approve` / `allowance`) | Fully supported via `approve` and `transferFrom` |
| **Receiver Requirement** | Must have `receive()` / `payable fallback` | Requires no special payable handlers to receive tokens |

---

## 2. Why DEX Protocols Use WETH (Wrapped Ether)
If a DEX attempted to trade native ETH directly in liquidity pools:
1. Every pool would require two distinct execution branches: one for ETH (`msg.value`, `.call{value}`) and one for ERC-20 (`transferFrom`).
2. Multi-hop swaps (`ETH` $\rightarrow$ `USDC` $\rightarrow$ `WBTC`) would become excessively complex and vulnerable to reentrancy.
3. **Solution**: Wrap native ETH into an ERC-20 interface (**WETH9**) to provide a 100% uniform interface across all trading pairs.

---

## 3. Canonical WETH Mechanics
```
Native ETH ──[ deposit() / receive() ]──> WETH (Minted 1:1)
WETH       ──[ withdraw(wad) ]─────────> Native ETH (Burned 1:1, ETH transferred)
```

- **Solvency Invariant**: $\text{address}(\text{weth}).\text{balance} \equiv \text{weth}.\text{totalSupply}()$.
- **Withdrawal Transfer**: Uses `(bool success, ) = msg.sender.call{value: wad}("")` to forward full gas, avoiding the 2300 gas limit trap of `transfer()`.
