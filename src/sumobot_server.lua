local M = {}

local _client
local _sumo

function M.init()
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
        if topic == CONTROL_TOPIC then
             msg = sjson.decode(data)
             if     msg.action == "program" then behaviour = msg.payload
             elseif msg.action == "control" then _sumo.do_action(msg.payload)
             elseif msg.action == "start" then _sumo.start()
             elseif msg.action == "stop" then _sumo.stop()
             end
        end
    end)
end

function publish(m)
     local msg = sjson.encode(m)
     if _client then _client:publish(FEEDBACK_TOPIC,msg,0,0,
          function(client) print("sent") end)
     else
          print("No MQTT:"..msg)
     end
end

function M.start(mqtt_ip)
    print("Trying to connect to "..mqtt_ip)
    _client:connect(mqtt_ip, 1883, 0,
        function(client)
            print("Connected")
            tmr.create():alarm(1000,tmr.ALARM_SINGLE,function()
                client:subscribe(CONTROL_TOPIC, 0,
                    function(client)   
                        print("subscribed to:"..CONTROL_TOPIC)
                    end)
            end)
            _sumo.register_mqtt(publish)
         end,
         function(client, reason)
             print("failed reason: " .. reason)
         end)
end

return M


