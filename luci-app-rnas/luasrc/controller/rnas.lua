module("luci.controller.rnas", package.seeall)

require("uci")
require("luci.util")
require("luci.sys")

local cached_uci = nil
local function get_uci()
    if not cached_uci then
        cached_uci = uci.cursor()
    end
    return cached_uci
end

function index()
    entry({"admin", "network", "rnas"}, alias("admin", "network", "rnas", "overview"), _("RADIUS NAS"))
    entry({"admin", "network", "rnas", "overview"}, cbi("rnas/overview"), _("Overview"), 1)
    entry({"admin", "network", "rnas", "radius"}, cbi("rnas/radius"), _("RADIUS Settings"), 2)
    entry({"admin", "network", "rnas", "protocol"}, cbi("rnas/protocol"), _("Protocol Config"), 3)
    entry({"admin", "network", "rnas", "ip_pool"}, cbi("rnas/ip_pool"), _("IP Pool"), 4)
    entry({"admin", "network", "rnas", "sessions"}, cbi("rnas/sessions"), _("Sessions"), 5)
    entry({"admin", "network", "rnas", "coa"}, cbi("rnas/coa"), _("CoA Control"), 6)
    entry({"admin", "network", "rnas", "status"}, cbi("rnas/status"), _("Status"), 7)

    entry({"admin", "network", "rnas", "sessions", "terminate"}, call("action_terminate_session"))
    entry({"admin", "network", "rnas", "coa", "disconnect"}, call("action_coa_disconnect"))
    entry({"admin", "network", "rnas", "coa", "timeout"}, call("action_coa_timeout"))
    entry({"admin", "network", "rnas", "status", "data"}, call("get_status_data"))
end

-- ===========================================================================
-- Session data helpers
-- ===========================================================================

-- Parse accel-cmd "show sessions" structured column output into Lua table
-- Columns: sid, ifname, username, ip, state, uptime-raw, rx-bytes-raw, tx-bytes-raw
local function parse_sessions(raw)
    local sessions = {}
    if not raw or raw == "" then return sessions end
    -- Skip header line starting with " ifname" or " "
    local in_body = false
    for line in raw:gmatch("[^\r\n]+") do
        if in_body then
            local cols = {}
            for col in line:gmatch("%S+") do
                table.insert(cols, col)
            end
            if #cols >= 8 then
                table.insert(sessions, {
                    sid       = cols[1],
                    ifname    = cols[2],
                    username  = cols[3],
                    ip        = cols[4],
                    state     = cols[6] or cols[5],  -- state column position
                    uptime    = cols[6],             -- uptime-raw in seconds
                    rx_bytes  = tonumber(cols[7]) or 0,
                    tx_bytes  = tonumber(cols[8]) or 0,
                })
            end
        elseif line:match("^%s*ifname") or line:match("^%-+") then
            in_body = true
        end
    end
    return sessions
end

-- Parse accel-cmd "show stat" output for key metrics
local function parse_service_stat(raw)
    local stat = { sessions_active = 0, uptime = "N/A", cpu = "0%", mem = "N/A", radius_state = "unknown" }
    if not raw then return stat end
    stat.uptime = raw:match("uptime:%s*(%S+)") or "N/A"
    stat.cpu    = raw:match("cpu:%s*(%S+)") or "0%"
    stat.mem    = raw:match("mem%(rss/virt%):%s*(%S+)") or "N/A"
    local rss, virt = stat.mem:match("(%d+)/(%d+)")
    if rss and virt then stat.mem = string.format("%s/%s kB", rss, virt) end
    stat.sessions_active = tonumber(raw:match("sessions:.-active:%s*(%d+)") or "0")
    stat.radius_state = raw:match("state:%s*(%S+)") or "unknown"
    stat.radius_fail_count = tonumber(raw:match("fail count:%s*(%d+)") or "0")
    stat.auth_sent = tonumber(raw:match("auth sent:%s*(%d+)") or "0")
    stat.acct_sent = tonumber(raw:match("acct sent:%s*(%d+)") or "0")
    return stat
end

-- ===========================================================================
-- Action handlers
-- ===========================================================================

function action_terminate_session()
    local sid = luci.http.formvalue("sid")
    if sid then
        luci.sys.exec("accel-cmd terminate sid " .. sid .. " hard")
        luci.http.redirect(luci.dispatcher.build_url("admin/network/rnas/sessions"))
    end
end

function action_coa_disconnect()
    local username = luci.http.formvalue("username")
    if username then
        local uci = get_uci()
        local secret = uci:get("rnas", "radius", "secret") or "testing123"
        local server = uci:get("rnas", "radius", "auth_server") or "127.0.0.1"
        luci.sys.exec("echo 'User-Name=" .. username .. "' | radclient " .. server .. ":3799 disconnect " .. secret)
        luci.http.redirect(luci.dispatcher.build_url("admin/network/rnas/coa"))
    end
end

function action_coa_timeout()
    local username = luci.http.formvalue("username")
    local timeout = luci.http.formvalue("timeout") or "3600"
    if username then
        local uci = get_uci()
        local secret = uci:get("rnas", "radius", "secret") or "testing123"
        local server = uci:get("rnas", "radius", "auth_server") or "127.0.0.1"
        luci.sys.exec("echo -e 'User-Name=" .. username .. "\\nSession-Timeout=" .. timeout .. "' | radclient " .. server .. ":3799 coa " .. secret)
        luci.http.redirect(luci.dispatcher.build_url("admin/network/rnas/coa"))
    end
end

-- ===========================================================================
-- Status API — returns JSON with structured session + service data
-- ===========================================================================
function get_status_data()
    local uci = get_uci()

    -- Determine active protocol from UCI
    local protocol = "disabled"
    for _, proto in ipairs({"pppoe", "ipoe", "l2tp", "pptp", "sstp"}) do
        if uci:get("rnas", proto, "interface") then
            protocol = proto
            break
        end
    end

    -- Get sessions from accel-cmd with explicit column selection
    local sessions_raw = luci.sys.exec(
        "accel-cmd show sessions " ..
        "sid,ifname,username,ip,type,state,uptime-raw,rx-bytes-raw,tx-bytes-raw " ..
        "2>/dev/null"
    )
    local sessions = parse_sessions(sessions_raw)

    -- Get service statistics
    local stat_raw = luci.sys.exec("accel-cmd show stat 2>/dev/null")
    local service_stat = parse_service_stat(stat_raw)

    -- System-level fallbacks
    local sys_uptime = luci.sys.exec("cat /proc/uptime 2>/dev/null | cut -d' ' -f1"):match("%S+") or "0"
    local sys_mem = luci.sys.exec("free 2>/dev/null | awk '/^Mem:/{printf \"%.0f\", $3}'"):match("%d+") or "0"

    luci.http.prepare_json()
    luci.http.write_json({
        protocol = protocol,
        sessions = sessions,
        service = service_stat,
        system = {
            uptime_seconds = sys_uptime,
            memory_kb = sys_mem,
        }
    })
end
