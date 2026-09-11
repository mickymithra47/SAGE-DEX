# 34 — GraphQL Schema & Type Definitions

## 1. Schema Types
```graphql
type Token {
  address: ID!
  symbol: String!
  name: String!
  decimals: Int!
}

type Pool {
  address: ID!
  token0: Token!
  token1: Token!
  reserve0: String!
  reserve1: String!
  volume24hToken0: String!
  volume24hToken1: String!
}

type Swap {
  id: ID!
  pool: Pool!
  sender: String!
  recipient: String!
  tokenIn: String!
  tokenOut: String!
  amountIn: String!
  amountOut: String!
  timestamp: String!
}
```
