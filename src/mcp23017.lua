local M = {}

local MCP23017_ADDRESS = 0x20

local _addr_table = {
    ["IODIR"]   = 0x00,
    ["IPOL"]    = 0x02,
    ["GPINTEN"] = 0x04,
    ["DEFVAL"]  = 0x06,
    ["INTCON"]  = 0x08,
    ["IOCON"]   = 0x0A,
    ["GPPU"]    = 0x0C,
    ["INTF"]    = 0x0E,
    ["INTCAP"]  = 0x10,
    ["GPIO"]    = 0x12,
    ["OLAT"]    = 0x14
}

function M.writeA(s, val)
    _write(_addr_table[s], val)
end

function M.writeB(s, val)
    _write(_addr_table[s]+1, val)
end

function M.readA(s)
    return _read(_addr_table[s])
end

function M.readB(s)
    return _read(_addr_table[s]+1)
end

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

    i2c.setup(0, sda_pin, scl_pin, i2c.SLOW)
end

return M