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
robotkali/
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
├── ci/                         # Azure Pipelines YAML (register under Pipelines → New Pipeline)
│   ├── azure-pipelines.yml             # IaC smoke suite (Terraform + Playwright)
│   ├── azure-contract-pipeline.yml     # API contract tests
│   ├── azure-performance-pipeline.yml  # Browser performance budgets (nightly)
│   ├── azure-load-pipeline.yml         # k6 load tests (manual + weekly)
│   ├── azure-security-pipeline.yml     # ZAP / Nikto / Nmap scans
│   └── templates/notify-on-failure.yml # Reusable failure-email step template
├── .github/
│   ├── workflows/              # GitHub Actions mirror of the ci/ pipelines
│   │   ├── qa-smoke-iac.yml            # ↔ azure-pipelines.yml
│   │   ├── api-contract.yml            # ↔ azure-contract-pipeline.yml
│   │   ├── performance.yml             # ↔ azure-performance-pipeline.yml
│   │   ├── load.yml                    # ↔ azure-load-pipeline.yml
│   │   └── security.yml                # ↔ azure-security-pipeline.yml
│   └── actions/notify-on-failure/      # Composite action ↔ notify-on-failure.yml template
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
- `staging`: https://practice.expandtesting.com
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

The same set of pipelines runs on **two** CI systems, kept in parity. Edit both
sides when changing a pipeline.

| Pipeline | Azure (`ci/`) | GitHub Actions (`.github/workflows/`) |
|---|---|---|
| IaC smoke suite | `azure-pipelines.yml` | `qa-smoke-iac.yml` |
| API contract tests | `azure-contract-pipeline.yml` | `api-contract.yml` |
| Performance budgets | `azure-performance-pipeline.yml` | `performance.yml` |
| k6 load tests | `azure-load-pipeline.yml` | `load.yml` |
| Security scans | `azure-security-pipeline.yml` | `security.yml` |
| Failure-email helper | `templates/notify-on-failure.yml` | `actions/notify-on-failure/` (composite) |

### Azure Pipelines

Register each YAML under **Pipelines → New Pipeline → Azure Repos Git → robotkali
→ Existing Azure Pipelines YAML file**. Configure pipeline secret variables:
`GMAIL_USER`, `GMAIL_APP_PASSWORD` (failure emails) and `LOGIN_USERNAME`,
`LOGIN_PASSWORD` (load test).

### GitHub Actions

Workflows live in `.github/workflows/` and appear under the repo **Actions** tab
once pushed. Every workflow has a `workflow_dispatch` trigger, so each can be run
on demand via **Actions → (workflow) → Run workflow**.

- **Triggers** mirror the Azure side: push/PR path filters, the nightly
  performance cron (`0 2 * * *`) and weekly load cron (`0 3 * * 0`).
- **Secrets** (Settings → Secrets and variables → Actions): `GMAIL_USER`,
  `GMAIL_APP_PASSWORD`, `LOGIN_USERNAME`, `LOGIN_PASSWORD` — same names as Azure.
- **Failure emails** are sent by the `notify-on-failure` composite action, which
  runs inline in the job so `log.html` is still on disk to attach.
- **Scheduled-run caveat:** GitHub `schedule` triggers only fire from the
  **default branch**. The Azure crons target `develop`; if `develop` is not the
  default branch, the nightly/weekly runs won't fire until these files exist on
  the default branch.
- **Artifacts** are published with `upload-artifact@v4` and downloadable from the
  run summary; the smoke and contract workflows add a `report` job that builds
  the Allure HTML report.

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
