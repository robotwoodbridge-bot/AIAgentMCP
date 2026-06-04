# Local overrides — safe to edit, but do NOT commit sensitive values.
# For the Grafana password, prefer the environment variable instead:
#   export TF_VAR_grafana_admin_password=mysecretpassword

loki_version           = "2.9.7"
grafana_version        = "10.4.2"
loki_port              = 3100
grafana_port           = 3000
loki_enabled           = true
