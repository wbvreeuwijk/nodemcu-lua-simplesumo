wifi.sta.autoconnect(1)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
    function(T)
        print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
            T.netmask.."\n\tGateway IP: "..T.gateway)
        print("Starting Time Sync")
        tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
            net.dns.resolve(NTP_HOST, function(sk, ip)
                if (ip == nil) then print("DNS fail!") 
                else           
                    sntp.sync(ip, function(sec,usec,server)
                         print('sync', sec, usec, server)
                    end,
                    function()
                       print('NTP Sync failed!')
                    end)
                end
            end)
        end)
        for i in pairs(MQTT_HOSTS) do
            if string.match(T.IP,MQTT_HOSTS[i].subnet) then
                print("Looking for MQTT server "..MQTT_HOSTS[i].server)
                net.dns.resolve(MQTT_HOSTS[i].server, function(sk, ip)
                    if (ip == nil) then print("DNS fail!") 
                    else 
                        server = require(SERVER)
                        print("Init Server")
                        server.init()
                        print("Starting Server")
                        server.start(ip)
                    end
                end)
             end
        end
    end)

tmr.create():alarm(10000, tmr.ALARM_SINGLE, 
    function()
        if wifi.sta.getip() == nil then
            print("We have no IP")
            enduser_setup.start(
                function()
                    print("Connected to wifi as:" .. wifi.sta.getip())
                end,
                function(err, str)
                    print("enduser_setup: Err #" .. err .. ": " .. str)
                end)
         else
            print("We got IP "..wifi.sta.getip())
         end
    end)