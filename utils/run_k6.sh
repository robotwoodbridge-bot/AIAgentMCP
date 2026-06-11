#!/usr/bin/env bash
# =============================================================================
# run_k6.sh — Run the k6 login load test
# =============================================================================
# Usage:
#   ./utils/run_k6.sh                 → smoke profile (2 VUs, 30s sanity check)
#   ./utils/run_k6.sh load            → load profile (5 VUs sustained 2m)
#   ./utils/run_k6.sh stress          → stress profile (ramp to 15 VUs)
#
# Optional env overrides:
#   BASE_URL=https://staging.example.com ./utils/run_k6.sh load
#   LOGIN_USERNAME / LOGIN_PASSWORD to override credentials
#
# Prerequisites:
#   - k6 installed: brew install k6
#
# Results land in results/k6/ (git-ignored) as a JSON summary per run.
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PROFILE=${1:-smoke}
SCRIPT="tests/performance/k6/login_load_test.js"
OUTPUT_DIR="results/k6"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
SUMMARY="${OUTPUT_DIR}/login-${PROFILE}-${TIMESTAMP}.json"

mkdir -p "${OUTPUT_DIR}"

echo "=============================================="
echo "  QA Lab — k6 Load Test Runner"
echo "  Script   : ${SCRIPT}"
echo "  Profile  : ${PROFILE}"
echo "  Summary  : ${SUMMARY}"
echo "=============================================="

k6 run \
  -e PROFILE="${PROFILE}" \
  --summary-export "${SUMMARY}" \
  "${SCRIPT}"

echo ""
echo "Done. JSON summary saved to ${SUMMARY}"
