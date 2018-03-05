mcp = require("mcp23017")
mcp.init(SDA_PIN,SCL_PIN)

mcp_setup = {
    ["IODIR"] = 0x1f,
    ["IPOL"] = 0x03,
    ["GPPU"] = 0x03,
    ["DEFVAL"] = 0x00,
    ["INTCON"] = 0x00,
    ["GPINTEN"] = 0x00
}

for r, v in pairs(mcp_setup) do
    mcp.writeA(r,v)
end
mcp.readA("INTCAP")

num=7
function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=num%2
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end

do
  -- use pin 1 as the input pulse width counter
  gpio.mode(INTERRUPT_PIN,gpio.INPUT)
  local int_tmr = tmr.create()
  local prev_value = 0
  int_tmr:alarm(100, tmr.ALARM_AUTO, function()
    local b = mcp.readA("GPIO")
    if b ~= prev_value then
        print(b.."="..table.concat(toBits(b)))
        prev_value = b
    end
  end) 
  mcp.writeA("GPINTEN",0x1f)
end
