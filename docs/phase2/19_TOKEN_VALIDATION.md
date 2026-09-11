# 19 — Token Validation & Diagnostic Compatibility Engine

## 1. Automated Compatibility Classification Engine
The `TokenCompatibilityChecker` performs automated, on-chain diagnostic tests against candidate token contracts to classify their compatibility with the SAGE DEX.

---

## 2. The 5-Step Diagnostic Protocol

```
Step 1: Code Verification
 └── Checks token.code.length > 0 (Rejects EOAs / undeployed addresses)

Step 2: Metadata Query via Staticcall
 └── Queries name(), symbol(), decimals() (Catches non-reverting missing methods)

Step 3: Zero-Transfer Probe
 └── Executes low-level transfer(this, 0) to detect reverts on 0-value transfers

Step 4: Return Data Size Inspection
 ├── If returndata.length == 0 ──> Category B (USDT / No-Return)
 ├── If returndata.length >= 32 and decode == true ──> Category A (Standard)
 └── If returndata.length >= 32 and decode == false ──> Category F (False-Return)

Step 5: Balance Delta Transfer Test
 └── Transfers testAmount to probe for Fee-on-Transfer (Category C)
```

---

## 3. The Limits of Automated Detection
Automated diagnostic scripts can never prove that a token is 100% safe. Malicious tokens can:
1. Act normally for small test transfers, but revert on large volume.
2. Enable transfer fees or blacklisting after a specific timestamp or block number.
3. Contain hidden backdoor minting capabilities or proxy upgrade keys.
*Conclusion*: Classification engines provide automated compatibility checks, not safety certifications.
