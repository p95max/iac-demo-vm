# HYLASTIX Cloud Infrastructure Test

This project implements the candidate task for HYLASTIX GmbH.

The goal was to provision a minimal cloud infrastructure in Microsoft Azure using Infrastructure as Code, deploy a containerized Keycloak setup with a Postgres database, and protect access to a static web page via OpenID Connect.

---

## Live Demo

Public endpoint: `http://<public-ip>/`

The application is exposed via Azure Public IP and served through Nginx running inside Docker on a Linux VM.

### Auth test data for Keycloak
- Login: admin
- Password: 55655

---

## Design Decisions

See [DESIGN.md](DESIGN.md) for detailed architectural and implementation decisions.

---

## Architecture Overview
Internet
↓
Azure Public IP
↓
Azure VM (Ubuntu 22.04 LTS)
↓
Docker network
├── nginx (reverse proxy, port 80)
├── oauth2-proxy (OIDC middleware)
├── keycloak (Identity Provider, port 8080)
└── postgres (Keycloak database)

---


---

## Infrastructure (Terraform)

All infrastructure components are provisioned using Terraform.

### Azure Resources

- Resource Group
- Virtual Network + Subnet
- Network Security Group
- Public IP (Standard SKU)
- Linux Virtual Machine (Ubuntu 22.04 LTS)

### Improvements (v2 after feedback)

- Resource naming aligned with **purpose instead of type**
- Introduced **Terraform templatefile()** for Ansible inventory generation
- Reduced coupling between Terraform and CI (less bash glue code)

---

## Configuration Management (Ansible)

Ansible is responsible for full VM provisioning and application deployment.

### Key Improvements

- Introduced **role-based structure**
- Replaced flat playbook with modular design
- Reduced usage of `shell` and `command`
- Introduced **Jinja2 templates** for dynamic configuration generation

### Roles

- `docker`
  - installs Docker Engine and dependencies
  - configures system packages

- `app_deploy`
  - renders `.env`
  - generates `docker-compose.yml` via template
  - generates `nginx.conf`
  - deploys application stack

- `keycloak`
  - bootstraps Keycloak
  - configures realm settings
  - creates OIDC client

---

## Container Environment

### Services

- **Nginx**
  - reverse proxy
  - static file server
  - integrates with oauth2-proxy via `auth_request`

- **oauth2-proxy**
  - handles OIDC authentication flow
  - integrates with Keycloak

- **Keycloak**
  - identity provider
  - configured automatically via Ansible

- **Postgres**
  - persistent database for Keycloak

### Improvements (v2)

- Removed static `docker/` directory
- All configuration is now **generated via templates**
- Environment-specific values injected dynamically

---

## Authentication Flow

1. User accesses the public endpoint
2. Nginx delegates authentication to oauth2-proxy
3. oauth2-proxy redirects user to Keycloak
4. User authenticates
5. oauth2-proxy validates token
6. Nginx serves protected content

---

## CI/CD (GitHub Actions)

GitHub Actions automates infrastructure provisioning and deployment.

### Deploy Workflow

1. Checkout repository
2. Prepare SSH keys
3. Run `terraform apply`
4. Generate Ansible inventory from Terraform output
5. Execute Ansible playbook

### Improvements (v2)

- Removed manual `echo`-based inventory generation
- Terraform outputs now directly generate inventory file
- Cleaner separation of responsibilities

---

## GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| ARM_CLIENT_ID | Azure Service Principal |
| ARM_CLIENT_SECRET | Azure Secret |
| ARM_SUBSCRIPTION_ID | Subscription |
| ARM_TENANT_ID | Tenant |
| SSH_PRIVATE_KEY | SSH access |
| DOCKER_ENV_FILE | Application env variables |

---

## Security Notes

- Secrets are not stored in repository
- SSH keys injected via CI only
- Terraform state is not committed (should use remote backend in production)

---

## Author

Maksym Petrykin  
Email: m.petrykin@gmx.de  
Telegram: @max_p95