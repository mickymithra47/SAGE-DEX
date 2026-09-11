# 05 — Delegated Token Transfers: TransferFrom Mechanics

## 1. Delegated Transfer Semantics
The `transferFrom(address from, address to, uint256 amount)` function allows a third-party spender (`msg.sender`) to pull tokens from an owner account (`from`) to a recipient (`to`), subject to an active allowance.

```
+------------------+-----------------------+------------------------+
| msg.sender       | from                  | to                     |
+------------------+-----------------------+------------------------+
| DEX Router       | User / Trader         | Liquidity Pool         |
| Liquidity Pool   | User / LP             | Vault Reserve          |
+------------------+-----------------------+------------------------+
```

---

## 2. Execution Protocol & Allowance Decoupling
1. If `from != msg.sender`, the contract loads `allowance[from][msg.sender]`.
2. If `allowance < amount`, execution reverts with `InsufficientAllowance`.
3. If `allowance != type(uint256).max`, the allowance is decremented:
   $$\text{allowance}[from][\text{msg.sender}] \leftarrow \text{allowance}[from][\text{msg.sender}] - \text{amount}$$
4. `balanceOf[from]` is decremented by `amount`.
5. `balanceOf[to]` is incremented by `amount`.
6. Emits `Transfer(from, to, amount)`.

---

## 3. Router Architecture Relevance
In future DEX phases, routers never hold user funds. Instead, users approve the Router once, and during a multi-hop swap (`TokenA` $\rightarrow$ `TokenB` $\rightarrow$ `TokenC`), the Router calls `transferFrom(user, poolA, amountIn)`, while intermediate pools transfer proceeds directly along the swap path.
