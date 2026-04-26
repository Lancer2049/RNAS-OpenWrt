# RNAS AGENTS — AI Agent Context File

## Project Identity

RNAS is a **standalone NAS simulation platform** for x86 Linux/VM — not an OpenWrt distribution. It fuses accel-ppp with standard Linux networking under a unified `/etc/rnas/` config tree.

## Architecture (v2 Fusion Model)

```
 /etc/rnas/*.conf  →  rnas-config (Python)  →  native daemon configs
     ↓                                              ↓
 rnas-api (FastAPI)  ←──  accel-cmd  ←──  accel-ppp/dnsmasq/nftables
     ↓
 Vue.js SPA Dashboard  (web/frontend/)
```

- **Base OS**: Debian/Ubuntu/UOS x86_64, NOT OpenWrt firmware
- **Service mgmt**: systemd units in `systemd/`
- **Config**: INI-style UCI-format files in `/etc/rnas/`
- **OpenWrt**: secondary target only (package/ directory preserved)

## Key Directories

| Path | Purpose |
|------|---------|
| `cmd/rnas-config/rnas_config.py` | Config engine: parser + accel-ppp generator |
| `web/api/` | FastAPI: status, sessions, config endpoints |
| `web/frontend/` | Vue.js 3 SPA dashboard |
| `configs/` | `/etc/rnas/` config templates (14 files) |
| `systemd/` | systemd units: target + services |
| `tools/` | CLI testing tools (coa-test, acct-verify, etc.) |
| `tests/` | Integration tests |
| `scripts/install.sh` | One-command installer |

## Test Environment

```
VM1: 192.168.0.84  —  UOS Desktop + accel-ppp (PPPoE server)
VM2: 192.168.0.85  —  FreeRADIUS + AIRadius (RADIUS server)
VM3: 192.168.0.82  —  Ubuntu CPE client (pppoe)
```

Test user: `testuser` / `testpass` in FreeRADIUS radcheck.

## Conventions

- Python code: `cmd/rnas-config/` and `web/api/`
- Shell scripts: must pass `shellcheck`, use `set -e`
- Config files: INI format, `${VAR:-default}` for secrets
- No hardcoded passwords — use `${RNAS_RADIUS_SECRET}` env var
- Git: `node_modules/`, `dist/`, `__pycache__/` in `.gitignore`
