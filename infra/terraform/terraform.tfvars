# Local overrides — safe to edit, but do NOT commit sensitive values.
# For the Grafana password, prefer the environment variable instead:
#   export TF_VAR_grafana_admin_password=mysecretpassword

selenium_version       = "4.20.0"
loki_version           = "2.9.7"
grafana_version        = "10.4.2"
node_max_sessions      = 4
session_timeout        = 300
grid_port              = 4444
chromium_novnc_port    = 7900
firefox_novnc_port     = 7901
loki_port              = 3100
grafana_port           = 3000
