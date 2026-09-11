# 59 — API Security & Rate Limiting Guardrails

## 1. Defensive API Controls
- **Rate Limiting**: 100 requests per minute per IP.
- **Max Page Size**: Enforced 100 records limit per query.
- **Query Complexity Cap**: Maximum 3 nested resolver levels in GraphQL.
- **Request Timeout**: 5,000ms global timeout on read queries.
