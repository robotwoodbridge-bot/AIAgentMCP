---
name: ai-testing
description: Design tests and evaluations for the Phase 3 AI/LLM features in this lab (Ollama integration) — prompt/response validation, hallucination and grounding checks, determinism, and safety. Use when the user asks about testing LLM features, eval harnesses, prompt regression, or model output quality.
---

# AI Testing Skill

Purpose:
Define test and evaluation strategy for the lab's AI/LLM features (Phase 3,
Ollama), where outputs are probabilistic rather than deterministic.

Inputs:

- LLM-backed features / prompts under test
- Reference / golden datasets
- Acceptance thresholds (eval metrics)

Review Areas:

1. Output correctness vs reference (exact, fuzzy, semantic)
2. Grounding / hallucination detection
3. Prompt-injection and safety boundaries
4. Determinism / variance across runs (temperature, seeds)
5. Latency and cost per call
6. Regression vs previous prompt/model version

Eval Techniques:

- Golden-dataset comparison
- LLM-as-judge (rubric-scored)
- Property / invariant checks
- Adversarial / red-team prompts

Output Format (per finding):

Capability Tested:
Eval Method:
Pass Threshold vs Observed:
Failure Mode: (hallucination / injection / variance / regression)
Recommendation:

Quality Gates:

- Eval thresholds defined and version-controlled
- Safety / injection cases covered
- Variance measured across repeated runs
- Regression gate vs last prompt/model baseline
