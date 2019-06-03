local mqtt = require("mqtt_library")

totalPerMinutePerTopic = {}
totalPerMinute = 0

startTime = 0
endTime = 0
interval = 5

function tableHasKey(table,key)
    return table[key] ~= nil
end

function mqttCallback(topic, message)
    if(tableHasKey(totalPerMinutePerTopic, message)) then
        totalPerMinutePerTopic[message] = totalPerMinutePerTopic[message] + 1
    else
        totalPerMinutePerTopic[message] = 1
    end
end

mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
mqtt_client:connect("viewer1420626")
mqtt_client:subscribe({"test1420626"})

startTime = os.time()
while true do
   mqtt_client:handler() 
   endTime = os.time()
   
    if(os.difftime(endTime,startTime) > interval) then
        startTime = os.time()
        
        print("Total received in minute: " .. totalPerMinute)
        totalPerMinute = 0

        for k,v in ipairs(totalPerMinutePerTopic) do
            print("Received " .. v .. " messages from " .. k)
            totalPerMinutePerTopic[k] = 0
        end
        
    end
end