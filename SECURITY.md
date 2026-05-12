# Security Documentation

## 1. Container Security
- **Non-root User**: The application runs as `appuser` (UID 1001) instead of root to prevent privilege escalation.
- **Multi-stage Builds**: Used a builder pattern in the Dockerfile to keep the final image minimal and reduce the attack surface.
- **Slim Base Images**: Used `python:3.11-slim` and `alpine` images for PostgreSQL/Redis.

## 2. Secrets Management
- No secrets are hardcoded in the codebase.
- Local development relies on `.env` files which are excluded via `.gitignore`.
- Production deployment relies entirely on **GitHub Actions Secrets** (`SSH_PRIVATE_KEY`, `DB_PASSWORD`, etc.) injected securely at runtime.

## 3. Network Security & Hardening
- **Firewall**: UFW configured to strictly allow only ports 22 (SSH), 80 (HTTP), 443 (HTTPS), and 3001 (Uptime Kuma).
- **SSH Hardening**: Disabled `PermitRootLogin` and `PasswordAuthentication` in `sshd_config`. Access is strictly via RSA/ED25519 keys.
- **Internal Stack**: PostgreSQL and Redis are isolated within the `statuspulse_net` Docker network and are not exposed directly to the public internet.

## 4. Web Application Security
- Enforced HTTPS using Caddy with automatic TLS via Let's Encrypt.
- Added critical security headers: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`, and `X-XSS-Protection`.