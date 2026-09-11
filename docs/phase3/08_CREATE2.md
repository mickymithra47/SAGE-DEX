# 08 — Deterministic Pair Deployment via CREATE2

## 1. Why Use CREATE2?
Using the EVM opcode `CREATE2` enables **deterministic, precomputable pair addresses**. Future routers, position managers, and off-chain routing engines can compute the exact contract address of any pair off-chain using pure math, without querying the factory contract storage.

---

## 2. Deterministic Address Formula
$$\text{Pair Address} = \text{keccak256}\left(\text{0xff} \parallel \text{factoryAddress} \parallel \text{salt} \parallel \text{keccak256}(\text{initCode})\right)[12:]$$

where:
- `0xff`: 1-byte constant defined in EIP-1014 to avoid collisions with `CREATE`.
- `factoryAddress`: 20-byte address of the `SageFactory`.
- `salt`: `keccak256(abi.encodePacked(token0, token1))`.
- `initCode`: `type(SagePair).creationCode`.

---

## 3. Implementation in Solidity Yul
```solidity
bytes memory bytecode = type(SagePair).creationCode;
bytes32 salt = keccak256(abi.encodePacked(token0, token1));

assembly {
    pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
}
```
