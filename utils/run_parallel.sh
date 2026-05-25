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

SUITE=${1:-""}          # optional subfolder under tests/
PROCESSES=${2:-4}       # number of parallel workers
OUTPUT_DIR="results"
ALLURE_DIR="${OUTPUT_DIR}/allure-results"

# Resolve the test path
if [[ -n "$SUITE" ]]; then
  TEST_PATH="tests/${SUITE}"
else
  TEST_PATH="tests"
fi

echo "=============================================="
echo "  QA Lab — Parallel Test Runner"
echo "  Suite    : ${TEST_PATH}"
echo "  Workers  : ${PROCESSES}"
echo "  Output   : ${OUTPUT_DIR}"
echo "=============================================="

# Clean previous results
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}" "${ALLURE_DIR}"

python -m pabot \
  --processes "${PROCESSES}" \
  --outputdir "${OUTPUT_DIR}" \
  --listener "allure_robotframework:${ALLURE_DIR}" \
  --loglevel INFO \
  "${TEST_PATH}"

echo ""
echo "Done. Open results/report.html to see the Robot Framework report."
echo "Run 'allure serve ${ALLURE_DIR}' to view the Allure report."
