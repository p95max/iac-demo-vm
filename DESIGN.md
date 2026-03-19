## Design Decisions

### Why Terraform?

Terraform was chosen for infrastructure provisioning because it provides declarative and reproducible infrastructure as code.

**Improvements (v2):**
- Resource naming aligned with purpose instead of type
- Inventory generation moved to Terraform using `templatefile()`
- Reduced dependency on CI scripts

---

### Why GitHub Actions?

GitHub Actions was chosen due to tight integration with the repository and built-in secret management.

**Improvements (v2):**
- Reduced bash scripting
- Cleaner pipeline with Terraform → Ansible separation

---

### Why Ansible?

Ansible handles VM configuration after provisioning.

**Improvements (v2):**

- Introduced **role-based architecture**
- Replaced flat playbook with modular structure:
  - docker
  - app_deploy
  - keycloak

Benefits:
- better maintainability
- reusability
- clearer separation of concerns

---

### Why Reduce Shell Usage?

Shell commands reduce idempotency and make automation harder to maintain.

**Changes (v2):**
- Replaced docker CLI calls with `community.docker.docker_compose_v2`
- Left shell only where no native modules exist (Keycloak CLI)

---

### Why Templates Instead of Static Files?

Previously, configuration was copied as static files.

**Now:**
- docker-compose and nginx configs are generated dynamically
- environment values injected at deploy time

Benefits:
- flexibility
- portability
- easier scaling

---

### Why Remove docker/ Directory?

Static copying was replaced with templating approach.

This aligns with IaC principles:

> infrastructure should generate configuration, not copy artifacts

---

### Why Docker Compose?

Docker Compose is sufficient for a single-node deployment.

Kubernetes was intentionally avoided due to:
- higher complexity
- no benefit at this scale

---

### Why Nginx?

Nginx is used as:
- reverse proxy
- static file server
- authentication gateway via `auth_request`

---

### Why oauth2-proxy?

Nginx does not support OIDC natively.

oauth2-proxy:
- handles authentication flow
- integrates with Keycloak
- works seamlessly with Nginx

---

### Network Design

- Single internal Docker network (`backend`)
- Public ports:
  - 80 (Nginx)
  - 8080 (Keycloak)
  - 22 (SSH)

Minimizes attack surface.

---

### Trade-offs

- Keycloak bootstrap still uses shell
  - no stable Ansible module available
- Terraform modules not introduced
  - avoided overengineering for small scope

---

### Possible Extensions

- Terraform modules (network / vm)
- Remote state backend (Azure Blob)
- HTTPS (Let's Encrypt)
- Redis for oauth2-proxy sessions
- Monitoring (Prometheus + Grafana)
- Centralized logging (Loki / ELK)