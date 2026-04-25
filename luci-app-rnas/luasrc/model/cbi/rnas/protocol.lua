local map = Map("rnas", translate("Protocol Configuration"),
    translate("Configure access protocols. Each protocol maps to a named section in /etc/config/rnas."))

-- ===== PPPoE section =====
local pppoe = map:section(NamedSection, "pppoe", "pppoe", translate("PPPoE"))

pppoe:tab("general", translate("General"))
pppoe:tab("advanced", translate("Advanced"))

o = pppoe:taboption("general", Value, "interface", translate("Interface"))
o.datatype = "network"
o.placeholder = "br-lan"
o.rmempty = false

o = pppoe:taboption("general", Value, "ac_name", translate("AC Name"))
o.placeholder = "RNAS"
o.default = "RNAS"

o = pppoe:taboption("advanced", Value, "service_name", translate("Service Name"))
o.placeholder = translate("Leave empty for any")

o = pppoe:taboption("advanced", Value, "verbose", translate("Verbose Level"))
o.datatype = "uinteger"
o.default = "1"

-- ===== PPP section (global PPP parameters) =====
local ppp = map:section(NamedSection, "ppp", "ppp", translate("PPP Settings"))

o = ppp:option(Value, "mtu", translate("MTU"))
o.datatype = "uinteger"
o.default = "1492"

o = ppp:option(Value, "mru", translate("MRU"))
o.datatype = "uinteger"
o.default = "1492"

o = ppp:option(Value, "min_mtu", translate("Minimum MTU"))
o.datatype = "uinteger"
o.default = "1280"

o = ppp:option(Value, "lcp_echo_interval", translate("LCP Echo Interval (s)"))
o.datatype = "uinteger"
o.default = "30"

o = ppp:option(Value, "lcp_echo_failure", translate("LCP Echo Failure Count"))
o.datatype = "uinteger"
o.default = "3"

-- ===== IPoE section =====
local ipoe = map:section(NamedSection, "ipoe", "ipoe", translate("IPoE (DHCP+)"))
ipoe.addremove = true

o = ipoe:option(Flag, "enabled", translate("Enable IPoE"))
o.default = o.disabled
o.rmempty = false

o = ipoe:option(Value, "interface", translate("Interface"))
o.datatype = "network"
o.placeholder = "br-lan"
o:depends("enabled", "1")

o = ipoe:option(Value, "verbose", translate("Verbose Level"))
o.datatype = "uinteger"
o.default = "1"
o:depends("enabled", "1")

-- ===== L2TP section =====
local l2tp = map:section(NamedSection, "l2tp", "l2tp", translate("L2TP"))
l2tp.addremove = true

o = l2tp:option(Flag, "enabled", translate("Enable L2TP"))
o.default = o.disabled
o.rmempty = false

o = l2tp:option(Value, "port", translate("Port"))
o.datatype = "port"
o.default = "1701"
o:depends("enabled", "1")

o = l2tp:option(Value, "verbose", translate("Verbose Level"))
o.datatype = "uinteger"
o.default = "1"
o:depends("enabled", "1")

-- ===== PPTP section =====
local pptp = map:section(NamedSection, "pptp", "pptp", translate("PPTP"))
pptp.addremove = true

o = pptp:option(Flag, "enabled", translate("Enable PPTP"))
o.default = o.disabled
o.rmempty = false

o = pptp:option(Value, "verbose", translate("Verbose Level"))
o.datatype = "uinteger"
o.default = "1"
o:depends("enabled", "1")

-- ===== SSTP section =====
local sstp = map:section(NamedSection, "sstp", "sstp", translate("SSTP"))
sstp.addremove = true

o = sstp:option(Flag, "enabled", translate("Enable SSTP"))
o.default = o.disabled
o.rmempty = false

o = sstp:option(Value, "port", translate("Port"))
o.datatype = "port"
o.default = "443"
o:depends("enabled", "1")

o = sstp:option(Value, "verbose", translate("Verbose Level"))
o.datatype = "uinteger"
o.default = "1"
o:depends("enabled", "1")

return map
