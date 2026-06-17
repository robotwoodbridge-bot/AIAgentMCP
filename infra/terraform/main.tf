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
# Images
# =============================================================================

# Build the image with the native docker CLI to avoid the kreuzwerker provider's
# legacy build API which corrupts the tar stream on some Docker Desktop versions.
resource "null_resource" "playwright_runner_build" {
  triggers = {
    dockerfile   = filemd5("${path.module}/../../docker/Dockerfile.runner")
    requirements = filemd5("${path.module}/../../requirements.txt")
  }

  provisioner "local-exec" {
    command = "docker build -t robotkali-runner:latest -f docker/Dockerfile.runner ."
    working_dir = abspath("${path.module}/../..")
  }
}

resource "docker_image" "playwright_runner" {
  name         = "robotkali-runner:latest"
  keep_locally = true

  depends_on = [null_resource.playwright_runner_build]
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
# Playwright Runner
# The test runner container has Playwright + all browsers baked in via
# mcr.microsoft.com/playwright/python. Tests are volume-mounted from the
# host so edits are reflected instantly without a rebuild.
# Run tests inside it with:
#   docker exec qa-playwright-runner python -m robot --outputdir results tests/
# =============================================================================

resource "docker_container" "playwright_runner" {
  name    = "qa-playwright-runner"
  image   = docker_image.playwright_runner.image_id
  command = ["tail", "-f", "/dev/null"] # keeps container alive; tests launched via exec

  networks_advanced {
    name = docker_network.qa_net.name
  }

  # Mount project root live — edits on host are visible inside the container
  # without a rebuild. results/ is also written back to the host.
  volumes {
    host_path      = abspath("${path.module}/../..")
    container_path = "/robotkali"
  }

  env = [
    "LOKI_URL=http://qa-loki:3100/loki/api/v1/push",
    "LOKI_ENABLED=${var.loki_enabled}",
    "PYTHONPATH=/robotkali",
  ]

  restart = "unless-stopped"

  # The image tag is :latest, so a rebuild alone doesn't register as a change —
  # recreate the container whenever the build (Dockerfile/requirements) changes.
  lifecycle {
    replace_triggered_by = [null_resource.playwright_runner_build]
  }

  depends_on = [docker_container.loki]
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
