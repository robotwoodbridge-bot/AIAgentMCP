# Introduction
This is a very early stage of my CI/CD Quality Engineering framework.
It's still a proof of concept project and work in progress to support many organizations' Project 10x. 
The project consist of 3 major parts:
    a. all quality gates (smoke test, performance test, security test, pen test, api test etc...)
    b. IaC, infrastructure as code is built in the infra/ folder to support various tools and testing
    c. Agents and sub-agents for Claude are ready

I will try to update this project daily.

# Getting Started
Please read the CLAUDE.MD for the following...

Installation process
Software dependencies
Latest releases
API references

# Build and Test
This framework runs on **both Azure DevOps and GitHub Actions** — the pipelines are
mirrored and kept in parity. 

Options to run:
Run locally and with Infrastructure as Code (Iac)
Run local browsers with pabot in parallel exec
Clone this to your Azure DevOps, and set up Pipelines to run (`ci/*.yml`).
Push to GitHub and use the **Actions** tab — workflows in `.github/workflows/` each
have a manual "Run workflow" button (`workflow_dispatch`).

See **CI/CD** in CLAUDE.md for the full Azure ↔ GitHub Actions pipeline map and the
required secrets (`GMAIL_USER`, `GMAIL_APP_PASSWORD`, `LOGIN_USERNAME`, `LOGIN_PASSWORD`).

# Contribute#
Please email me at guan01@gmail.com for any question or contribution.

