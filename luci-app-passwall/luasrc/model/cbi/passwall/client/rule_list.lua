local fs = require "nixio.fs"
local api = require "luci.model.cbi.passwall.api.api"
local appname = api.appname

m = Map(appname)
m.apply_on_parse=true
function m.on_apply(self)
luci.sys.call("/etc/init.d/passwall reload > /dev/null 2>&1 &")
end
-- [[ Rule List Settings ]]--
s = m:section(TypedSection, "global_rules")
s.anonymous = true

s:tab("direct_list", translate("Direct List"))
s:tab("proxy_list", translate("Proxy List"))

---- Direct Hosts
local direct_host = string.format("/usr/share/%s/rules/direct_host", appname)
o = s:taboption("direct_list", TextValue, "direct_host", "", "<font color='red'>" .. translate("Join the direct hosts list of domain names will not proxy.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return fs.readfile(direct_host) or "" end
o.write = function(self, section, value) fs.writefile(direct_host, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) fs.writefile(direct_host, "") end
o.validate = function(self, value)
    local hosts= {}
    string.gsub(value, '[^' .. "\r\n" .. ']+', function(w) table.insert(hosts, w) end)
    for index, host in ipairs(hosts) do
        if not datatypes.hostname(host) then
            return nil, host .. " " .. translate("Not valid domain name, please re-enter!")
        end
    end
    return value
end

---- Direct IP
local direct_ip = string.format("/usr/share/%s/rules/direct_ip", appname)
o = s:taboption("direct_list", TextValue, "direct_ip", "", "<font color='red'>" .. translate("These had been joined ip addresses will not proxy. Please input the ip address or ip address segment,every line can input only one ip address. For example: 192.168.0.0/24 or 223.5.5.5.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return fs.readfile(direct_ip) or "" end
o.write = function(self, section, value) fs.writefile(direct_ip, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) fs.writefile(direct_ip, "") end
o.validate = function(self, value)
    local ipmasks= {}
    string.gsub(value, '[^' .. "\r\n" .. ']+', function(w) table.insert(ipmasks, w) end)
    for index, ipmask in ipairs(ipmasks) do
        if not datatypes.ipmask4(ipmask) then
            return nil, ipmask .. " " .. translate("Not valid IP format, please re-enter!")
        end
    end
    return value
end

---- Proxy Hosts
local proxy_host = string.format("/usr/share/%s/rules/proxy_host", appname)
o = s:taboption("proxy_list", TextValue, "proxy_host", "", "<font color='red'>" .. translate("These had been joined websites will use proxy. Please input the domain names of websites,every line can input only one website domain. For example: google.com.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return fs.readfile(proxy_host) or "" end
o.write = function(self, section, value) fs.writefile(proxy_host, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) fs.writefile(proxy_host, "") end
o.validate = function(self, value)
    local hosts= {}
    string.gsub(value, '[^' .. "\r\n" .. ']+', function(w) table.insert(hosts, w) end)
    for index, host in ipairs(hosts) do
        if not datatypes.hostname(host) then
            return nil, host .. " " .. translate("Not valid domain name, please re-enter!")
        end
    end
    return value
end

---- Proxy IP
local proxy_ip = string.format("/usr/share/%s/rules/proxy_ip", appname)
o = s:taboption("proxy_list", TextValue, "blacklist_ip", "", "<font color='red'>" .. translate("These had been joined ip addresses will use proxy.Please input the ip address or ip address segment,every line can input only one ip address.For example: 35.24.0.0/24 or 8.8.4.4.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return fs.readfile(proxy_ip) or "" end
o.write = function(self, section, value) fs.writefile(proxy_ip, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) fs.writefile(proxy_ip, "") end
o.validate = function(self, value)
    local ipmasks= {}
    string.gsub(value, '[^' .. "\r\n" .. ']+', function(w) table.insert(ipmasks, w) end)
    for index, ipmask in ipairs(ipmasks) do
        if not datatypes.ipmask4(ipmask) then
            return nil, ipmask .. " " .. translate("Not valid IP format, please re-enter!")
        end
    end
    return value
end

return m
