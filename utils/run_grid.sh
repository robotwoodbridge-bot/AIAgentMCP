#!/usr/bin/env bash
# =============================================================================
# run_grid.sh — Run Selenium-based tests against the Docker Grid
# =============================================================================
# Usage:
#   ./utils/run_grid.sh               → runs tests/regression/ against grid
#   ./utils/run_grid.sh smoke         → runs tests/smoke/ against grid
#
# Prerequisites:
#   1. Docker grid must be up:
#        cd docker && docker compose up -d selenium-hub chrome firefox
#   2. Virtual env activated: source .venv/bin/activate
# =============================================================================

set -euo pipefail

SUITE=${1:-"regression"}
HUB_URL="http://localhost:4444/wd/hub"
OUTPUT_DIR="results/grid"
ALLURE_DIR="${OUTPUT_DIR}/allure-results"

echo "=============================================="
echo "  QA Lab — Selenium Grid Runner"
echo "  Suite    : tests/${SUITE}"
echo "  Grid URL : ${HUB_URL}"
echo "=============================================="

# Verify the grid is reachable before running
if ! curl -sf "${HUB_URL}/status" > /dev/null; then
  echo ""
  echo "ERROR: Selenium Grid is not reachable at ${HUB_URL}"
  echo "Start it with: cd docker && docker compose up -d selenium-hub chrome firefox"
  exit 1
fi

mkdir -p "${OUTPUT_DIR}" "${ALLURE_DIR}"

python -m pabot \
  --processes 4 \
  --outputdir "${OUTPUT_DIR}" \
  --variable SELENIUM_REMOTE_URL:"${HUB_URL}" \
  --listener "allure_robotframework:${ALLURE_DIR}" \
  "tests/${SUITE}"

echo ""
echo "Grid run complete. Results in ${OUTPUT_DIR}/"
