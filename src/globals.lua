majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();

_DEBUG = function(s) if DEBUG then print("[DEBUG] "..s) end end

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

-- MOTIONS
FORWARD = 80
FAST = 180
SLOW = 30
BACKWARD=-60
STILL=0

LEFT=-65
RIGHT=65
STRAIGHT=0

-- STATES
STOPPED=0
SEARCH=1
STAY_IN_RING=2
PURSUE=3
ATTACK=4
RUNNING=5

-- NETWORK
NTP_HOST="pool.ntp.org"
MQTT_HOSTS={
    {subnet="192.168.100.",server="mqtt.reeuwijk.net"},
    {subnet="192.168.0.",server="192.168.0.124"},
    {subnet="192.168.42.",server="192.168.42.1"}
}

-- TOPICS
CONTROL_TOPIC="/sumo/control"
FEEDBACK_TOPIC="/sumo/feedback"

behaviour = {
     [LEFT_BUTTON]={
          state=ATTACK,
          requires=SEARCH,
          moves={
               [1]={speed=FAST,direction=STRAIGHT,duration=100},
               [2]={speed=FORWARD,direction=LEFT,duration=100}
          }
     },
     [RIGHT_BUTTON]={
          state=ATTACK,
          requires=SEARCH,
          moves={
               [1]={speed=FAST,direction=STRAIGHT,duration=100},
               [2]={speed=FORWARD,direction=RIGHT,duration=100}
          }
     },
     [RIGHT_BUTTON+RIGHT_BUTTON]={
          state=ATTACK,
          requires=SEARCH,
          moves={
               [1]={speed=FAST,direction=STRAIGHT,duration=100},
               [2]={speed=FORWARD,direction=RIGHT,duration=100}
          }
     },
     [LEFT_EDGE+RIGHT_EDGE]={
          state=STAY_IN_RING,
          moves={
               [1]={speed=BACKWARD,direction=STRAIGHT,duration={min=500,max=800}},
               [2]={speed=STILL,direction=RIGHT,duration={min=200,max=800}}
          },
          next_state=SEARCH
     },
     [LEFT_EDGE]={
          state=STAY_IN_RING,
          moves={
               [1]={speed=BACKWARD,direction=LEFT,duration={min=500,max=800}},
               [2]={speed=STILL,direction=RIGHT,duration={min=200,max=800}}
          },
          next_state=SEARCH
     },
     [RIGHT_EDGE]={
          state=STAY_IN_RING,
          moves={
               [1]={speed=BACKWARD,direction=RIGHT,duration={min=500,max=800}},
               [2]={speed=STILL,direction=LEFT,duration={min=200,max=800}}
          },
          next_state=SEARCH
     },
     [BACK_EDGE]={
          state=STAY_IN_RING,
          moves={
               [1]={speed=FORWARD,direction=STRAIGHT,duration=1000}
          },
          next_state=SEARCH
     }
}
