#!/bin/bash
# RNAS post-reboot quick verification
# Runs after VM1 comes back from reboot
set -e

echo "=== 1. Verify VM1 accel-ppp auto-start ==="
ssh -o ConnectTimeout=3 root@192.168.0.84 "systemctl is-active accel-ppp"
ssh -o ConnectTimeout=3 root@192.168.0.84 "lsof -i :3799 | grep -v COMMAND || echo 'DAE NOT LISTENING'"
ssh -o ConnectTimeout=3 root@192.168.0.84 "grep 'nas-identifier' /etc/accel-ppp.conf"

echo ""
echo "=== 2. Verify VM1 logs ==="
ssh -o ConnectTimeout=3 root@192.168.0.84 "tail -5 /var/log/accel-ppp/accel-ppp.log"

echo ""
echo "=== 3. PPPoE connect from VM3 ==="
ssh -o ConnectTimeout=3 root@192.168.0.82 "killall pppd 2>/dev/null; sleep 1
pppd pty 'pppoe -I ens33' user testuser password testpass noipdefault noauth nodetach logfile /tmp/pppoe.log 2>&1 & sleep 6
ip addr show ppp0 2>/dev/null | grep 'inet ' || echo 'PPPoE FAILED'"

echo ""
echo "=== 4. Check RADIUS accounting ==="
sleep 3
ssh -o ConnectTimeout=3 root@192.168.0.85 "psql -U radius -d radius -c \"SELECT radacctid, username, framedipaddress, acctstarttime FROM radacct WHERE username='testuser' AND nasipaddress='192.168.0.84' ORDER BY radacctid DESC LIMIT 3;\""

echo ""
echo "=== 5. CoA Disconnect test ==="
ssh -o ConnectTimeout=3 root@192.168.0.85 "echo 'User-Name=testuser' | radclient -t 3 192.168.0.84:3799 disconnect testing123"

echo ""
echo "=== 6. Verify PPPoE dropped on VM3 ==="
sleep 2
ssh -o ConnectTimeout=3 root@192.168.0.82 "ip addr show ppp0 2>/dev/null | grep 'inet ' || echo 'ppp0 DISCONNECTED ✅'"

echo ""
echo "=== 7. Final RADIUS records ==="
ssh -o ConnectTimeout=3 root@192.168.0.85 "psql -U radius -d radius -c \"SELECT radacctid, acctstoptime, acctterminatecause FROM radacct WHERE username='testuser' AND nasipaddress='192.168.0.84' ORDER BY radacctid DESC LIMIT 1;\""

echo ""
echo "=== DONE ==="