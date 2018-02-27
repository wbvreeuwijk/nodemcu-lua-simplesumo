print("Sumobot v0.1")
node.setcpufreq(node.CPU160MHZ)
if(file.exists("config.lua")) then 
    dofile("config.lua") 
  
    -- FAIL SAFE
    gpio.mode(PIN_WIFI_RESET,gpio.INPUT,gpio.PULLUP)
    if(gpio.read(PIN_WIFI_RESET) == 1) then

        -- RESET WIFI CONFIGURATION
        gpio.mode(PIN_WIFI_RESET,gpio.INT,gpio.PULLUP)
        gpio.trig(PIN_WIFI_RESET, "down", function(level, when)
            print("Reset Wifi...")
            wifi.sta.clearconfig()
            tmr.delay(100)
            node.restart()
        end)

        -- CHECK REQUIRED MODULES
        print("Checking required modules")
        for i in pairs(DEPENDS) do
            if(not file.exists(DEPENDS[i]..".lc")) and
              (not file.exists(DEPENDS[i]..".lua")) then
                print("ERROR: Missing '"..DEPENDS[i].."'") 
                return
            end
        end
        print("Starting ...")
        
        for i in pairs(MODULES) do
            if(file.exists(MODULES[i])) then 
                print("Executing: '"..MODULES[i].."'")
                dofile(MODULES[i]) 
            end
        end

    else
        print("Bypassing init.lua")
    end
end

-- in you init.lua:
if adc.force_init_mode(adc.INIT_VDD33)
then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

