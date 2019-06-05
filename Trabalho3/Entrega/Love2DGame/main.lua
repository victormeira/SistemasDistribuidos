local mqtt = require("mqtt_library")

function splitString(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function mqttCallback(topic, message)

  print(topic .."-".. message)

  -- acknoledge new player
  if topic == "ack1420626" and message ~= objects.player.name then

    -- checks if we already have acknoledged the player
    for k,v in ipairs(objects.enemies) do
      if(message == v.name) then
        return
      end
    end

    mqtt_client:publish("ack1420626", objects.player.name)
    loadNewEnemy(message)

    -- update score
  elseif topic == "score1420626" then
    local tokens = splitString(message, ",")
    local pName = tokens[1]
    local pScore = tokens[2]
    print(pName)
    print(pScore)
    if pName == objects.player.name then
      objects.player.score = pScore
    else
      for k,v in ipairs(objects.enemies) do
        if(pName == v.name) then
          v.score = pScore
          print("im here")
        end
      end
    end

    -- start game for everyone
  elseif topic == "start1420626" then

    if not worldBuilt then
      loadRandomObjs(message)
    end

    startGame()

  -- load new coins
  elseif topic == "coin1420626" then
    loadNewCoinLocation(tonumber(message))

  -- load new positions
  elseif topic == "position1420626" then
    local tokens = splitString(message, ",")
    local pName = tokens[1]
    local pX = tonumber(tokens[2])
    local pY = tonumber(tokens[3])
    print(pName)
    print(pScore)
    if pName == objects.player.name then
      --objects.player.body:setX(pX)
      --objects.player.body:setY(pY)
    else
      for k,v in ipairs(objects.enemies) do
        if(pName == v.name) then
          v.x = pX
          v.y = pY
        end
      end
    end

  end

end

function loadRandomObjs (seed)
  objects.platforms = {}
  love.math.setRandomSeed(seed)

  for i=1, 5 do
    local w     = love.math.random(160,500)
    local h     = love.math.random(15,20)
    local xPos  = love.math.random(0, 650)
    local yPos  = love.math.random(60,80) + (100)*(i)
    objects.platforms[i] = {}
    objects.platforms[i].w = w
    objects.platforms[i].h = h
    objects.platforms[i].body = love.physics.newBody(world, xPos, yPos)
    objects.platforms[i].shape = love.physics.newRectangleShape(w, h)
    objects.platforms[i].fixture = love.physics.newFixture(objects.platforms[i].body, objects.platforms[i].shape);
  end

  --spawning coins
  objects.coins = {}

  for i=1, 5 do
    loadNewCoinLocation(i)
  end

  worldBuilt = true

end

function startGame()
  if(gameState == "end") then
    reloadGame()
  end

  gameState = "playing"
  start = love.timer.getTime() -- start 30 sec timer
  missing = 30


end

function reloadGame()

  objects.player.score = 0

  --spawning coins
  objects.coins = {}

  for i=1, 5 do
    loadNewCoinLocation(i)
  end
end

function loadNewEnemy(name)
  local en = {}
  en.w = 10
  en.h = 10
  en.score = 0
  en.name = name
  en.x = 100
  en.y = 500

  table.insert(objects.enemies, en)
end

function loadNewCoinLocation (i)

  local platformIndex = love.math.random(1,5)

  local platformX = objects.platforms[platformIndex].body:getX()
  local platformY = objects.platforms[platformIndex].body:getY()
  local platformW = objects.platforms[platformIndex].w
  local platformH = objects.platforms[platformIndex].h

  local xCoin = -1

  while xCoin < 20 or xCoin > 620 do
    xCoin = love.math.random(platformX - platformW/2, platformX + platformW/2)
  end

  local yCoin = platformY - platformH/2 - 15
  local rCoin = love.math.random(3,10)

  objects.coins[i] = {}
  objects.coins[i].x = xCoin
  objects.coins[i].y = yCoin
  objects.coins[i].r = rCoin

end

function checkCoinCollision()
  local xp = objects.player.body:getX()
  local yp = objects.player.body:getY()
  local wp = 10
  local hp = 25

  for k,v in ipairs(objects.coins) do
    local xc = v.x
    local yc = v.y
    local rc = v.r

    if (xp + wp/2) > (xc - rc) and (xp - wp/2) < (xc + rc) and (yp + hp/2) > (yc - rc) and (yp - hp/2) < (yc + rc) then
      mqtt_client:publish("coin1420626", k)
      local publishedScore = objects.player.score + 100*v.r
      mqtt_client:publish("score1420626", objects.player.name .. "," .. publishedScore)
    end
  end
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "up" and math.abs(velY) < 150 then
    initImpulse = objects.player.body:getMass()*400
    objects.player.body:applyLinearImpulse(0,-initImpulse)
  end

  if gameState == "start" and key ~= "return" and not fixedName then
    objects.player.name = objects.player.name .. key
  end

  if gameState == "start" and key == "return" then
    fixedName = true
    mqtt_client:connect("victor" .. love.math.random(1,50000))
    print("CONNECTED")

    connected = true
    mqtt_client:subscribe({"ack1420626", "start1420626", "score1420626", "coin1420626", "position1420626"})
    print("SUBBED")

    mqtt_client:publish("ack1420626", objects.player.name)
    print("PUBLISHED")

  end

end

function love.load()

  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttCallback)

  gameState = "start"
  fixedName = false
  connected = false
  worldBuilt = false


  love.math.setRandomSeed(love.timer.getTime())
  love.physics.setMeter(20)
  world = love.physics.newWorld(0, 640, false)
  world:setCallbacks(beginContact)

  objects = {}

  objects.enemies = {}

  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 650/2, 650-25/2)
  objects.ground.shape = love.physics.newRectangleShape(650, 25)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape);

  --let's create a player
  objects.player = {}
  objects.player.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
  objects.player.shape = love.physics.newRectangleShape(10, 25)
  objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 1)
  objects.player.fixture:setUserData("player")
  objects.player.fixture:setCategory(1)
  objects.player.score = 0
  objects.player.name = ""


  --initial graphics setup
  love.graphics.setBackgroundColor(242/255, 239/255, 233/255)

  --block colors 86, 78, 88
  --player color 164, 110, 115
  --opponents colors 224, 200, 212

  love.window.setMode(650, 650)
  love.window.setTitle("Jumping Rectangles")

