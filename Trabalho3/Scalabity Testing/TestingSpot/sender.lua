local mqtt = require("mqtt_library")
local socket = require("socket")

totalPerMinute = 0
interval = 60
totalMinutes = 0
averagePerMinute = 1

mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
mqtt_client:connect(arg[1].."1420626")


shown = false
while true do
   mqtt_client:handler()
   mqtt_client:publish("test1420626", arg[1] .. "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

   socket.sleep(arg[2])
   totalPerMinute = totalPerMinute + 1


    if(os.time() % interval == 0 ) then
      if(not shown) then
        shown = true
        startTime = os.time()
        print("Total sent in minute " .. totalPerMinute .. " from thread " .. arg[1])

        totalMinutes = totalMinutes + 1
        averagePerMinute = (averagePerMinute*(totalMinutes-1) + totalPerMinute)/totalMinutes
        totalPerMinute = 0

        if totalMinutes == 5 then
          -- Opens a file in append mode
          file = io.open("results.txt", "a")
          io.output(file)
          io.write(arg[1] .. "-" .. arg[2] .. "-" .. averagePerMinute .. "\n")
          io.close(file)
          break
        end

      end
    else
      shown = false
    end

end

print ("Finished with an average of: " .. averagePerMinute)
