# 20 — Token Accounting Models: Internal State vs Physical Balances

## 1. The Accounting Discrepancy Problem
In an EVM decentralized exchange, a liquidity pool has two distinct views of token ownership:

$$\text{View 1: Physical Token Balance } = \text{token}.\text{balanceOf}(\text{address}(\text{this}))$$
$$\text{View 2: Internal Accounting Reserves } = (\text{reserve0}, \text{reserve1})$$

These two numbers can diverge due to:
1. **Unsolicited Token Donations**: Attackers directly transferring tokens to the pool contract.
2. **Fee-on-Transfer Deductions**: Less tokens received than the requested transfer amount.
3. **Rebasing Actions**: Underlying token balance dynamically increasing or decreasing.

---

## 2. The Token Donation / Share Inflation Attack
If a vault or pool calculates LP share issuance directly using `balanceOf`:

$$\text{sharesMinted} = \frac{\text{assetsDeposited} \times \text{totalShares}}{\text{token}.\text{balanceOf}(\text{this})}$$

1. An attacker deposits 1 wei of assets and receives 1 wei of shares.
2. The attacker directly transfers (donates) $10,000$ tokens to the contract without calling `deposit()`.
3. `balanceOf` becomes $10,001$, but `totalShares` remains $1$.
4. The next depositor depositing $5,000$ tokens receives $\frac{5000 \times 1}{10001} = 0$ shares!
5. The attacker redeems their 1 share and steals the entire $15,001$ token balance.

---

## 3. Protocol Accounting Policies for SAGE DEX
1. **Track Internal Reserves Explicitly**: Core swap math relies strictly on internal storage variables (`reserve0`, `reserve1`), NEVER raw `balanceOf`.
2. **Reconcile via `sync()` and `skim()`**:
   - `sync()`: Updates internal reserves to match physical `balanceOf`, capturing donations for the protocol.
   - `skim()`: Forces excess physical balance beyond internal reserves to be swept to a fee collector.
3. **Virtual Shares Offset in Vaults**: Use a $10^3$ virtual offset in share pricing to mathematically eliminate the donation attack.
