# HYLASTIX Cloud Infrastructure Test

This project implements the candidate task for HYLASTIX GmbH.

The goal was to provision a minimal cloud infrastructure in Microsoft
Azure using Infrastructure as Code, deploy a containerized Keycloak
setup with a Postgres database, and protect access to a static web page
via OpenID Connect.

------------------------------------------------------------------------

## Live Demo

Public endpoint:

http://20.223.216.43/

The application is exposed via Azure Public IP and served through Nginx
running inside Docker on a Linux VM.

------------------------------------------------------------------------

## Architecture Overview

Internet\
↓\
Azure Public IP\
↓\
Azure VM (Ubuntu 22.04 LTS)\
↓\
Docker network\
├── nginx (reverse proxy, port 80)\
├── oauth2-proxy (OIDC middleware)\
├── keycloak (Identity Provider)\
└── postgres (Keycloak database)

------------------------------------------------------------------------

## Infrastructure

All infrastructure components are provisioned using Terraform.

### Azure Resources

-   Resource Group
-   Virtual Network
-   Subnet
-   Network Security Group
-   Public IP (Standard SKU)
-   Linux Virtual Machine (Ubuntu 22.04 LTS)

### Network Configuration

Open ports:

-   22 (SSH)
-   80 (HTTP)
-   8080 (Keycloak)

The NSG is attached to the subnet to control inbound traffic.

------------------------------------------------------------------------

## Container Environment

The VM hosts a minimal Docker-based container environment.

### Services

-   Nginx --- reverse proxy and static web server
-   Keycloak --- Identity Provider (OIDC)
-   Postgres --- persistent database for Keycloak
-   oauth2-proxy --- authentication gateway

Docker Compose is used to orchestrate services.

------------------------------------------------------------------------

## Authentication Flow

1.  User accesses the public endpoint
2.  Nginx forwards auth requests to oauth2-proxy
3.  oauth2-proxy redirects to Keycloak
4.  User authenticates
5.  Access is granted to the protected static page

------------------------------------------------------------------------

## Provisioning

All configuration tasks on the VM are automated using Ansible.

Ansible responsibilities:

-   Install Docker
-   Install Docker Compose plugin
-   Configure user permissions
-   Deploy container stack

------------------------------------------------------------------------

## CI/CD (Planned / Extendable)

GitHub Actions can be used to:

-   Deploy infrastructure (terraform apply)
-   Configure VM (ansible-playbook)
-   Destroy infrastructure (terraform destroy)

------------------------------------------------------------------------

## Why These Components?

### Terraform

Used for declarative Infrastructure as Code.\
Ensures reproducibility and state management.

### Ansible

Chosen for post-provision configuration.\
Keeps infrastructure provisioning and configuration management
separated.

### Docker

Provides isolated, portable, minimal runtime environment.

### Keycloak

Open-source Identity Provider supporting OpenID Connect.

### Postgres

Reliable relational database required by Keycloak.

### Nginx

Lightweight reverse proxy and static content server.

------------------------------------------------------------------------

## Possible Extensions

-   HTTPS with Let's Encrypt
-   Domain binding
-   Azure Managed Identity integration
-   Container health checks
-   Azure Application Gateway
-   Remote Terraform backend (Azure Storage)
-   Monitoring (Prometheus + Grafana)
-   Logging stack (ELK)

------------------------------------------------------------------------

## Current Status

Infrastructure provisioning: Complete\
Container deployment: Complete\
External access: Operational\
OIDC integration: In progress\
CI/CD automation: Extendable

------------------------------------------------------------------------

## Cleanup

To destroy infrastructure:

terraform destroy

------------------------------------------------------------------------

## Notes

-   All secrets are excluded from the repository.
-   Terraform state is not committed.
-   SSH private keys are not committed.
-   Example configuration files are provided where needed.

------------------------------------------------------------------------

## Author: Maksym Petrykin  
Email: [m.petrykin@gmx.de](mailto:m.petrykin@gmx.de)  
Telegram: [@max_p95](https://t.me/max_p95)