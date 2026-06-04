#!/usr/bin/env bash
# =============================================================================
# run_security.sh — Run the security scan suite (ZAP / Nikto / Nmap)
# =============================================================================
# Usage:
#   ./utils/run_security.sh               → scan active_environment (staging)
#   ./utils/run_security.sh staging       → explicit environment target
#   ./utils/run_security.sh production    → scan production environment
#
# Prerequisites:
#   - Docker Desktop must be running
#   - Virtual env must be activated: source .venv/bin/activate
#
# Output:
#   results/security/   → raw JSON/XML reports from ZAP, Nikto, Nmap
#   results/report.html → Robot Framework execution log
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

ENVIRONMENT=${1:-"staging"}
OUTPUT_DIR="results"
SECURITY_DIR="${OUTPUT_DIR}/security"

echo "=============================================="
echo "  robotkali — Security Scan Runner"
echo "  Environment : ${ENVIRONMENT}"
echo "  Output      : ${SECURITY_DIR}"
echo "=============================================="

if ! docker info > /dev/null 2>&1; then
  echo "[ERROR] Docker is not running. Start Docker Desktop and retry."
  exit 1
fi

echo "Pulling scan tool images..."
docker pull ghcr.io/zaproxy/zaproxy:stable --quiet
docker pull frapsoft/nikto                  --quiet
docker pull instrumentisto/nmap             --quiet

mkdir -p "${SECURITY_DIR}"

python -m robot \
  --outputdir "${OUTPUT_DIR}" \
  --variable ENVIRONMENT:"${ENVIRONMENT}" \
  --loglevel INFO \
  --consolecolors on \
  --name "Security Scan — ${ENVIRONMENT}" \
  tests/security/

echo ""
echo "Scan complete."
echo "  RF report    : open ${OUTPUT_DIR}/report.html"
echo "  Raw findings : ls ${SECURITY_DIR}/"
