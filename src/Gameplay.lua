local Gameplay = {}
DebugMode = true
DrawCollision = false
PlaceAsteroid = false

-- Import Modules
Data = require('src/utils/Data')
Player = require('src/entities/Player')
Asteroids = require('src/entities/Asteroids')
UserInterface = require('src/UI')


-- Initialize Modules
Asteroids:Init()
Player:Init()
UserInterface:Init()

local CameraZoomLevel = 3
camera = Camera()

local InfiniteBoost = false

local Background = love.graphics.newImage('assets/bg.png')
local Planet = love.graphics.newImage('assets/PlanetBg.png')
local PlanetAngle = 0
local PlanetRotationSpeed = 0.01
local PlanetPosX, PlanetPosY = 2040/2, 980/2
local PlanetX, PlanetY =  PlanetPosX - Player.x * 0.3, PlanetPosY - Player.y * 0.3

local stars = {}
stars.x = love.math.random(0, love.graphics.getWidth())
stars.y = love.math.random(0, love.graphics.getHeight())

local StarSpawnTimer = 0
local MaxTimer = 0.01
local StarMaxLifetime = 20
local CursorImage = love.graphics.newImage('assets/cursor.png')
love.mouse.setVisible(false)

function Gameplay.Draw()
    love.graphics.draw(Background)
    for i, star in ipairs(stars) do
        love.graphics.rectangle('fill', star.x, star.y, star.w, star.h)
    end

    camera:attach()
    PlanetX, PlanetY =  PlanetPosX - Player.x * 0.3, PlanetPosY - Player.y * 0.3

    love.graphics.draw(Planet, PlanetX, PlanetY, PlanetAngle, 1, 1, Planet:getWidth()/2, Planet:getHeight()/2)
    love.graphics.setColor(255, 255, 255)

    Asteroids:Draw()
    Player:Draw()
    Gameplay:CollisionDraw()
    camera:detach()
    UserInterface:Draw()

    Gameplay:Debug()

    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.draw(CursorImage, mouseX - CursorImage:getWidth()/2, mouseY- CursorImage:getHeight()/2)
    
end

function Gameplay.Update(dt)
    camera = Camera(0, 0, CameraZoomLevel)
    camera:lookAt(Player.x, Player.y)

    PlanetAngle = PlanetAngle + PlanetRotationSpeed *dt

    Gameplay:SpawnStar(dt)
    Player:Update(dt)
    Asteroids:Update(dt)
    UserInterface:Update(dt)




    function love.keypressed(key)
        if key == 't' and not DebugMode then
            DebugMode = true
        elseif DebugMode and key == 't' then
            DebugMode = false
        end
        Gameplay:Debug(key)
    end

    function love.mousepressed(x, y, button)
        x, y = camera:worldCoords(x, y)

        Gameplay:Debug(nil, x, y, button)
        if button == 1 then
            Player:SpawnBullet()
        end
    end

    -- print(DebugMode)
end

function Gameplay:SpawnStar(dt)
    StarSpawnTimer = StarSpawnTimer + dt
    if StarSpawnTimer > MaxTimer then
        local x = love.math.random(0, 2040)
        local y = love.math.random(0, 980)
        local vx = love.math.random(-1, 3)
        local vy = love.math.random(-1, 3)
        local w = love.math.random(0.3, 1)
        local h = love.math.random(0.3, 1)
        table.insert(stars, {x = x, y = y, vx = vx, vy = vy, w = w, h = h, lifetime = 0})
        StarSpawnTimer = StarSpawnTimer - MaxTimer
    end
  
    for i, star in ipairs(stars) do
        star.x = star.x + star.vx * dt
        star.y = star.y + star.vy * dt
        star.lifetime = star.lifetime + dt
        if star.lifetime > StarMaxLifetime then
            table.remove(stars, i)
        end
    end
end

function Gameplay:CirclesCollide(c1_x, c1_y, c1_radius, c2_x, c2_y, c2_radius)
    local dx = c1_x - c2_x
    local dy = c1_y - c2_y
    local distance = math.sqrt(dx * dx + dy * dy)
  
    if distance < c1_radius + c2_radius then
      return true
    else
      return false
    end
end

-- Only Debug
function Gameplay:Debug(key, x, y, button)
    if DebugMode then
        love.graphics.print("Debug: "..tostring(DebugMode), 5, 10)
        love.graphics.print("zoom level: "..CameraZoomLevel, 5, 25)
        love.graphics.print("booster fuel: "..Player.booster, 5, 40)
        love.graphics.print("player speed: "..Player.speed, 5, 55)
        love.graphics.print("player dx: "..Player.dx, 5, 70)
        love.graphics.print("player dy: "..Player.dy, 5, 85)
        love.graphics.print("player isMoving: "..tostring(Player.IsMoving), 5, 100)
        love.graphics.print("player health: "..Player.Health, 5, 125)
        
        
        -- keyboard

        -- Zoom In/Out
        if key == '=' then
            CameraZoomLevel = CameraZoomLevel + 0.5
        elseif key == '-' then
            CameraZoomLevel = CameraZoomLevel - 0.5
        end

        -- Enable Collision Draw
        if key == 'v' and not DrawCollision then
            DrawCollision = true
        elseif key == 'v' and DrawCollision then
            DrawCollision = false
        end        
        
        -- Add Asteroid
        if key == 'r' and not PlaceAsteroid then
            PlaceAsteroid = true
        elseif key == 'r' and PlaceAsteroid then
            PlaceAsteroid = false
        end

        -- mouse
        if button == 1 and PlaceAsteroid then
            asteroid.x = x
            asteroid.y = y
            table.insert(Asteroids.asteroids, asteroid)
        end
        
        -- Infinite Boost
        local InfiniteBoostValue = 999999999999999
        local NormalBoostValue = 100
        if key == 'b' and not InfiniteBoost then
            Player.booster = InfiniteBoostValue
            InfiniteBoost = true
        elseif InfiniteBoost and key == 'b' then
            InfiniteBoost = false
            Player.booster = NormalBoostValue
        end
    end
end

function Gameplay:CollisionDraw()
    if DrawCollision then
            Player:DrawCollision()
            Asteroids:CollisionDraw()
    end
end

return Gameplay