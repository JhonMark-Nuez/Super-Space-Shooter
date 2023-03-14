local timeStep = 1/60 -- 60 frames per second
local accumulator = 0

function love.load()
  love.graphics.setDefaultFilter('nearest','nearest')
  LoadLibraies = require('src/utils/LoadLib')
  LoadInputMapping = require('src/utils/InputMapping')

  SceneManager = require('src/utils/SceneManager')
  Gameplay = require('src/Gameplay')
end

function love.draw()
  SceneManager:DrawLoad(Gameplay.Draw)
end

function love.update(dt)

  accumulator = accumulator + dt
  
  if accumulator >= timeStep then
    SceneManager:UpdateLoad(Gameplay.Update, timeStep)
  end

end