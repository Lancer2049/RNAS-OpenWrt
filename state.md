# RNAS Development State

**Session Date**: 2026-04-27
**Status**: ✅ Phase 1 v2 complete — continuing Phase 2: dnsmasq + nftables generators

## Current Goal
Build RNAS as a standalone NAS platform for x86 Linux — fusion of accel-ppp + Linux networking under unified `/etc/rnas/` config with systemd orchestration and Vue.js dashboard.

## Phase 1 — Complete ✅
- `/etc/rnas/` config schema: 14 templates (access.d/ + network.d/)
- `rnas-config` engine: INI parser + accel-ppp generator
- systemd units: rnas.target + accel-ppp + dnsmasq + firewall
- FastAPI backend: status, sessions, config endpoints
- Vue.js dashboard: status cards + sessions table + disconnect
- `scripts/install.sh`: one-command bootstrap installer
- README + AGENTS.md rewritten for v2 fusion architecture

## Next Steps — Phase 2: Network + Monitoring

### Immediate
1. **dnsmasq config generator** in `rnas-config`: `/etc/rnas/network.d/dhcp.conf` → dnsmasq.conf
2. **nftables config generator** in `rnas-config`: `/etc/rnas/network.d/firewall.conf` → nft rules
3. **Network config pages** in Vue.js dashboard (interfaces, DHCP, firewall)

### Later
4. SNMP + NetFlow + syslog monitoring presets
5. Traffic dashboard with live graphs (Chart.js)
6. `rnas-network` + `rnas-mon` package definitions

## Open Issues
- VM1 is UOS Desktop (not OpenWrt) — LuCI/UCI not testable live
- GitHub push sometimes times out (workaround: unset credential.helper)
- protocol.lua fixed (commit ca12521) — L2TP/PPTP/SSTP now have interface field
