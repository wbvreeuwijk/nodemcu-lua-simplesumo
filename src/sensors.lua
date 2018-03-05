local M = {}

local _mcp = require("mcp23017")
local _tmr_mcp
local _tmr_hcsr
local _callback = {}
local _echo_callback
local _start = 0

local mcp_setup = {
    ["IODIR"] = 0x1f,
    ["IPOL"] = 0x03,
    ["GPPU"] = 0x03,
    ["DEFVAL"] = 0x00,
    ["INTCON"] = 0x00,
    ["GPINTEN"] = 0x00
}

function M.init()
    -- Setup MCP23017
    _DEBUG("Init sensor hardware")
    _mcp.init(SDA_PIN,SCL_PIN)
    for r, v in pairs(mcp_setup) do
        _mcp.writeA(r,v)
    end
    _mcp.readA("INTCAP")
    _tmr_mcp = tmr.create()
    gpio.mode(INTERRUPT_PIN,gpio.INPUT)

    -- Setup HC-SR04
    gpio.mode(TRIG_PIN, gpio.OUTPUT)
    gpio.mode(ECHO_PIN, gpio.INT)
    gpio.trig(ECHO_PIN, "down", _measure)
    _tmr_hcsr = tmr.create()
end

function M.register(mask,callback)
    -- Register callback for IR and switches
    _DEBUG("Register mask"..mask)
    _callback[mask] = callback
end

function M.register_echo(callback)
    -- Register callback for IR and switches
    _DEBUG("Register echo callback")
    _echo_callback = callback
end

function _measure(level, pulse)
    local d = (pulse - _start - 1072)/58
    _DEBUG("Distance:"..d)
    _echo_callback(d)
end

function M.start()
    _DEBUG("Start loop")
    local prev_state = 0
    _tmr_mcp:alarm(25, tmr.ALARM_AUTO, function()
        local b = _mcp.readA("GPIO")
        if b ~= prev_state then
            for mask, callback in pairs(_callback) do
                if bit.band(mask,b) ~= 0 then
                    callback(b)
                end
            end
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
    _DEBUG("Stop loop")
    _tmr_mcp:stop()
    _tmr_hcsr:stop()
end

return M
