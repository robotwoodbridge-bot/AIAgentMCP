---
name: compliance-review
description: Review changes and test coverage for compliance, data-handling, and audit requirements in this lab — secrets hygiene, PII handling, traceability, and policy gates. Use when the user asks about compliance, audit readiness, data-protection requirements, or governance checks before release.
---

# Compliance Review Skill

Purpose:
Assess changes and test coverage against compliance, data-protection, and
auditability requirements before release.

Inputs:

- Change set / suites under review
- Data handled (credentials, PII, tokens)
- config/settings.yaml, data/test_data.robot, CI secret usage

Review Areas:

1. Secrets hygiene (no hardcoded credentials; secrets via CI variables)
2. PII / sensitive-data handling and retention
3. Traceability (requirement → test → result)
4. Access control and least privilege
5. Audit logging and evidence retention
6. Policy / regulatory gates applicable to the change

Output Format (per finding):

Requirement:
Status: (compliant / gap / unknown)
Evidence:
Risk if Unaddressed:
Recommendation:

Quality Gates:

- No secrets committed (config, results/, .vscode/, .claude.json excluded)
- Sensitive data masked in logs/reports
- Traceability intact for changed requirements
- Audit evidence retained per policy
