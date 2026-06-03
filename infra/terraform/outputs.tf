output "run_headless" {
  description = "Run all tests headless inside the IaC container (no display needed — CI-safe)"
  value       = "docker exec qa-playwright-runner python -m robot --outputdir results --variable HEADLESS_MODE:True tests/"
}

output "run_headless_smoke" {
  description = "Run smoke suite headless inside the IaC container"
  value       = "docker exec qa-playwright-runner python -m robot --outputdir results --variable HEADLESS_MODE:True tests/smoke/"
}

output "run_headed" {
  description = "Run all tests headed inside the IaC container via xvfb virtual display"
  value       = "docker exec qa-playwright-runner xvfb-run --auto-servernum python -m robot --outputdir results --variable HEADLESS_MODE:False --variable BROWSER_TIMEOUT:30s tests/"
}

output "run_headed_smoke" {
  description = "Run smoke suite headed inside the IaC container via xvfb virtual display"
  value       = "docker exec qa-playwright-runner xvfb-run --auto-servernum python -m robot --outputdir results --variable HEADLESS_MODE:False --variable BROWSER_TIMEOUT:30s tests/smoke/"
}

output "runner_shell_cmd" {
  description = "Open an interactive shell inside the runner container"
  value       = "docker exec -it qa-playwright-runner bash"
}

output "grafana_url" {
  description = "Grafana dashboard — login with admin / <grafana_admin_password>"
  value       = "http://localhost:${var.grafana_port}"
}

output "loki_ready_url" {
  description = "Loki readiness check — HTTP 200 = healthy. Root / returns 404 by design."
  value       = "http://localhost:${var.loki_port}/ready"
}

output "loki_push_url" {
  description = "Loki log push endpoint — used by the test runner to ship logs"
  value       = "http://localhost:${var.loki_port}/loki/api/v1/push"
}

output "loki_query_url" {
  description = "Loki query API — used by Grafana as its datasource"
  value       = "http://localhost:${var.loki_port}/loki/api/v1/query_range"
}
