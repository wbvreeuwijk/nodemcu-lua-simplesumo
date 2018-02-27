local M = {}

local MCP23017_ADDRESS = 0x20
local _callback = {}
local _tmr

function _write(bankAddr, reg_val)
  i2c.start(0)
  i2c.address(0, MCP23017_ADDRESS, i2c.TRANSMITTER)    
  i2c.write(0, bankAddr)
  if(reg_val >= 0) then
    i2c.write(0, reg_val)
  end
  i2c.stop(0)
end

function _read(bankAddr)
  _write(bankAddr,-1)
  i2c.start(0)
  i2c.address(0, MCP23017_ADDRESS,i2c.RECEIVER)
  local val=string.byte(i2c.read(0,1))
  i2c.stop(0)
  return val
end


function M.init(sda,scl)
    local sda_pin, scl_pin = sda or 5, scl or 6
    _tmr = tmr.create()

    i2c.setup(0, sda_pin, scl_pin, i2c.SLOW)

    -- Set Input state
    _write(0x00,0x1f) -- Set pin 1-5 to input
    _write(0x02,0x03) -- Reverse polarity on switches
    _write(0x0c,0x03) -- Set Pull-Up on switches

    -- Set Interrup Handling
    _write(0x04,0x03) -- Enable Interrupt on pin 1-5
    _write(0x06,0x00) -- Default value for pins
    _write(0x08,0x00) -- Set Interrup behaviour
    _read(0x0e)
    _read(0x10)
end

function M.trig(pin,callback)
    _callback[pin] = callback
end

function M.start()
    local prev_state = 0
    _tmr:alarm(100, tmr.ALARM_AUTO, function()
        local s = _read(0x12) -- Read state
        if(not(s == prev_state)) then
            for k, v in pairs(_callback) do
                if s % (k + k) >= k then
                    v()
                end
            end
            prev_state=s
        end
    end)
end

function M.stop()
    _tmr:stop()
end

return M
