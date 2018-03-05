local M = {}

local _client
local _sumo

function M.init()
    print("Init Servos")
    _motion = require("motion_control")
    _motion.init(SERVO_LEFT_PIN,SERVO_RIGHT_PIN)

    print("Init Sensors")
    _sensor = require("sensors")
    _sensor.init(SDA_PIN, SCL_PIN)

    print("Init Sumo control")
    _sumo = require("sumo_control")
    _sumo.init(_motion, _sensor)

    print("Init mqtt")
    _client = mqtt.Client("ID"..chipid, 120)
    _client:lwt("/lwt", "offline", 0, 0)
    _client:on("offline", function(client) 
        --node.restart() 
        print("Queue offline, restarting")
    end)

    _client:lwt("/lwt", "offline", 0, 0)
   
    _client:on("offline", function(client) print ("offline") end)

    print("Register callback")
    -- on publish message receive event
    _client:on("message", function(client, topic, data) 
        print(topic .. ":" .. " msg=" .. data) 
        if topic == MOTION_TOPIC then 
            _motion.move(data)
        else 
            if topic == ACTION_TOPIC then 
                if data == "start" then
                    _sumo.start()
                else if data == "stop" then
                        _sumo.stop()
                else _sumo.set_state(data)
                end end
            end 
        end          
    end)   
end

function M.start(mqtt_ip)
    print("Trying to connect to "..mqtt_ip)
    _client:connect(mqtt_ip, 1883, 0,
        function(client)
            print("Connected")
            tmr.create():alarm(1000,tmr.ALARM_SINGLE,function()
                client:subscribe(MOTION_TOPIC, 0,  
                    function(client)   
                        print("subscribed to:"..MOTION_TOPIC)
                    end)
            end)
            tmr.create():alarm(2000,tmr.ALARM_SINGLE,function()
                client:subscribe(ACTION_TOPIC, 0,  
                    function(client)   
                        print("subscribed to:"..ACTION_TOPIC)
                    end)
             end)
             _sumo.register_mqtt(client)
         end,
         function(client, reason)
             print("failed reason: " .. reason)
         end)
end

return M


