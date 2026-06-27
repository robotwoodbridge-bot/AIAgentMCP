---
name: security-review
description: Review changes and test coverage for application security in this lab — authentication, authorization, tenant isolation, data exposure, session and webhook security against OWASP Top 10. Use when the user asks for a security review of code/tests, threat modeling, or security test strategy. For active exploitation/scanning, use pen-testing instead.
---

# Security Review Skill

Purpose:
Assess changes and test coverage for application-security risk — a defensive,
review-time complement to the offensive pen-testing skill.

Inputs:

- Change set / suites under review
- Auth flows, session handling, tenant boundaries
- config/settings.yaml, data/test_data.robot (secrets hygiene)

Review Areas (OWASP-aligned):

1. Authentication — bypass, weak credentials, MFA gaps
2. Authorization — privilege escalation, IDOR, cross-tenant access
3. Tenant isolation — data segregation
4. Sensitive data exposure — logs, errors, responses
5. Session management — expiration, fixation, replay
6. Webhook / integration security
7. Secrets hygiene — no hardcoded credentials

Output Format (per finding):

Severity: (Critical / High / Medium / Low)
Category: (OWASP / CWE)
Evidence:
Impact:
Recommended Test / Fix:

Quality Gates:

- No authn/authz bypass paths in changed flows
- No sensitive data leaked in logs/responses
- No hardcoded secrets
- Security-relevant changes have regression coverage
