# Phase 2 — Enterprise Infrastructure Layer
## Step-by-Step Setup Guide

> **Prerequisites:** Phase 1 complete — your `.venv` exists, `playwright install` has been run, and the smoke login test passes locally.

---

## What You're Building

Phase 2 adds four capabilities on top of your working Phase 1 framework:

1. **Parallel test execution** — run multiple tests simultaneously using `pabot`
2. **Docker + Selenium Grid 4** — containerised browsers you can watch in real time
3. **Allure Reports** — beautiful, interactive HTML test reports with history
4. **Grafana + Loki** — a live log dashboard so you can see test output as it streams in

---

## Step 1 — Install New Dependencies

Activate your virtual environment, then install everything added to `requirements.txt`:

```bash
cd ~/qa-lab
source .venv/bin/activate

uv pip install -r requirements.txt
```

Key new packages installed:
- `robotframework-pabot` — parallel Robot Framework runner
- `robotframework-seleniumlibrary` + `selenium` — for Selenium Grid-targeted tests
- `allure-robotframework` — generates Allure JSON alongside normal RF output
- `python-logging-loki` — ships test logs to Loki

---

## Step 2 — Run Tests in Parallel (Local, No Docker)

You can run your tests in parallel right now without Docker. `pabot` splits test suites across multiple workers:

```bash
# Run all tests with 4 parallel workers
./utils/run_parallel.sh

# Run only the smoke suite with 2 workers
./utils/run_parallel.sh smoke 2
```

After the run, open these in your browser:
- `results/report.html` — Robot Framework's built-in summary
- Run `allure serve results/allure-results` to view the Allure report (install Allure CLI first — see Step 5)

---

## Step 3 — Install Docker Desktop

If you don't have Docker yet:

- **macOS:** Download from https://www.docker.com/products/docker-desktop — install and launch it
- **Windows 11:** Same URL — enable WSL 2 integration during setup
- **Ubuntu:** `sudo apt install docker.io docker-compose-plugin`

Verify Docker is working:

```bash
docker --version        # should say Docker version 25+
docker compose version  # should say Docker Compose version 2+
```

---

## Step 4 — Start the Docker Stack (Grid + Observability)

All Docker config lives in `docker/`. A single helper script handles everything:

```bash
# Start the Selenium Grid, Grafana, and Loki
./utils/start_stack.sh

# Check that everything is running
./utils/start_stack.sh status
```

Once it's up, open these URLs:

| Service | URL | Notes |
|---|---|---|
| Selenium Grid console | http://localhost:4444/ui | See registered browsers |
| Chrome live viewer | http://localhost:7900 | Watch Chrome run tests in real time (no password) |
| Firefox live viewer | http://localhost:7901 | Watch Firefox |
| Grafana dashboards | http://localhost:3000 | Login: admin / admin |
| Loki push endpoint | http://localhost:3100 | Used internally by the runner |

> **Tip:** Open http://localhost:7900 in your browser *before* running tests, then start a test run — you can watch the browser being driven live.

---

## Step 5 — Install Allure CLI (for local report viewing)

```bash
# macOS
brew install allure

# Windows (via Scoop)
scoop install allure

# Ubuntu / Linux
sudo apt install default-jre   # Allure needs Java
wget https://github.com/allure-framework/allure2/releases/download/2.27.0/allure-2.27.0.tgz
tar -xzf allure-2.27.0.tgz
sudo mv allure-2.27.0 /opt/allure
sudo ln -s /opt/allure/bin/allure /usr/local/bin/allure
```

Generate and open a report after any test run:

```bash
allure serve results/allure-results
```

This opens an interactive report in your browser with test timeline, categories, and history.

---

## Step 6 — Run Tests Against Selenium Grid

Once the Docker stack is running (`./utils/start_stack.sh`):

```bash
# Run the smoke suite against the containerised Grid
./utils/run_grid.sh smoke
```

The script auto-checks that the Grid is reachable before running. Watch the tests execute live at http://localhost:7900.

To scale up and run on multiple Chrome instances simultaneously:

```bash
# From the docker/ directory
docker compose up -d --scale chrome=3
```

---

## Step 7 — View Logs in Grafana

1. Open http://localhost:3000 and log in with `admin` / `admin`
2. Go to **Dashboards → QA Lab → QA Test Runs**
3. The pre-provisioned dashboard shows:
   - All test log lines (searchable)
   - Only FAIL lines filtered out
   - Log volume over time

To enable log shipping from your test runner to Loki, open `config/settings.yaml` and set:

```yaml
loki:
  enabled: true
```

Then add this snippet to `utils/loki_handler.py` (see below) and import it in your test runner script.

---

## Step 8 — Set Up GitHub Actions CI/CD

The pipeline file is at `ci/qa-pipeline.yml`. GitHub Actions requires it to live in a specific location:

```bash
# From your qa-lab directory
mkdir -p .github/workflows
cp ci/qa-pipeline.yml .github/workflows/qa-pipeline.yml
```

Then push to GitHub:

```bash
git add .
git commit -m "Phase 2: Add CI/CD pipeline, Docker stack, parallel execution"
git push origin main
```

Go to your repo on GitHub → **Actions** tab. You'll see the `QA Pipeline` workflow run automatically.

The pipeline:
1. Installs Python 3.12 and all dependencies
2. Installs Playwright browsers (headless mode for CI)
3. Runs your tests in parallel with `pabot`
4. Uploads Allure results and RF logs as downloadable artifacts
5. On `main` branch — publishes an Allure HTML report to GitHub Pages

To enable GitHub Pages: **Settings → Pages → Source → GitHub Actions**. After the first successful run, your report will be live at `https://<your-username>.github.io/<repo-name>/`.

---

## Quick Reference — Common Commands

```bash
# --- Local ---
source .venv/bin/activate              # activate virtual env

./utils/run_parallel.sh                # run all tests in parallel (4 workers)
./utils/run_parallel.sh smoke 2        # run smoke suite with 2 workers

allure serve results/allure-results    # open Allure report in browser

# --- Docker stack ---
./utils/start_stack.sh                 # start Grid + Grafana + Loki
./utils/start_stack.sh status          # check what's running
./utils/start_stack.sh stop            # shut everything down

./utils/run_grid.sh smoke              # run tests against the Docker Grid

# --- Scale up browsers ---
cd docker && docker compose up -d --scale chrome=3

# --- View live browser ---
open http://localhost:7900             # Chrome noVNC viewer
open http://localhost:7901             # Firefox noVNC viewer

# --- Grafana ---
open http://localhost:3000             # admin / admin
```

---

## What's Next: Phase 3

Phase 3 adds AI to your lab:
- Install Ollama + local LLM models (Qwen, DeepSeek)
- Auto-generate test cases from natural language descriptions
- Self-healing selector repair when tests break after UI changes
- AI-powered failure analysis from your Loki logs
