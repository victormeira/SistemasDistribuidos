function loadNewCoinLocation (i)
      local platformIndex = love.math.random(1,6)
      
      local platformX = objects.platforms[platformIndex].body:getX()
      local platformY = objects.platforms[platformIndex].body:getY()
      local platformW = objects.platforms[platformIndex].w
      local platformH = objects.platforms[platformIndex].h
      
      local xCoin = -1
      
      while xCoin < 20 or xCoin > 620 do
        xCoin = love.math.random(platformX - platformW/2, platformX + platformW/2)
      end
      
      local yCoin = platformY - platformH/2 - 15
      local rCoin = love.math.random(2,10)
      
      print(platformX .. " " .. platformY .. " " .. platformW .. " " .. platformH .. " " .. xCoin.. " " .. yCoin)
      
      objects.coins[i] = {}
      objects.coins[i].body = love.physics.newBody(world, xCoin, yCoin, "static")
      objects.coins[i].shape = love.physics.newCircleShape(rCoin)
      objects.coins[i].fixture = love.physics.newFixture(objects.coins[i].body, objects.coins[i].shape)
      objects.coins[i].fixture:setUserData("coin")
      objects.coins[i].fixture:setGroupIndex(i)
end

function beginContact(a, b, coll)
  print(a:getUserData(), b:getUserData())
  if a:getUserData() == "player" and b:getUserData() == "coin" then
    objects.player.score = objects.player.score + 100*b:getShape():getRadius()
    loadNewCoinLocation(b:getGroupIndex(i))
  end
  print(objects.player.score)
end

function love.keypressed(key)   
   if key == "escape" then
      love.event.quit()
    elseif key == "up" and math.abs(velY) < 150 then
        initImpulse = objects.player.body:getMass()*400
        objects.player.body:applyLinearImpulse(0,-initImpulse)
   end
end

function love.load()

  print("test")

  love.math.setRandomSeed(love.timer.getTime())
  love.physics.setMeter(20) 
  world = love.physics.newWorld(0, 640, false)
  world:setCallbacks(beginContact)
 
  objects = {} -- table to hold all our physical objects
 
  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 650/2, 650-25/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(650, 25) --make a rectangle with a width of 650 and a height of 50
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body
 
  --let's create a player
  objects.player = {}
  objects.player.body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  objects.player.shape = love.physics.newRectangleShape(10, 25) --the player's shape has a radius of 20
  objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 1) -- Attach fixture to body and give it a density of 1.
  objects.player.fixture:setUserData("player")
  objects.player.score = 0

  --objects.player.fixture:setRestitution(0.9) --let the player bounce
    
    objects.platforms = {}
    love.math.setRandomSeed(love.timer.getTime())

    for i=1, 6 do
        local w     = love.math.random(160,500)
        local h     = love.math.random(15,20)
        local xPos  = love.math.random(0, 650)
        local yPos  = love.math.random(60,80) + (100)*(i)
        objects.platforms[i] = {}
        objects.platforms[i].w = w
        objects.platforms[i].h = h
        objects.platforms[i].body = love.physics.newBody(world, xPos, yPos)  --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
        objects.platforms[i].shape = love.physics.newRectangleShape(w, h) --make a rectangle with a width of 650 and a height of 50
        objects.platforms[i].fixture = love.physics.newFixture(objects.platforms[i].body, objects.platforms[i].shape); --attach shape to body
    end

  --spawning coins
  objects.coins = {}
  
  for i=1, 5 do
      loadNewCoinLocation(i)
  end


  --initial graphics setup
  love.graphics.setBackgroundColor(242/255, 239/255, 233/255) --set the background color to a nice blue
  
  --block colors 86, 78, 88
  --player color 164, 110, 115
  --opponents colors 224, 200, 212
  
  love.window.setMode(650, 650) --set the window dimensions to 650 by 650
  love.window.setTitle("Jumping Rectangles")
  
end
 
 
function love.update(dt)
  world:update(dt) --this puts the world into motion
 
 
    posX = objects.player.body:getX() 
    velX, velY = objects.player.body:getLinearVelocity()
    objects.player.body:setAngle(0) -- avoid object rotation
  --here we are going to create some keyboard events
  if love.keyboard.isDown("right") then --press the right arrow key to push the player to the right
    posX = posX + 200*dt
  
    -- borders to the window
    if (posX > 650 - 5) then
        posX = 650 - 5
    end
        
    objects.player.body:setX(posX)
  elseif love.keyboard.isDown("left") then --press the left arrow key to push the player to the left
    posX = posX - 200*dt
    
        -- borders to the window
    if (posX < 5) then
        posX = 5
    end
        
    objects.player.body:setX(posX)
    --we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
  end
end
 
function love.draw()
  love.graphics.setColor(63/255, 57/255, 65/255) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
 
  love.graphics.setColor(164/255, 110/255, 115/255) --set the drawing color to red for the player
  love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))
  
  for k, v in ipairs(objects.platforms) do
    love.graphics.setColor(86/255, 78/255, 88/255) --set the drawing color to red for the player
    love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
  end
  
  for k, v in ipairs(objects.coins) do
      love.graphics.setColor(250/255, 166/255, 19/255)
     --set the drawing color to red for the player
    love.graphics.circle("fill", v.body:getX(),v.body:getY(), v.shape:getRadius() )
  end
  
  love.graphics.setColor(153/255, 147/255, 178/255)
  love.graphics.polygon("fill", 20, 20, 20, 150, 120, 150, 120, 20)
  
  love.graphics.setColor(166/255, 66/255, 83/255)
  love.graphics.print(objects.player.score, 30, 30, 1.2, 1.2)

  love.graphics.setColor(229/255, 242/255, 243/255)
  love.graphics.print("Player 1", 90, 30, 1.2, 1.2)
  
end