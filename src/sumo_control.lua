local M = {}

local _sensor, _motion, _state, _tmr

function _attack_left()
    _state = "attack"
    _motion.move("forward.fast")
    tmr.create():alarm(100,tmr.ALARM_SINGLE, function()
        _motion.move("pivot.left")
    end)
end

function _attack_right()
    _state = "attack"
    _motion.move("forward.fast")
    tmr.create():alarm(100,tmr.ALARM_SINGLE, function()
        _motion.move("pivot.right")
    end)
end

function _back_left()
    _state = "stay_in_ring"
    _motion.move("backward.left")
    tmr.create():alarm(node.random(300,700), tmr.ALARM_SINGLE, function()
        _motion.move("rotate.right")    
        tmr.create():alarm(node.random(10,550), tmr.ALARM_SINGLE, function()
            _state = "search"
        end)    
    end)
end

function _back_right()
    _state = "stay_in_ring"
    _motion.move("backward.right")
    tmr.create():alarm(node.random(300,700), tmr.ALARM_SINGLE, function()
        _motion.move("rotate.left")    
        tmr.create():alarm(node.random(10,550), tmr.ALARM_SINGLE, function()
            _state = "search"
        end)    
    end)
end

function _forward()
    _state = "stay_in_ring"
    _motion.move("forward.fast")
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
        _state = "search"
    end)
end

function M.init(m, s)
    _sensor = s
    _motion = m
    _state = "stopped"
    _sensor.trig(LEFT_BUTTON,_attack_left)
    _sensor.trig(RIGHT_BUTTON,_attack_right)
    _sensor.trig(LEFT_EDGE,_back_left)
    _sensor.trig(RIGHT_EDGE,_back_right)
    _sensor.trig(BACK_EDGE,_forward)
end

function M.start()
    _state = "running"
    _sensor.start()
    _tmr = tmr.create()
    _tmr:alarm(500, tmr.ALARM_AUTO, function()
        print("State:".._state)
        if _state == "search" then
            if node.random(1,100) > 5 then
                if node.random(1,100) < 50 then                 
                    _motion.move("pivot.right")
                else
                    _motion.move("pivot.left")           
                end
                tmr.create():alarm(50,tmr.ALARM_SINGLE, function()
                    _motion.move("forward.slow")
                end)    
            else
                _motion.random()
            end
        end
    end)
end

function M.stop()
    _state = "stopped"
    _tmr:stop()
    _sensor.stop()
end

return M