end


function love.update(dt)

  if connected then
    mqtt_client:handler()
  end


  if gameState == "start" or gameState == "end" then
    if(love.keyboard.isDown("space")) then
      mqtt_client:publish("start1420626", love.timer.getTime())

    end
  else

    if not worldBuilt then
      return
    end

    world:update(dt)
    checkCoinCollision()
    missing = 30 - (love.timer.getTime() - start)

    if(missing < 0) then
      gameState = "end"
    end

    posX = objects.player.body:getX()
    velX, velY = objects.player.body:getLinearVelocity()
    objects.player.body:setAngle(0) -- avoid object rotation
    --here we are going to create some keyboard events
    if love.keyboard.isDown("right") then
      posX = posX + 200*dt

      -- borders to the window
      if (posX > 650 - 5) then
        posX = 650 - 5
      end

      objects.player.body:setX(posX)

      mqtt_client:publish("position1420626", objects.player.name..","..posX..","..objects.player.body:getY())

    elseif love.keyboard.isDown("left") then
      posX = posX - 200*dt

      -- borders to the window
      if (posX < 5) then
        posX = 5
      end

      objects.player.body:setX(posX)

      mqtt_client:publish("position1420626", objects.player.name..","..posX..","..objects.player.body:getY())
    end
  end
end


function love.draw()


  if gameState == "start" or gameState == "end" then
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Press Space to Start", 300, 325)

    love.graphics.setColor(153/255, 147/255, 178/255)
    love.graphics.polygon("fill", 20, 20, 20, 150, 120, 150, 120, 20)

    love.graphics.setColor(166/255, 66/255, 83/255)
    love.graphics.print(objects.player.name, 23, 30)

    love.graphics.setColor(229/255, 242/255, 243/255)
    love.graphics.print(objects.player.score, 80, 30)

    for k,v in ipairs(objects.enemies) do
      love.graphics.setColor(166/255, 66/255, 83/255)
      love.graphics.print(v.name, 23, 30 + k*20)

      love.graphics.setColor(229/255, 242/255, 243/255)
      love.graphics.print(v.score, 80, 30 + k*20)
    end



    if gameState == "start" then
      love.graphics.setColor(166/255, 66/255, 83/255)
      love.graphics.print("Write Your Name. It will appear on the scoreboard.\n Press Enter to confirm and enter lobby.", 275, 375)
    end

  else
    --this puts the world into motion

    love.graphics.setColor(63/255, 57/255, 65/255)
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

    love.graphics.setColor(164/255, 110/255, 115/255)
    love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))

    for k, v in ipairs(objects.platforms) do
      love.graphics.setColor(86/255, 78/255, 88/255)
      love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
    end

    for k, v in ipairs(objects.coins) do
      love.graphics.setColor(250/255, 166/255, 19/255)
      love.graphics.circle("fill", v.x,v.y, v.r )
    end

    love.graphics.setColor(153/255, 147/255, 178/255)
    love.graphics.polygon("fill", 20, 20, 20, 150, 120, 150, 120, 20)

    love.graphics.setColor(166/255, 66/255, 83/255)
    love.graphics.print(objects.player.name, 23, 30)

    love.graphics.setColor(229/255, 242/255, 243/255)
    love.graphics.print(objects.player.score, 80, 30)

    love.graphics.setColor(166/255, 66/255, 83/255)
    love.graphics.print(math.floor(missing), 600 , 30)

    for k,v in ipairs(objects.enemies) do
      love.graphics.setColor(166/255, 66/255, 83/255)
      love.graphics.print(v.name, 23, 30 + k*20)

      love.graphics.setColor(229/255, 242/255, 243/255)
      love.graphics.print(v.score, 80, 30 + k*20)

      --opponents colors 224, 200, 212
      love.graphics.setColor(224/255, 200/255, 212/255)
      love.graphics.rectangle("fill", v.x-5, v.y-13, 10, 25)
    end
  end
end
