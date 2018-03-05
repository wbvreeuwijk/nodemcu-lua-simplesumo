dofile("config.lua")
print("Init Servos")
_motion = require("motion_control")
_motion.init(SERVO_LEFT_PIN,SERVO_RIGHT_PIN)

print("Init Sensors")
_sensor = require("sensors")
_sensor.init()

print("Init Sumo control")
_sumo = require("sumo_control")
_sumo.init(_motion, _sensor)

_sumo.start()