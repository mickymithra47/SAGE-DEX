# Phase 10 — LP Position Read Model

## 1. Mathematical Share Reconstruction
$$\text{Ownership Share} = \frac{\text{lpBalance}}{\text{totalLPSupply}}$$
$$\text{Underlying Token 0} = \left\lfloor \frac{\text{lpBalance} \cdot \text{reserve0}}{\text{totalLPSupply}} \right\rfloor$$
$$\text{Underlying Token 1} = \left\lfloor \frac{\text{lpBalance} \cdot \text{reserve1}}{\text{totalLPSupply}} \right\rfloor$$
