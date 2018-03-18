local M = {}

local _servo_left, _servo_right, _publish

function M.init(pin_left,pin_right)
    _DEBUG("Init motion_control")
    _servo_left = pin_left
    _servo_right = pin_right
    pwm.setup(_servo_left,333,512)
    pwm.setup(_servo_right,333,512)
end

function _servo_write(pin,t)
    if not DEBUG then pwm.setduty(pin,t*3.41333+512) end
end

function M.start()
     pwm.start(_servo_left)
     pwm.start(_servo_right)
end

function M.stop()
     pwm.stop(_servo_left)
     pwm.stop(_servo_right)
     _publish({module="motion",move={speed=0,rotation=0}})
end

function M.move(s,r)
     _publish({module="motion",move={speed=s,rotation=r}})
    _servo_write(PIN_LEFT, s/2 + r / 2)
    _servo_write(PIN_RIGHT, -s/2 + r / 2)
end

function M.register_mqtt(f)
    _publish = f
    _publish({module="motion",state="registered"})
    _publish({module="motion",move={speed=0,rotation=0}})
end

return M
