-- SERVER 
SERVER="sumobot_server"

-- REQUIRED MODULES
DEPENDS = {"motion_control",SERVER}
MODULES = {"globals.lua","wifi_setup.lua"} 

-- TEST SETTING (NO SERVO OUTPUT)
--DEBUG=1

-- Boot pins
PIN_WIFI_RESET=3

-- Control Pins
SERVO_LEFT_PIN=7
SERVO_RIGHT_PIN=8
SDA_PIN=5  -- Green 
SCL_PIN=6  -- Yellow
TRIG_PIN=0 -- Green
ECHO_PIN=1 -- Blue
INTERRUPT_PIN=2

-- SENSORS
LEFT_BUTTON=1
RIGHT_BUTTON=2
LEFT_EDGE=4
RIGHT_EDGE=8
BACK_EDGE=16

-- NETWORK
NTP_HOST="pool.ntp.org"
MQTT_HOSTS={
    {subnet="192.168.100.",server="mqtt.reeuwijk.net"},
    {subnet="192.168.0.",server="192.168.0.124"}
}

-- TOPICS
MOTION_TOPIC="/sumo/motion"
SENSOR_TOPIC="/sumo/sensor"
ACTION_TOPIC="/sumo/action"



