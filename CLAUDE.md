# QA Lab — Claude Code Guide

Robot Framework test automation platform with Playwright browser automation, parallel execution, Terraform-managed Docker IaC (Playwright runner + Grafana/Loki observability), and Allure reporting. Three-phase roadmap: Phase 1 (core RF + Playwright), Phase 2 (parallel + Docker + reporting), Phase 3 (AI/LLM integration via Ollama).

## Environment Setup

**Prerequisites:** Python 3.12+, Docker Desktop, Allure CLI (`brew install allure`)

```bash
python -m venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
playwright install --with-deps chromium firefox
python -m Browser.entry init
```

Activate the venv before every session: `source .venv/bin/activate`

## Running Tests

**Local (no Docker):**
```bash
./utils/run_parallel.sh               # all tests, 4 workers
./utils/run_parallel.sh smoke         # smoke suite only
./utils/run_parallel.sh smoke 2       # smoke suite, 2 workers
```

**Inside IaC container (Playwright + Grafana/Loki observability):**
```bash
cd infra/terraform && terraform apply  # start playwright-runner + loki + grafana
./utils/run_iac.sh smoke               # run smoke suite headless inside container
./utils/run_iac.sh smoke --headed      # run smoke suite headed via xvfb
cd infra/terraform && terraform destroy # tear down
```

**View reports:**
```bash
allure serve results/allure-results   # interactive Allure report
open results/report.html              # Robot Framework HTML report
```

## Project Structure

```
qa-lab/
├── config/settings.yaml        # Central config — environments, browser, timeouts, test data
├── tests/smoke/                # Smoke test suites
├── keywords/
│   ├── common.robot            # Suite setup/teardown, browser lifecycle
│   └── reporting.robot         # Allure tagging + structured logging helpers
├── pages/                      # Page Object Model — selectors and interactions per page
├── data/test_data.robot        # Test data variables (credentials, endpoints, messages)
├── docker/                     # Docker Compose stack + Dockerfile for CI runner
│   ├── docker-compose.yml      # Selenium Grid, Loki, Grafana, test-runner services
│   ├── Dockerfile.runner       # Container image for CI-style execution
│   └── loki-config.yaml        # Loki log aggregation config
├── ci/qa-pipeline.yml          # GitHub Actions workflow — copy to .github/workflows/
├── utils/
│   ├── run_parallel.sh         # Pabot parallel runner wrapper (local, no Docker)
│   └── run_iac.sh              # Playwright runner inside Terraform IaC container
└── results/                    # Git-ignored output (reports, traces, allure results)
```

## Key Configuration

**config/settings.yaml** controls everything:
- `active_environment`: switch between `staging` and `production`; override with `--variable ENVIRONMENT:production`
- `browser.type`: chromium / firefox / webkit
- `browser.headless`: set false for headed local debugging
- `selenium_grid.enabled`: flip to true when running against the Docker stack
- `parallel.workers`: pabot worker count (default 4)
- `loki.enabled`: flip to true when the Docker observability stack is running

**Environments defined in settings.yaml:**
- `staging`: https://rahulshettyacademy.com
- `production`: separate URLs configured in the yaml

## Docker Stack

ARM64-native images (seleniarm) for Apple Silicon.

| Service | URL | Notes |
|---|---|---|
| Selenium Hub | http://localhost:4444 | Grid entry point |
| Chrome node (noVNC) | http://localhost:7900 | Watch live execution |
| Firefox node (noVNC) | http://localhost:7901 | Watch live execution |
| Grafana | http://localhost:3000 | admin/admin |
| Loki | http://localhost:3100 | Log backend |

Scale browsers: `cd docker && docker compose up -d --scale chromium=3`

The `test-runner` service only starts with `--profile run`.

## CI/CD

GitHub Actions pipeline at `ci/qa-pipeline.yml` — copy to `.github/workflows/qa-pipeline.yml` to activate.

- Triggers on push/PR to `main` or `develop`, plus manual dispatch
- Runs `pabot` with 4 workers in headless mode
- Publishes Allure HTML report to GitHub Pages (main branch only)
- Uploads browser traces as artifacts on failure

## Stack

| Layer | Library | Version |
|---|---|---|
| Test runner | Robot Framework | 7.0 |
| Browser (primary) | robotframework-browser (Playwright) | 18.3.0 |
| Browser (Grid) | robotframework-seleniumlibrary | 6.3.0 |
| Parallel | robotframework-pabot | 2.18.0 |
| Reporting | allure-robotframework | 2.13.5 |
| Log shipping | python-logging-loki | 0.3.1 |
| AI (Phase 3) | ollama | 0.5.1 |

## What Claude Should Know

- `results/` is git-ignored — never reference or commit its contents
- `.vscode/` is git-ignored — MCP server config lives there, contains credentials
- `.claude.json` is git-ignored — contains MCP server config with credentials
- Page objects live in `pages/`, shared keywords in `keywords/`
- All test data (credentials, URLs) is centralised in `config/settings.yaml` and `data/test_data.robot` — do not hardcode values in test files
- The `.venv` Python environment must be active for all `robot`, `pabot`, and `playwright` commands
