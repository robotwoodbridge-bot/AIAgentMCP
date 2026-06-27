---
name: performance-testing
description: Define and triage performance and load testing for this lab — browser performance budgets, k6 load profiles, and latency/throughput baselines. Use when the user asks about performance budgets, load tests, response-time regressions, or the performance/load CI pipelines.
---

# Performance Testing Skill

Purpose:
Establish performance budgets and load profiles, and triage results against
baselines for the browser and API workloads in this lab.

Inputs:

- Target flows (page loads, API calls)
- ci/azure-performance-pipeline.yml + ci/azure-load-pipeline.yml
  (.github/workflows/performance.yml + load.yml)
- LOGIN_USERNAME / LOGIN_PASSWORD secrets for authenticated load runs

Review Areas:

1. Browser performance budgets (load, TTI, layout shift)
2. API latency (p50 / p95 / p99)
3. Throughput and concurrency
4. Resource saturation (CPU, memory)
5. Soak / endurance behavior
6. Baseline + regression thresholds

Test Types:

- Smoke / baseline
- Load (expected concurrency)
- Stress (beyond expected)
- Soak (sustained)

Output Format (per finding):

Metric:
Baseline vs Observed:
Threshold Breached: (yes/no)
Impact:
Recommendation:

Quality Gates:

- Budgets defined and version-controlled
- p95 within threshold for critical flows
- No unexplained regression vs last baseline
