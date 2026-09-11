# 07 — EIP-712 Domain Separation & Replay Immunity

## 1. Domain Separator Formulation
```solidity
bytes32 public constant EIP712_DOMAIN_TYPEHASH =
    keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

function DOMAIN_SEPARATOR() public view returns (bytes32) {
    return keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(name)), block.chainid, address(this)));
}
```

---

## 2. Dynamic ChainId Protection
- Calculating `block.chainid` dynamically inside `DOMAIN_SEPARATOR()` ensures instant protection against cross-chain replay in the event of an EVM hard fork.
