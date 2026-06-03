terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # Local state — no remote backend needed for local-only usage.
  # To promote to cloud later, replace this block with an s3/gcs backend.
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {
  # Connects to the local Docker daemon.
  # Override with DOCKER_HOST env var if using a remote socket.
}

# =============================================================================
# Network
# =============================================================================

resource "docker_network" "qa_net" {
  name   = "qa-net"
  driver = "bridge"
}

# =============================================================================
# Volumes
# =============================================================================

resource "docker_volume" "grafana_storage" {
  name = "grafana-storage"
}

resource "docker_volume" "loki_storage" {
  name = "loki-storage"
}

# =============================================================================
# Images — pulled once, reused by container resources
# =============================================================================

resource "docker_image" "selenium_hub" {
  name         = "seleniarm/hub:${var.selenium_version}"
  keep_locally = true
}

resource "docker_image" "selenium_chromium" {
  name         = "seleniarm/node-chromium:${var.selenium_version}"
  keep_locally = true
}

resource "docker_image" "selenium_firefox" {
  name         = "seleniarm/node-firefox:${var.selenium_version}"
  keep_locally = true
}

resource "docker_image" "loki" {
  name         = "grafana/loki:${var.loki_version}"
  keep_locally = true
}

resource "docker_image" "grafana" {
  name         = "grafana/grafana:${var.grafana_version}"
  keep_locally = true
}

# =============================================================================
# Selenium Hub
# =============================================================================

resource "docker_container" "selenium_hub" {
  name  = "selenium-hub"
  image = docker_image.selenium_hub.image_id

  networks_advanced {
    name = docker_network.qa_net.name
  }

  ports {
    internal = 4444
    external = var.grid_port
  }
  ports {
    internal = 4442
    external = 4442
  }
  ports {
    internal = 4443
    external = 4443
  }

  env = [
    "SE_SESSION_REQUEST_TIMEOUT=${var.session_timeout}",
    "SE_SESSION_RETRY_INTERVAL=5",
  ]

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:4444/status"]
    interval     = "15s"
    timeout      = "10s"
    retries      = 5
    start_period = "10s"
  }

  restart = "unless-stopped"
}

# =============================================================================
# Chromium Node
# =============================================================================

resource "docker_container" "chromium" {
  name  = "selenium-chromium"
  image = docker_image.selenium_chromium.image_id

  networks_advanced {
    name = docker_network.qa_net.name
  }

  ports {
    internal = 7900
    external = var.chromium_novnc_port
  }

  env = [
    "SE_EVENT_BUS_HOST=selenium-hub",
    "SE_EVENT_BUS_PUBLISH_PORT=4442",
    "SE_EVENT_BUS_SUBSCRIBE_PORT=4443",
    "SE_NODE_MAX_SESSIONS=${var.node_max_sessions}",
    "SE_NODE_SESSION_TIMEOUT=${var.session_timeout}",
    "SE_VNC_NO_PASSWORD=1",
  ]

  shm_size = 2147483648 # 2 GB in bytes

  depends_on = [docker_container.selenium_hub]

  restart = "unless-stopped"
}

# =============================================================================
# Firefox Node
# =============================================================================

resource "docker_container" "firefox" {
  name  = "selenium-firefox"
  image = docker_image.selenium_firefox.image_id

  networks_advanced {
    name = docker_network.qa_net.name
  }

  ports {
    internal = 7900
    external = var.firefox_novnc_port
  }

  env = [
    "SE_EVENT_BUS_HOST=selenium-hub",
    "SE_EVENT_BUS_PUBLISH_PORT=4442",
    "SE_EVENT_BUS_SUBSCRIBE_PORT=4443",
    "SE_NODE_MAX_SESSIONS=${var.node_max_sessions}",
    "SE_NODE_SESSION_TIMEOUT=${var.session_timeout}",
  ]

  shm_size = 2147483648 # 2 GB in bytes

  depends_on = [docker_container.selenium_hub]

  restart = "unless-stopped"
}

# =============================================================================
# Loki — Log Aggregation
# =============================================================================

resource "docker_container" "loki" {
  name  = "qa-loki"
  image = docker_image.loki.image_id

  networks_advanced {
    name = docker_network.qa_net.name
  }

  ports {
    internal = 3100
    external = var.loki_port
  }

  volumes {
    host_path      = abspath("${path.module}/../../docker/loki-config.yaml")
    container_path = "/etc/loki/local-config.yaml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.loki_storage.name
    container_path = "/loki"
  }

  command = ["-config.file=/etc/loki/local-config.yaml"]

  healthcheck {
    test         = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3100/ready"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 5
    start_period = "10s"
  }

  restart = "unless-stopped"
}

# =============================================================================
# Grafana — Dashboards
# =============================================================================

resource "docker_container" "grafana" {
  name  = "qa-grafana"
  image = docker_image.grafana.image_id

  networks_advanced {
    name = docker_network.qa_net.name
  }

  ports {
    internal = 3000
    external = var.grafana_port
  }

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_USERS_ALLOW_SIGN_UP=false",
  ]

  volumes {
    volume_name    = docker_volume.grafana_storage.name
    container_path = "/var/lib/grafana"
  }

  volumes {
    host_path      = abspath("${path.module}/../../docker/grafana/provisioning")
    container_path = "/etc/grafana/provisioning"
    read_only      = true
  }

  depends_on = [docker_container.loki]

  restart = "unless-stopped"
}
