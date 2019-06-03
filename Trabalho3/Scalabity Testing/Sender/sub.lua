local mqtt = require("mqtt_library")

function mqttCallback(topic, message)
  print(topic .. "-" .. message)
  mqtt_client:publish("ack1420626", "testsubj")
end

mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttCallback)
mqtt_client:connect("viewer1420626")
mqtt_client:subscribe({"ack1420626"})


while true do
   mqtt_client:handler() 
end