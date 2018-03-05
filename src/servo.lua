local ServoClass = {}
ServoClass.__index = ServoClass

function ServoClass.new(_pin)
    local self = setmetatable({}, ServoClass)
    self.pin = _pin
    pwm.setup(_pin,333,502)
    return self
end

