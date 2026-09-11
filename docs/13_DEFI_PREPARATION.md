# 13 — DeFi Preparation: Financial Invariants & Protocol Primitives

## 1. The Financial Invariant Mindset
In traditional web engineering, applications manage transient state and rely on database rollbacks. In DeFi protocol engineering, systems are governed by **Mathematical Invariants** that must hold true before and after every single transaction:

$$\text{Constant Product AMM Invariant: } k = x \cdot y$$
$$\text{Vault Solvency Invariant: } \sum \text{User Assets} \le \text{Contract Token Balance}$$
$$\text{Conservation of Liquidity: } L^2 = x \cdot y$$

---

## 2. Integer-Only Financial Mathematics & Precision
The EVM does not support floating-point arithmetic. All financial calculations must be conducted using fixed-point representation:

- **WAD (18 Decimals)**: 1.0 = $10^{18}$ ($1,000,000,000,000,000,000$ wei)
- **RAY (27 Decimals)**: 1.0 = $10^{27}$ (used in money market interest rate compounding)

### Fixed-Point Multiplication & Division:
$$\text{Wmul}(a, b) = \frac{a \times b}{10^{18}}$$
$$\text{Wdiv}(a, b) = \frac{a \times 10^{18}}{b}$$

---

## 3. Rounding Direction Rules for DEX Protocols

| Operation | Action | Rounding Direction | Rationale |
| :--- | :--- | :--- | :--- |
| **Swap In** | User specifies exact input token | Round **DOWN** on output | Protocol never gives out more tokens than math permits |
| **Swap Out** | User specifies exact output token | Round **UP** on input required | User must provide full payment to cover the swap |
| **LP Deposit** | User adds liquidity | Round **DOWN** on minted LP shares | Prevents free liquidity share extraction |
| **LP Burn** | User removes liquidity | Round **DOWN** on returned tokens | Protects remaining LPs from reserve dilution |
| **Protocol Fee**| Calculating swap fee | Round **UP** | Prevents fee zeroing on micro-trades |

---

## 4. Internal Accounting vs External Balance
A major vulnerability in AMMs is assuming that `IERC20.balanceOf(address(this))` is controlled strictly by protocol functions.
- Anyone can directly transfer (`transfer()`) tokens to an AMM contract.
- If the AMM relies on `balanceOf` for swap pricing, malicious actors can donate tokens to manipulate price calculations (Donation Attack / Share Inflation).
- **Core Principle**: Always maintain **internal reserve accounting variables** (`reserve0`, `reserve1`) and verify balance deltas explicitly during settlements.

---

## 5. Adversarial User Modeling
In EVM protocol design, every external caller must be treated as a malicious, economically rational adversary with:
1. Unlimited computational power for transaction simulations.
2. Complete mempool visibility (MEV searchers / sandwich bots).
3. Flashloan access to billions in capital to manipulate spot balances within a single transaction block.
4. Custom smart contracts designed to exploit callbacks and reentrancy opportunities.
