#!/usr/bin/env bash
# =============================================================================
# run_parallel.sh — Run the full suite in parallel using pabot
# =============================================================================
# Usage:
#   ./utils/run_parallel.sh               → runs all tests, 4 workers
#   ./utils/run_parallel.sh smoke         → runs tests/smoke/ only
#   ./utils/run_parallel.sh smoke 2       → runs tests/smoke/ with 2 workers
#
# Prerequisites:
#   - virtual env must be activated: source .venv/bin/activate
#   - pabot installed: uv pip install robotframework-pabot
# =============================================================================

set -euo pipefail

# Always operate from the repo root regardless of where the script is called from
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SUITE=${1:-""}          # optional subfolder under tests/ (omit or use "smoke", not ".")
PROCESSES=${2:-4}       # number of parallel workers
OUTPUT_DIR="results"
ALLURE_DIR="${OUTPUT_DIR}/allure-results"

# Resolve the test path — treat "." or empty as "run everything"
if [[ -z "$SUITE" || "$SUITE" == "." ]]; then
  TEST_PATH="tests"
else
  TEST_PATH="tests/${SUITE}"
fi

echo "=============================================="
echo "  QA Lab — Parallel Test Runner"
echo "  Suite    : ${TEST_PATH}"
echo "  Workers  : ${PROCESSES}"
echo "  Output   : ${OUTPUT_DIR}"
echo "=============================================="

# Clean previous results and stale pabot suite cache
rm -rf "${OUTPUT_DIR}"
rm -f .pabotsuitenames
mkdir -p "${OUTPUT_DIR}" "${ALLURE_DIR}"

python -m pabot.pabot \
  --processes "${PROCESSES}" \
  --testlevelsplit \
  --outputdir "${OUTPUT_DIR}" \
  --listener "allure_robotframework:${ALLURE_DIR}" \
  --loglevel INFO \
  "${TEST_PATH}"

echo ""
echo "Done. Open results/report.html to see the Robot Framework report."
echo "Run 'allure serve ${ALLURE_DIR}' to view the Allure report."
