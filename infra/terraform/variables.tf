variable "loki_version" {
  description = "Grafana Loki image tag"
  type        = string
  default     = "2.9.7"
}

variable "grafana_version" {
  description = "Grafana image tag"
  type        = string
  default     = "10.4.2"
}

variable "loki_port" {
  description = "Host port for the Loki log aggregation API"
  type        = number
  default     = 3100
}

variable "grafana_port" {
  description = "Host port for the Grafana dashboard UI"
  type        = number
  default     = 3000
}

variable "grafana_admin_password" {
  description = "Grafana admin password — override via TF_VAR_grafana_admin_password env var"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "loki_enabled" {
  description = "Enable Loki log shipping from the test runner"
  type        = bool
  default     = true
}
