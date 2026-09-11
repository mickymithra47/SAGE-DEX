# 02 — ERC-20 State Model & EVM Storage Layout

## 1. The Canonical State Model
The internal state of an ERC-20 contract is governed by three primary variables:

1. `uint256 public totalSupply;` — Total units of token in existence.
2. `mapping(address => uint256) public balanceOf;` — Individual ledger mapping account addresses to token units.
3. `mapping(address => mapping(address => uint256)) public allowance;` — Delegated permissions mapping owner $\rightarrow$ spender $\rightarrow$ authorized amount.

---

## 2. EVM Storage Slot Layout

```
Slot 0: [ 32 Bytes: string name (Short string layout or pointer)                      ]
Slot 1: [ 32 Bytes: string symbol (Short string layout or pointer)                    ]
Slot 2: [ 32 Bytes: uint8 decimals (1 byte) | address owner (20 bytes) | 11 bytes pad ]
Slot 3: [ 32 Bytes: uint256 totalSupply                                               ]
Slot 4: [ 32 Bytes: balanceOf Mapping Slot Pointer                                    ]
Slot 5: [ 32 Bytes: allowance Mapping Slot Pointer                                    ]
```

### Storage Addressing Calculations
- **Balance of user $U$** (Slot 4):
  $$\text{slot} = \text{keccak256}(\text{abi.encode}(U, 4))$$
- **Allowance from Owner $O$ to Spender $S$** (Slot 5):
  $$\text{slot} = \text{keccak256}(\text{abi.encode}(S, \text{keccak256}(\text{abi.encode}(O, 5))))$$

---

## 3. EVM Gas Characteristics of State Mutations
- **Cold Storage Read (`SLOAD`)**: 2,100 gas.
- **Warm Storage Read (`SLOAD`)**: 100 gas.
- **First-time Balance Allocation (`SSTORE` $0 \rightarrow \text{non-zero}$)**: 20,000 gas.
- **Subsequent Balance Mutation (`SSTORE` $\text{non-zero} \rightarrow \text{non-zero}$)**: 2,900 gas.
- **Zeroing a Balance (`SSTORE` $\text{non-zero} \rightarrow 0$)**: 2,900 gas with partial gas refund.
