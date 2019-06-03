local mqtt = require("mqtt_library")
local socket = require("socket")

totalPerMinute = 0
interval = 5

mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
mqtt_client:connect(arg[1].."1420626")


shown = false
while true do
   mqtt_client:handler()
   mqtt_client:publish("test1420626", arg[1])
   
   socket.sleep(arg[2])
   totalPerMinute = totalPerMinute + 1
   

    if(os.time() % interval == 0 ) then
      
      if(not shown) then
        shown = true
        startTime = os.time()
        print("Total sent in minute" .. totalPerMinute .. "from thread " .. arg[1])
        totalPerMinute = 0
      end
    else
      shown = false
    end
    
end
