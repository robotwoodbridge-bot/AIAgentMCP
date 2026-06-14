### terraform commands ###
cd infra/terraform/
terraform init (!only first time)
terraform play
    ## should see ##
    chromium_novnc_url = "http://localhost:7900"
    firefox_novnc_url = "http://localhost:7901"
    grafana_url = "http://localhost:3000"
    grid_console_url = "http://localhost:4444/ui"
    loki_url = "http://localhost:3100/metrices"
    selenium_grid_url = "http://localhost:4444"  
terraform destroy

# Stack must be up first
cd infra/terraform && terraform apply -auto-approve

**One test suite, three ways to run — same `.robot` files every time:**
| Local dev (fast iteration) | `python -m robot tests/`             | Your Mac         |
| Via script                 | `./utils/run_iac.sh smoke`           | Docker container |
| Via script                 | `./utils/run_iac.sh smoke --headed`  | Docker container |
| Via script                 | `./utils/run_parallels smoke 4`      | local browsers 4 parallels proc |
| Via script                 | `./utils/run_parallels MVP 2`        | local browsers 2 parallels proc |

./utils/run_k6.sh           # smoke — 2 VUs, 30s sanity check
./utils/run_k6.sh load      # load — ramp to 5 VUs, sustain 2m
./utils/run_k6.sh stress    # stress — ramp to 15 VUs, sustain 2m

**IaC Container Headless fastest**
docker exec qa-playwright-runner python -m robot \
  --outputdir results --variable HEADLESS_MODE:True tests/

**IaC Container Headed slow**
docker exec qa-playwright-runner xvfb-run --auto-servernum python -m robot \
  --outputdir results --variable HEADLESS_MODE:False --variable BROWSER_TIMEOUT:30s tests/


**Check if the test run inside Container**
  docker exec qa-playwright-runner cat results/log.html | grep -o "robot version.*" | head -1
**Check the Artifacts log.html for Hosname**

  