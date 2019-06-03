local mqtt = require("mqtt_library")

totalPerMinute = 0
interval = 5

function mqttcb(topic, message)
   print("Received from topic: " .. topic .. " - message:" .. message)
end

mqtt_client = mqtt.client.create("test.mosquitto.org", 1882, mqttcb)
mqtt_client:connect("viewer1420626")
mqtt_client:subscribe({"test1420626"})

startTime = os.time()
while true do
   mqtt_client:handler()
   --mqtt_client:publish("viewer1420626", "1")
   --print("published")
   totalPerMinute = totalPerMinute + 1
   endTime = os.time()

    if(os.difftime(endTime,startTime) > interval) then
        startTime = os.time()
        print("Total sent in minute: " .. totalPerMinute)
        mqtt_client:publish("test1420626", "1")
        totalPerMinute = 0
    end
end
