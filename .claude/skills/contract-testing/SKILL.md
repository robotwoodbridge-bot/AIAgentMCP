---
name: contract-testing
description: Design and triage API contract tests for this lab — schema validation, consumer-driven contracts, and version/breaking-change checks against the REST/GraphQL endpoints. Use when the user asks about contract testing, schema drift, provider/consumer compatibility, or the api-contract CI pipeline.
---

# Contract Testing Skill

Purpose:
Ensure provider and consumer API contracts stay compatible across versions for
the services exercised by this lab's contract pipeline.

Inputs:

- API endpoints (REST / GraphQL) under test
- Published schemas / OpenAPI specs
- ci/azure-contract-pipeline.yml and .github/workflows/api-contract.yml

Review Areas:

1. Schema validation (request + response)
2. Consumer-driven contracts (expectations per consumer)
3. Backward / forward compatibility
4. Required vs optional fields, additive vs breaking changes
5. Status codes, headers, error envelopes
6. Versioning strategy

Output Format (per finding):

Contract Risk:
Affected Consumer(s):
Compatibility Impact: (additive / breaking)
Evidence:
Recommendation:

Quality Gates:

- No breaking contract changes without a version bump
- Every consumer expectation has a verifying test
- Schema validated on both request and response
