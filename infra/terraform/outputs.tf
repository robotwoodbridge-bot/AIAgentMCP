output "selenium_grid_url" {
  description = "Selenium Grid 4 WebDriver endpoint — use as SELENIUM_REMOTE_URL in test runs (Grid 4 dropped the legacy /wd/hub path)"
  value       = "http://localhost:${var.grid_port}"
}

output "grid_console_url" {
  description = "Selenium Grid live console"
  value       = "http://localhost:${var.grid_port}/ui"
}

output "chromium_novnc_url" {
  description = "Watch Chromium test execution live"
  value       = "http://localhost:${var.chromium_novnc_port}"
}

output "firefox_novnc_url" {
  description = "Watch Firefox test execution live"
  value       = "http://localhost:${var.firefox_novnc_port}"
}

output "grafana_url" {
  description = "Grafana dashboard — login with admin / <grafana_admin_password>"
  value       = "http://localhost:${var.grafana_port}"
}

output "loki_ready_url" {
  description = "Loki readiness check — should return 'ready' (HTTP 200). Root path / returns 404 by design."
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
