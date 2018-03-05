local M = {}
local mcp_setup = {
    ["IODIR"] = 0x1f,
    ["IPOL"] = 0x03,
    ["GPPU"] = 0x03,
    ["DEFVAL"] = 0x00,
    ["INTCON"] = 0x00,
    ["GPINTEN"] = 0x00
}

for k,v in pairs(mcp_setup) do
    M.k = function(s) print(s..v) end
    print(k..v)
end

M.IODIR("test")