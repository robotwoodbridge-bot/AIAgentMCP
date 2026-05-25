#!/usr/bin/env bash
# =============================================================================
# start_stack.sh — Start the full Phase 2 Docker stack
# =============================================================================
# Usage:
#   ./utils/start_stack.sh          → starts grid + observability
#   ./utils/start_stack.sh stop     → stops and removes containers
#   ./utils/start_stack.sh status   → shows running services
# =============================================================================

set -euo pipefail

ACTION=${1:-"start"}
COMPOSE_FILE="docker/docker-compose.yml"

case "$ACTION" in
  start)
    echo "Starting QA Lab Docker stack..."
    docker compose -f "${COMPOSE_FILE}" up -d selenium-hub chromium firefox loki grafana
    echo ""
    echo "Stack is up:"
    echo "  Selenium Grid console : http://localhost:4444/ui"
    echo "  Chrome noVNC viewer   : http://localhost:7900"
    echo "  Firefox noVNC viewer  : http://localhost:7901"
    echo "  Grafana dashboard     : http://localhost:3000  (admin / admin)"
    echo "  Loki push endpoint    : http://localhost:3100/loki/api/v1/push"
    ;;
  stop)
    echo "Stopping QA Lab Docker stack..."
    docker compose -f "${COMPOSE_FILE}" down -v
    echo "Stack stopped and volumes removed."
    ;;
  status)
    docker compose -f "${COMPOSE_FILE}" ps
    ;;
  *)
    echo "Unknown action: $ACTION. Use start | stop | status"
    exit 1
    ;;
esac
