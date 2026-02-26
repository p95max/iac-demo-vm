## Design Decisions

### Why Terraform?
Terraform was chosen for infrastructure provisioning because it provides declarative, reproducible infrastructure as code. The entire Azure environment (VM, VNet, NSG, Public IP) can be created and destroyed with a single command. Alternatives like ARM templates or Bicep were not used — they are Azure-specific, while Terraform is provider-agnostic and more readable.

### Why Ansible?
Ansible handles VM configuration after Terraform provisions the infrastructure. It installs Docker, copies the application stack, writes the `.env` file, and fully configures Keycloak automatically — no manual SSH steps required. Shell scripts were considered but Ansible is idempotent, readable, and fits the separation of concerns: Terraform for infrastructure, Ansible for configuration.

### Why Docker Compose?
Docker Compose was chosen as the container environment because it is lightweight, simple to reason about, and sufficient for a single-VM setup. Kubernetes would be overkill for this scale — it adds significant operational complexity without benefit when running 4 containers on one machine.

### Why These Images?
- `postgres:15-alpine` — minimal footprint, stable, well-supported by Keycloak
- `quay.io/keycloak/keycloak:24.0` — official Keycloak image, supports OIDC out of the box
- `quay.io/oauth2-proxy/oauth2-proxy:v7.6.0` — lightweight OIDC proxy that integrates cleanly with Nginx `auth_request`
- `nginx:alpine` — minimal reverse proxy, serves static files, handles auth delegation

### Why This Network Configuration?
All containers share a single internal Docker network (`backend`). Only Nginx (port 80) and Keycloak (port 8080) are exposed externally via NSG rules. oauth2-proxy and Postgres are internal only — they have no public ports. SSH (port 22) is open for provisioning. This keeps the attack surface minimal for a non-production setup.

### Why oauth2-proxy Instead of Direct Keycloak Integration?
Nginx does not natively support OIDC. oauth2-proxy sits between Nginx and the application, handles the full OIDC flow, and uses Nginx `auth_request` to gate access. This is a clean, well-established pattern that keeps the static web server simple.

### Possible Extensions
- **HTTPS / Let's Encrypt** — production deployments require TLS; can be added via Certbot or Azure Application Gateway
- **Remote Terraform backend** — storing state in Azure Blob Storage prevents state conflicts in team workflows
- **Redis session storage** — oauth2-proxy currently splits sessions across multiple cookies (>4kb); Redis eliminates this
- **Domain binding** — replace raw IP with a proper domain for stable URLs across deploys
- **Monitoring** — Prometheus + Grafana for container and VM metrics
- **Logging** — centralized log aggregation (ELK or Loki) for debugging across services
- **Azure Managed Identity** — eliminate static credentials for Azure API access