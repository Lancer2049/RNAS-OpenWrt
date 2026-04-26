import subprocess
import re

def run_accel_cmd(*args: str) -> str:
    try:
        result = subprocess.run(
            ["/usr/bin/accel-cmd"] + list(args),
            capture_output=True, text=True, timeout=5
        )
        return result.stdout
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return ""

def parse_sessions(raw: str) -> list:
    rows = []
    header_skipped = False
    for line in raw.splitlines():
        if not header_skipped:
            if line.strip().startswith("ifname") or line.strip().startswith("---"):
                header_skipped = True
            continue
        cols = line.split()
        if len(cols) >= 9:
            rows.append({
                "sid": cols[0],
                "ifname": cols[1],
                "username": cols[2],
                "ip": cols[3],
                "type": cols[4],
                "state": cols[5],
                "uptime_raw": cols[6],
                "rx_bytes_raw": int(cols[7]) if cols[7].isdigit() else 0,
                "tx_bytes_raw": int(cols[8]) if cols[8].isdigit() else 0,
            })
    return rows

def parse_stat(raw: str) -> dict:
    stat = {"sessions_active": 0, "uptime": "N/A", "radius_state": "unknown"}
    m = re.search(r"uptime:\s*(\S+)", raw)
    if m: stat["uptime"] = m.group(1)
    m = re.search(r"cpu:\s*(\S+)", raw)
    if m: stat["cpu"] = m.group(1)
    m = re.search(r"mem\(rss/virt\):\s*(\S+)", raw)
    if m: stat["mem"] = m.group(1)
    m = re.search(r"sessions:.*?active:\s*(\d+)", raw, re.DOTALL)
    if m: stat["sessions_active"] = int(m.group(1))
    m = re.search(r"state:\s*(\S+)", raw)
    if m: stat["radius_state"] = m.group(1)
    m = re.search(r"fail count:\s*(\d+)", raw)
    if m: stat["radius_fail_count"] = int(m.group(1))
    m = re.search(r"auth sent:\s*(\d+)", raw)
    if m: stat["auth_sent"] = int(m.group(1))
    m = re.search(r"acct sent:\s*(\d+)", raw)
    if m: stat["acct_sent"] = int(m.group(1))
    return stat

def disconnect_session(sid: str) -> bool:
    output = run_accel_cmd("terminate", "sid", sid, "hard")
    return "not found" not in output.lower() and output.strip() != ""
