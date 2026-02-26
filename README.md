# HYLASTIX Cloud Infrastructure Test

This project implements the candidate task for HYLASTIX GmbH.

The goal was to provision a minimal cloud infrastructure in Microsoft Azure using Infrastructure as Code, deploy a containerized Keycloak setup with a Postgres database, and protect access to a static web page via OpenID Connect.

---

## Live Demo

Public endpoint: `http://<public-ip>/`

The application is exposed via Azure Public IP and served through Nginx running inside Docker on a Linux VM.

# Auth test data
Login: admin
Password: 55655

---

## Architecture Overview

```
Internet
↓
Azure Public IP
↓
Azure VM (Ubuntu 22.04 LTS)
↓
Docker network
├── nginx          (reverse proxy, port 80)
├── oauth2-proxy   (OIDC middleware)
├── keycloak       (Identity Provider, port 8080)
└── postgres       (Keycloak database)
```

---

## Infrastructure

All infrastructure components are provisioned using Terraform.

### Azure Resources

- Resource Group
- Virtual Network + Subnet
- Network Security Group
- Public IP (Standard SKU)
- Linux Virtual Machine (Ubuntu 22.04 LTS)

### Open Ports

- 22 (SSH)
- 80 (HTTP)
- 8080 (Keycloak)

---

## Container Environment

### Services

- **Nginx** — reverse proxy and static web server with proxy buffer tuning for large oauth2-proxy headers
- **Keycloak** — Identity Provider (OIDC)
- **Postgres** — persistent database for Keycloak
- **oauth2-proxy** — authentication gateway

Docker Compose orchestrates all services with health checks and proper dependency ordering.

---

## Authentication Flow

1. User accesses the public endpoint
2. Nginx forwards auth requests to oauth2-proxy via `auth_request`
3. oauth2-proxy redirects unauthenticated users to Keycloak
4. User authenticates with Keycloak credentials
5. oauth2-proxy validates the OIDC token and grants access
6. Nginx serves the protected static page

**Logout behavior:** The /oauth2/sign_out endpoint clears the oauth2-proxy session cookie.
The Keycloak SSO session may remain active unless explicitly terminated at the Identity Provider.

---

## CI/CD

GitHub Actions automates the full infrastructure lifecycle.

### Workflows

**Deploy** (`deploy.yml`) — triggered manually via `workflow_dispatch`:
1. Checkout repository
2. Prepare SSH keys from GitHub Secrets
3. `terraform apply` — provision Azure infrastructure
4. Extract VM public IP from Terraform output
5. `ansible-playbook` — configure VM and deploy stack

**Destroy** (`destroy.yml`) — triggered manually via `workflow_dispatch`:
1. `terraform destroy` — tear down all Azure resources

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `ARM_CLIENT_ID` | Azure Service Principal client ID |
| `ARM_CLIENT_SECRET` | Azure Service Principal secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |
| `SSH_PRIVATE_KEY` | SSH private key for VM access |
| `DOCKER_ENV_FILE` | Contents of `.env` file with all service secrets |

---

## Provisioning (Ansible)

Ansible handles full VM configuration automatically after Terraform provisions the VM.

### Tasks

- Install Docker Engine + Compose plugin
- Copy Docker stack to VM
- Write `.env` from GitHub Secret
- Inject dynamic values (`PUBLIC_URL`, `OIDC_ISSUER`) based on VM public IP
- Start Docker Compose stack
- Wait for Keycloak to become healthy
- Disable SSL requirement in Keycloak master realm
- Set admin email and mark as verified
- Create `nginx` OIDC client in Keycloak with correct redirect URIs

All Keycloak configuration is fully automated — no manual steps required after deploy.

---

## Security Notes

- All secrets are excluded from the repository
- Terraform state is not committed (move to remote backend for production)
- SSH private keys are not committed
- Example configuration files are provided where needed

---

## Author: Maksym Petrykin
Email: [m.petrykin@gmx.de](mailto:m.petrykin@gmx.de)  
Telegram: [@max_p95](https://t.me/max_p95)