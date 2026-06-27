---
name: observability-review
description: Review observability and telemetry for this lab's Grafana/Loki stack — log coverage, structured logging, dashboards, and alerting for test runs. Use when the user asks about logging gaps, Loki/Grafana setup, trace/log correlation, or whether failures are diagnosable from telemetry.
---

# Observability Review Skill

Purpose:
Assess whether test runs and the system under test emit enough signal to diagnose
failures, using the lab's Loki + Grafana observability stack.

Inputs:

- keywords/reporting.robot (structured logging helpers)
- docker/loki-config.yaml, Grafana dashboards
- config/settings.yaml `loki.enabled`

Review Areas:

1. Log coverage — key steps and failures are logged
2. Structured logging — consistent fields, levels, correlation IDs
3. Log shipping — Loki receives run logs when enabled
4. Dashboards — pass/fail trends, flaky suites, duration
5. Alerting — failures and regressions surface to the team
6. Trace ↔ log ↔ report correlation

Output Format (per finding):

Gap:
Impact on Diagnosability:
Evidence:
Recommendation:

Quality Gates:

- Failures are diagnosable from logs alone
- Structured logging used (no bare prints)
- Loki shipping verified when loki.enabled is true
- Dashboards cover pass/fail + duration trends
