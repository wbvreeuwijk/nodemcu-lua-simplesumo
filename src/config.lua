-- SERVER 
SERVER="sumobot_server"

-- REQUIRED MODULES
MODULES = {
     "globals.lua",
     "wifi_setup.lc"
}

DEPENDS = {
     "motion_control",
     "mcp23017",
     "sensors",
     "motion_control",
     SERVER
}

-- TEST SETTING (NO SERVO OUTPUT)
DEBUG=1

-- Boot pins
PIN_WIFI_RESET=3



