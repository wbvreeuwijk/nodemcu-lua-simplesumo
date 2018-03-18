local M = {}

local MCP23017_ADDRESS = 0x20

function M.write(bankAddr, reg_val)
  i2c.start(0)
  i2c.address(0, MCP23017_ADDRESS, i2c.TRANSMITTER)    
  i2c.write(0, bankAddr)
  if(reg_val >= 0) then
    i2c.write(0, reg_val)
  end
  i2c.stop(0)
end

function M.read(bankAddr)
  M.write(bankAddr,-1)
  i2c.start(0)
  i2c.address(0, MCP23017_ADDRESS,i2c.RECEIVER)
  local val=string.byte(i2c.read(0,1))
  i2c.stop(0)
  return val
end

function M.init(sda,scl)
    local sda_pin, scl_pin = sda or 5, scl or 6

    i2c.setup(0, sda_pin, scl_pin, i2c.SLOW)
end

return M