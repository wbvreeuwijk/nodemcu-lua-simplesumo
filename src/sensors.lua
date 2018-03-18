local M = {}

local _mcp = require("mcp23017")
local _tmr_mcp
local _tmr_hcsr
local _sensor_callback
local _echo_callback
local _start = 0
local _publish
--local mcp_setup = {
--    ["IODIR"] = 0x1f,
--    ["IPOL"] = 0x03,
--   ["GPPU"] = 0x03,
--    ["DEFVAL"] = 0x00,
--    ["INTCON"] = 0x00,
--    ["GPINTEN"] = 0x00
--}
--local _addr_table = {
--    ["IODIR"]   = 0x00,
--    ["IPOL"]    = 0x02,
--    ["GPINTEN"] = 0x04,
--    ["DEFVAL"]  = 0x06,
--    ["INTCON"]  = 0x08,
--    ["IOCON"]   = 0x0A,
--    ["GPPU"]    = 0x0C,
--    ["INTF"]    = 0x0E,
--    ["INTCAP"]  = 0x10,
--    ["GPIO"]    = 0x12,
--    ["OLAT"]    = 0x14
--}

function M.init()
    -- Setup MCP23017
    _DEBUG("Init sensor hardware")
    _mcp.init(SDA_PIN,SCL_PIN)
    _mcp.write(0x00,0x1f) -- set pin 1-5 to input
    _mcp.write(0x02,0x03) -- reverse pin 1 and 2
    _mcp.write(0x06,0x00) -- default value
    _mcp.write(0x08,0x00) -- Interrupt control
    _mcp.write(0x04,0x00) -- Interrupt enable
    _mcp.read(0x10)
    _tmr_mcp = tmr.create()
    gpio.mode(INTERRUPT_PIN,gpio.INPUT)

    -- Setup HC-SR04
    gpio.mode(TRIG_PIN, gpio.OUTPUT)
    gpio.mode(ECHO_PIN, gpio.INT)
    gpio.trig(ECHO_PIN, "down", _measure)
    _tmr_hcsr = tmr.create()
end

function M.register_sensor(callback)
    -- Register callback for IR and switches
    _sensor_callback = callback
end

function M.register_echo(callback)
    -- Register callback for IR and switches
    _echo_callback = callback
end

function _measure(level, pulse)
     local d = (pulse - _start - 1072)/58
     if _publish then _publish({module="sensor",distance=d}) end
     if _echo_callback then _echo_callback(d) end
end

function M.start()
    _DEBUG("Start loop")
    local prev_state = 0
    _publish({module="sensor",detected=0})
    _tmr_mcp:alarm(100, tmr.ALARM_AUTO, function()
        local b = _mcp.read(0x12)
        if b ~= prev_state then
            _publish({module="sensor",detected=s})
            if callback then callback(b) end
            prev_state = b
        end
   end) 
   _tmr_hcsr:alarm(1000, tmr.ALARM_AUTO, function()
        _start = tmr.now()
        gpio.write(TRIG_PIN, gpio.HIGH)
        -- tmr.delay(10)
        gpio.write(TRIG_PIN, gpio.LOW)
   end)
end

function M.stop()
    if _tmr_mcp  then _tmr_mcp:stop()  end
    if _tmr_hcsr then _tmr_hcsr:stop() end
end

function M.register_mqtt(f)
    _publish = f
    _publish({module="sensor",state="registered"})
end

return M
