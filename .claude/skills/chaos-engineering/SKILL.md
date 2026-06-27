---
name: chaos-engineering
description: Design controlled chaos / resilience experiments for this lab's Docker + Terraform stack — fault injection, dependency failure, and recovery validation with a defined steady-state hypothesis and blast radius. Use when the user asks about chaos experiments, resilience testing, or failure-injection scenarios.
---

# Chaos Engineering Skill

Purpose:
Run controlled resilience experiments that validate how the system behaves under
failure, with an explicit steady-state hypothesis and bounded blast radius.

Inputs:

- Target services (Playwright runner, Loki, Grafana, Selenium Grid; see docker/)
- Steady-state metrics (observability stack)
- Rollback / abort plan

Experiment Design:

1. Steady-state hypothesis — what "healthy" looks like (measurable)
2. Blast radius — scope and abort conditions
3. Fault to inject — latency, resource exhaustion, dependency kill, network partition
4. Expected vs observed behavior
5. Recovery validation

Fault Types:

- Service kill / restart
- Network latency / partition
- Resource exhaustion (CPU / memory / disk)
- Dependency unavailability (Loki, Grid node)

Output Format (per experiment):

Hypothesis:
Fault Injected:
Blast Radius:
Observed Behavior:
Steady-State Held: (yes/no)
Weakness Found:
Recommendation:

Quality Gates:

- Abort conditions defined before running
- Blast radius bounded (no prod, no shared infra)
- Steady-state measurable before and after
- Findings have a remediation owner
