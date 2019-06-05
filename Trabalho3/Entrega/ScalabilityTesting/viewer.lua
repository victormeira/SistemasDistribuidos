local mqtt = require("mqtt_library")

totalPerMinutePerThread = {}
totalPerMinute = 0

startTime = 0
endTime = 0
interval = 60

function tableHasKey(table,key)
    return table[key] ~= nil
end

function mqttCallback(topic, message)

  totalPerMinute = totalPerMinute + 1

  for k,v in ipairs(totalPerMinutePerThread) do
    if(v.thread == message) then
      v.totalMessages = v.totalMessages + 1
      return
    end
  end

  local totalObj = {}
  totalObj.totalMessages = 1
  totalObj.thread = message

  table.insert(totalPerMinutePerThread, totalObj)
end

mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttCallback)
mqtt_client:connect("viewer1420626")
mqtt_client:subscribe({"test1420626"})

totalMinutes = 0
averagePerMinute = 1

shown = false
while true do
   mqtt_client:handler()

    if(os.time() % interval == 0) then
      if not shown then
        shown = true
        print("Total received in minute: " .. totalPerMinute)

        for k,v in ipairs(totalPerMinutePerThread) do
            print("Received " .. v.totalMessages .. " messages from " .. v.thread)
            v.totalMessages = 0
        end

        totalMinutes = totalMinutes + 1
        averagePerMinute = (averagePerMinute*(totalMinutes-1) + totalPerMinute)/totalMinutes
        totalPerMinute = 0

        if totalMinutes == 5 then
          -- Opens a file in append mode
          file = io.open("results.txt", "a")
          io.output(file)
          io.write("viewer-" .. #totalPerMinutePerThread .. "-" .. averagePerMinute/#totalPerMinutePerThread .. "\n")
          io.close(file)
          break
        end

      end
    else
      shown = false
    end
end

print ("Finished with an average of: " .. averagePerMinute)
