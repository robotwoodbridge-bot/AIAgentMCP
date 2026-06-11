#!/usr/bin/env bash
# =============================================================================
# run_iac.sh — Run Playwright tests inside the Terraform IaC container
# =============================================================================
# Usage:
#   ./utils/run_iac.sh                  → all tests, headless
#   ./utils/run_iac.sh smoke            → smoke suite only
#   ./utils/run_iac.sh smoke --headed   → smoke suite, headed (VNC required)
#
# Prerequisites:
#   IaC stack must be up: cd infra/terraform && terraform apply
# =============================================================================

set -euo pipefail

# Always operate from the repo root regardless of where the script is called from
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SUITE=${1:-""}
HEADLESS="True"
CONTAINER="qa-playwright-runner"

# Check for --headed flag
for arg in "$@"; do
  if [ "$arg" = "--headed" ]; then
    HEADLESS="False"
  fi
done

# Verify the container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo ""
  echo "ERROR: '${CONTAINER}' is not running."
  echo "Start the IaC stack first:"
  echo "  cd infra/terraform && terraform apply"
  exit 1
fi

# Resolve the suite argument: a directory under tests/ wins; otherwise fall
# back to treating it as a Robot Framework tag (e.g. "contract" → --include contract)
TEST_PATH="tests/"
INCLUDE_ARGS=()
if [ -n "${SUITE}" ]; then
  if [ -d "tests/${SUITE}" ]; then
    TEST_PATH="tests/${SUITE}/"
  else
    INCLUDE_ARGS=(--include "${SUITE}")
  fi
fi

echo "============================================================"
echo "  QA Lab — Playwright IaC Runner"
echo "  Container : ${CONTAINER}"
echo "  Suite     : ${TEST_PATH}"
[ ${#INCLUDE_ARGS[@]} -gt 0 ] && echo "  Tag       : ${SUITE}"
echo "  Headless  : ${HEADLESS}"
echo "============================================================"

# Headed mode requires a virtual display (xvfb) — no physical screen inside Docker
if [ "${HEADLESS}" = "False" ]; then
  # xvfb provides a virtual display — headed browsers run without a physical screen.
  # 30s timeout accommodates the slower rendering of a virtual display vs headless.
  docker exec "${CONTAINER}" xvfb-run --auto-servernum \
    python -m robot \
    --outputdir results \
    --variable HEADLESS_MODE:False \
    --variable BROWSER_TIMEOUT:30s \
    --listener allure_robotframework:results/allure-results \
    ${INCLUDE_ARGS[@]+"${INCLUDE_ARGS[@]}"} \
    "${TEST_PATH}"
else
  docker exec "${CONTAINER}" python -m robot \
    --outputdir results \
    --variable HEADLESS_MODE:True \
    --listener allure_robotframework:results/allure-results \
    ${INCLUDE_ARGS[@]+"${INCLUDE_ARGS[@]}"} \
    "${TEST_PATH}"
fi

echo ""
echo "Run complete. Results written to results/ on your host."
echo "Open report: open results/report.html"
