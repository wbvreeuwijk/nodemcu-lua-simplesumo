local M = {}

local _sensor, _motion, _state, _tmr, _mqtt_client

function _publish(m)
    if _mqtt_client then
        _mqtt_client:publish(SENSOR_TOPIC,sjson.encode(m),0,0,
            function(client) print("sent") 
        end)
    end
end

function _attack(s)
    _publish({sensor=s})
    _state = "attack"
    _motion.move("forward.fast")
    tmr.create():alarm(100,tmr.ALARM_SINGLE, function()
        if bit.band(LEFT_BUTTON,s) ~= 0 then
            _motion.move("pivot.left")
        else
            _motion.move("pivot.right")
        end
    end)
end

function _stay(m1,m2) 
    _motion.move(m1)
    tmr.create():alarm(node.random(500,800), tmr.ALARM_SINGLE, function()
        _motion.move(m2)    
        tmr.create():alarm(node.random(200,800), tmr.ALARM_SINGLE, function()
            _state = "search"
        end)    
    end)
end

function _stay_in_ring(s)
    _publish({sensor=s})
    _state = "stay_in_ring"
    if bit.band(LEFT_EDGE+RIGHT_EDGE,s) == LEFT_EDGE+RIGHT_EDGE then
        _stay("backward","rotate.right")
    else if bit.band(LEFT_EDGE,s) ~= 0 then
        _stay("backward.left","rotate.right")    
    else if bit.band(RIGHT_EDGE,s) ~= 0 then
        _stay("backward.right","rotate.left")    
    end end end    
    if bit.band(BACK_EDGE,s) ~=0 then
        _motion.move("forward.fast")
        tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
            _state = "search"
        end)
    end
end

function _pursue(d)
    _publish({target=d})
    if d < 50 and _state == "search" then
        _state = "pursue"
        _motion.move("forward.fast")
    end
end
    

function M.init(m, s)
    _DEBUG("Init Sumo")
    _sensor = s
    _motion = m
    _state = "stopped"
    _sensor.register(LEFT_BUTTON+RIGHT_BUTTON,_attack)
    _sensor.register(LEFT_EDGE+RIGHT_EDGE+BACK_EDGE,_stay_in_ring)
    _sensor.register_echo(_pursue)
end

function M.start()
    _state = "running"
    _sensor.start()
    _tmr = tmr.create()
    _tmr:alarm(500, tmr.ALARM_AUTO, function()
        _DEBUG("state:".._state)
        _publish({state=_state})
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

function M.set_state(s)
    _state = s
end

function M.stop()
    _state = "stopped"
    _tmr:stop()
    _sensor.stop()
    _motion.move("sit.still")
end

function M.register_mqtt(c)
    _mqtt_client = c
end

return M
