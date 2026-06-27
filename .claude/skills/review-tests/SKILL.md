---
name: review-tests
description: Author and review Robot Framework / Playwright tests in this lab — design scenarios (positive/negative/boundary/risk-based) AND review existing test code for quality, reliability, flakiness, and Page Object Model adherence. Use when the user asks to design test cases, expand coverage, review test code, or find brittle/flaky tests. Produces scenarios and prioritized findings with concrete fixes.
---

# Review Tests Skill

Purpose:
Cover the full test-quality lifecycle for this lab — design new test scenarios
and assess existing tests under `tests/`, `keywords/`, and `pages/` for quality,
reliability, and convention adherence.

Inputs:

- Feature / story / acceptance criteria (for authoring)
- Test suites under `tests/` (for review)
- Shared keywords (`keywords/common.robot`, `keywords/reporting.robot`)
- Page objects under `pages/`; test data in `data/test_data.robot`

## Part A — Authoring scenarios

Scenario Types:

1. Positive / happy path
2. Negative / error handling
3. Boundary / edge cases
4. Data-driven variations
5. Security-relevant cases (authz, input validation)
6. Cross-browser / responsive (where applicable)

Authoring Output (per scenario):

ID / Title
Type: (positive / negative / boundary / data-driven / security)
Priority: (P0 / P1 / P2)
Preconditions:
Steps:
Expected Result:
Suite / Tag: (target tests/ location + Robot tags)
Test Data: (reference to data/test_data.robot, no hardcoded secrets)

## Part B — Reviewing existing tests

Review Areas:

1. Correctness — assertions actually verify behavior, not just no-error
2. Reliability — no hardcoded waits; use explicit waits / web-first assertions
3. Page Object Model adherence — selectors live in `pages/`, not in tests
4. Data hygiene — credentials/URLs from config/settings.yaml + test_data.robot
5. Structure — setup/teardown via keywords, no duplication
6. Tagging — correct smoke/regression tags for suite selection
7. Reporting — Allure tags and structured logging via keywords/reporting.robot
8. Parallel-safety — no shared state that breaks pabot workers

Anti-Patterns to Flag:

- `Sleep` / fixed waits instead of conditional waits
- Selectors hardcoded in test files
- Hardcoded credentials, URLs, or environment values
- Assertion-free "happy path" tests
- Order-dependent or worker-shared state
- Copy-pasted steps that belong in a shared keyword

Review Output (per finding):

Severity: (Critical / High / Medium / Low)
Location: (file:line)
Issue:
Why It Matters:
Recommended Fix:

## Quality Gates

- Acceptance criteria fully covered; negative + boundary cases included
- No fixed sleeps in changed tests
- POM respected (selectors in pages/)
- No hardcoded secrets/URLs (use config/settings.yaml + test_data.robot)
- Each suite has correct tags
- Parallel-safe (no shared mutable state)
