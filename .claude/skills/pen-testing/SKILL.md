---
name: pen-testing
description: Plan and triage AUTHORIZED penetration tests of the QA lab targets — recon, OWASP Top 10 web/API testing, scan triage (Nmap/Nikto/ZAP), and findings write-up. Use when the user asks for a pen-test plan, to triage a security scan, or to turn a vulnerability into a tests/pentest/ regression. Active testing requires confirmed scope and explicit approval.
---

# Pen-Testing Skill

Purpose:
Generate an authorized penetration-testing plan and triage findings for the QA
lab targets. Active testing requires confirmed scope and explicit approval.

Scope Guardrails:

- In-scope targets only (default: `staging` / `production` in config/settings.yaml)
- Passive recon before active scanning
- No destructive, DoS, mass-targeting, or evasion actions

Phases (PTES-aligned):

1. Pre-Engagement — confirm scope, authorization, rules of engagement
2. Reconnaissance — passive surface mapping
3. Scanning & Enumeration — services, endpoints, tech stack
4. Vulnerability Analysis — triage tool output, remove false positives
5. Exploitation — minimal proof only, with approval
6. Reporting — findings + remediation

Review Areas (OWASP Top 10):

1. Broken Access Control / IDOR
2. Cryptographic Failures / TLS
3. Injection (SQLi, command, template)
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable & Outdated Components
7. Identification & Authentication Failures
8. Software & Data Integrity Failures
9. Logging & Monitoring Failures
10. SSRF

Tooling (see ci/azure-security-pipeline.yml):

- Nmap — port / service discovery
- Nikto — web server scanning
- OWASP ZAP — web app scanning

Output Format (per finding):

Severity:
Evidence:
Reproduction:
Impact:
Remediation:
Regression Test: (proposed tests/pentest/ coverage, if applicable)

Quality Gates:

- Authorization confirmed before active testing
- Findings validated (no unverified false positives)
- Each Critical/High finding has remediation + regression path
