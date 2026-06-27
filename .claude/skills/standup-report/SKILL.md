---
name: standup-report
description: Produce a daily QA standup report for this lab — summarize recent test runs, failures, flaky suites, blockers, and risks from CI and results. Use when the user asks for a standup summary, daily status, what changed/broke, or a blockers-and-risks roundup.
---

# Standup Report Skill

Purpose:
Generate a concise daily QA status summary from recent test activity, CI runs,
and open risks — framed for a team standup.

Inputs:

- Recent CI runs (Azure Pipelines / GitHub Actions)
- Latest suite results and Allure/Robot reports
- Open blockers and risk items

Sections:

1. Yesterday — suites run, pass/fail counts, notable changes
2. Today — planned runs / coverage in progress
3. Blockers — what is stopping progress (env, flaky tests, dependencies)
4. Risks — emerging quality risks (link to risk-analysis where relevant)
5. Flaky watch — intermittent suites needing attention

Output Format:

Date:
Status: (green / amber / red)
Yesterday:
Today:
Blockers:
Risks:
Flaky Watch:

Quality Gates:

- Pass/fail numbers cite the actual run
- Every blocker has an owner / next step
- Red status always lists the cause
