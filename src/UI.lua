local UI = {}

function UI:Init()
    local PlayerStats = {}
    PlayerStats.health = 10

    PlayerStats.Booster = Player.booster
    PlayerStats.BoosterBarWidth = 300
    PlayerStats.BoosterBarHeight = 10
    PlayerStats.BoosterX = 5
    PlayerStats.BoosterY = love.graphics.getHeight() - PlayerStats.BoosterBarHeight - 5


    function UI:Draw()
        PlayerStats.Booster = Player.booster
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', PlayerStats.BoosterX - 2, PlayerStats.BoosterY - 2, PlayerStats.BoosterBarWidth + 4, PlayerStats.BoosterBarHeight + 4)
        love.graphics.reset()
        love.graphics.rectangle('fill', PlayerStats.BoosterX, PlayerStats.BoosterY, PlayerStats.BoosterBarWidth * (PlayerStats.Booster / 100), PlayerStats.BoosterBarHeight)
    end

    function UI:Update(dt)
        
    end

    function UI:DrawHealthBar(x, y, width, height, currentHealth, maxHealth, BarColor, FillColor)
        local healthPercentage = currentHealth / maxHealth
        local barWidth = width
        local barHeight = height
        local barFillWidth = barWidth * healthPercentage
      
        love.graphics.setColor(BarColor)
        love.graphics.rectangle("fill", x - barWidth /2, y, barWidth, barHeight) -- draw the outline of the bar
        love.graphics.setColor(FillColor)
        love.graphics.rectangle("fill", x - barWidth /2, y, barFillWidth, barHeight) -- draw the filled portion of the bar
        love.graphics.setColor(1, 1, 1)
    end
    
end

return UI