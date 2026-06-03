variable "selenium_version" {
  description = "seleniarm image tag for hub and browser nodes"
  type        = string
  default     = "4.20.0"
}

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

variable "grid_port" {
  description = "Host port for the Selenium Grid console and WebDriver endpoint"
  type        = number
  default     = 4444
}

variable "chromium_novnc_port" {
  description = "Host port for the Chromium node noVNC viewer"
  type        = number
  default     = 7900
}

variable "firefox_novnc_port" {
  description = "Host port for the Firefox node noVNC viewer"
  type        = number
  default     = 7901
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

variable "node_max_sessions" {
  description = "Maximum concurrent sessions per browser node"
  type        = number
  default     = 4
}

variable "session_timeout" {
  description = "Selenium session timeout in seconds"
  type        = number
  default     = 300
}
