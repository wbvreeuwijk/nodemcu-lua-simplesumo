local M = {}

local _sensor, _motion, _state, _tmr, _publish, _prev_state

function _pursue(d)
    if d < 50 and _state == SEARCH then
        _state = PURSUE
        _motion.move(FAST,STRAIGHT)
    end
end

function do_moves(moves,end_state)
     if table.getn(moves) == 0 then
          _state = end_state
     else
          local m = table.remove(moves,1)
          local d = 0
          if type(m.duration) == "number" then
               d = m.duration
          else
               d = node.random(m.duration.min,m.duration.max)
          end
          local t = tmr.create()
          t:alarm(d, tmr.ALARM_SINGLE, function()
               do_moves(moves,end_state)
          end)
     end
end

function _react(sensor)
     if behaviour[sensor] then
          if behaviour[sensor].requires== _state or not behaviour[sensor].requires then
               _state = behaviour[sensor].state
               do_moves(behaviour[sensor].moves,behaviour[sensor].next_state)
          end
     end
end

function M.init(m, s)
    _DEBUG("Init Sumo")
    _motion = require("motion_control")
    _motion.init(SERVO_LEFT_PIN,SERVO_RIGHT_PIN)

    _sensor = require("sensors")
    _sensor.init(SDA_PIN, SCL_PIN)

    _state = STOPPED
    _sensor.register_sensor(_react)
    _sensor.register_echo(_pursue)
end

function M.start()
    _state = RUNNING
    _prev_state = STOPPED
    _sensor.start()
    _tmr = tmr.create()
    _tmr:alarm(100, tmr.ALARM_AUTO, function()
        if _state ~= _prev_state then
           _publish({module="control",state=_state})
           _prev_state = _state
        end
        if _state == SEARCH then
            if node.random(1,100) < 50 then
                _motion.move(FORWARD,RIGHT)
            else
                _motion.move(FORWARD,RIGHT)
            end
            tmr.create():alarm(50,tmr.ALARM_SINGLE, function()
                _motion.move(SLOW,STRAIGHT)
            end)
        end
    end)
end

function M.do_action(msg)
     if msg.action == "set_state" then _state = msg.state
     elseif msg.action == "react" then _react = msg.input
     end
end

function M.stop()
    _state = STOPPED
    if _tmr then
         _tmr:stop()
         _sensor.stop()
         _motion.stop()
    end
end

function M.register_mqtt(f)
    _publish = f
    _publish({module="control",state="registered"})
    _motion.register_mqtt(f)
    _sensor.register_mqtt(f)
end

return M
