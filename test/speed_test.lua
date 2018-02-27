node.setcpufreq(node.CPU160MHZ)
tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
  print("start speed test")
  gpio.mode(2,gpio.OUTPUT)
  gpio.mode(3,gpio.OUTPUT)
  gpio.write(2,1)
  for i=1,100 do
      gpio.write(3,1)
      gpio.write(3,0)
  end
  gpio.write(2,0)  
  print("end speed test")
end)

