local Player = {}

function Player:Init()

    self.x, self.y = 500, 500
    self.dx, self.dy = 0, 0
    self.CollisionSize = 7
    self.MaxSpeed = 25
    self.MinSpeed = 13
    self.speed = self.MinSpeed
    self.angle = 0
    self.IsAlive = true

    self.MaxHealth = Data.PlayerStats.PlayetHealth
    self.Health = self.MaxHealth

    self.MaxBooster = Data.PlayerStats.PlayerBoost
    self.booster = self.MaxBooster
    self.MaxBoosterRegenTime = 5 
    self.BoosterRegenTimer = self.MaxBoosterRegenTime

    self.IsMoving = false

    self.SpriteSheet = love.graphics.newImage('assets/Player/PlayerSpriteSheet.png')
    self.FrameWidth, self.FrameHeight = 32, 32
    self.ImageGrid = Anim8.newGrid(self.FrameWidth, self.FrameHeight, self.SpriteSheet:getWidth(), self.SpriteSheet:getHeight())

    self.AnimationIdle = Anim8.newAnimation(self.ImageGrid(1,1), 0.1)
    self.AnimationMove = Anim8.newAnimation(self.ImageGrid(2,'1-3'), 0.1)
    self.AnimationBoost = Anim8.newAnimation(self.ImageGrid(3,'1-3'), 0.1)

    self.CurrentAnimation = self.AnimationIdle

    self.bullets = {}
    self.BulletMaxLifeTime = 1
    self.BulletSpeed = 20
    self.BulletDamage = Data.PlayerStats.BulletDamage
    self.BulletImage = love.graphics.newImage('assets/Player/PlayerBullets.png')
    bullet = {}
    
    self.BulletsParticles = {}
    self.BulletParticleMaxLifeTime = 50
    BulletParticle = {}

    function Player:Draw()
        if self.IsAlive then
            local mouseX, mouseY = love.mouse.getPosition()
            mouseX, mouseY = camera:worldCoords(mouseX, mouseY)
            self.angle = math.atan2(mouseY - self.y, mouseX - self.x)

            -- Draw Player
            self.CurrentAnimation:draw(self.SpriteSheet, self.x, self.y, self.angle, 1, 1, self.FrameWidth / 2 , self.FrameHeight / 2 + 0.5)

            -- Draw Bullets
            for i, bullet in ipairs(self.bullets) do
                love.graphics.draw(self.BulletImage, bullet.x - self.BulletImage:getWidth() /2, bullet.y - self.BulletImage:getHeight() /2)
            end
            for i, BulletParticle in ipairs(self.BulletsParticles) do
                love.graphics.setColor(love.math.colorFromBytes(255, 255, 255,  BulletParticle.opacity))
                love.graphics.draw(self.BulletImage, BulletParticle.x - self.BulletImage:getWidth() /2, BulletParticle.y - self.BulletImage:getHeight() /2, BulletParticle.angle, BulletParticle.radius/5, BulletParticle.radius/5)
            end
        end
    end

    function Player:Update(dt)
        if self.IsAlive then
            Player:PlayerController(dt)
            self.CurrentAnimation:update(dt)

            -- Calculate the current speed of the player using the Pythagorean theorem
            local speed = math.sqrt(self.dx * self.dx + self.dy * self.dy)
            
            -- If the current speed is greater than the maximum speed, scale down the velocity vector
            if speed > self.speed then
                local scale = self.speed / speed
                self.dx = self.dx * scale
                self.dy = self.dy * scale
            end
            
            -- Apply movement
            self.x = self.x + self.dx * self.speed * dt
            self.y = self.y + self.dy * self.speed * dt

            -- Stop the player if they are moving very slowly and check if player is moving
            if math.abs(self.dx) < 0.5 then
                self.dx = 0
                self.IsMoving = false
                self.CurrentAnimation = self.AnimationIdle

                -- Prevent the speed when player boost stopped
                if self.speed == self.MaxSpeed then
                    if self.speed > self.MinSpeed then
                        self.speed = self.speed - 1
                    end
                end
                
                -- Data.Audio.SpaceShipThrust:stop()
            end
            if math.abs(self.dy) < 0.5 then
                self.dy = 0
                self.IsMoving = false
                self.CurrentAnimation = self.AnimationIdle
                -- Prevent the speed when player boost stopped
                if self.speed == self.MaxSpeed then
                    if self.speed > self.MinSpeed then
                        self.speed = self.speed - 1                
                    end
                end

            end
            if self.dx ~= 0 or self.dy ~= 0 then
                self.IsMoving = true
                self.CurrentAnimation = self.AnimationMove
                if self.speed > self.MinSpeed then
                    self.CurrentAnimation = self.AnimationBoost                
                end

                Data.Audio.SpaceShipThrust:play()
                Data.Audio.SpaceShipThrust:setLooping(true)
            else
                Data.Audio.SpaceShipThrust:stop()
            end

            -- Booster Regen
            if self.booster < self.MaxBooster  then
                self.BoosterRegenTimer = self.BoosterRegenTimer - dt
                
                if self.BoosterRegenTimer <= 0  then
                    self.booster = self.booster + 0.5
                    if self.booster == self.MaxBooster then
                        self.BoosterRegenTimer = self.MaxBoosterRegenTime
                    end
                end
            end

            -- Player Fire Bullets
            function love.mousepressed(x, y, button)
                if button == 1 then
                end
            end
            
            for i, bullet in ipairs(self.bullets) do
                bullet.x = bullet.x + math.cos(bullet.angle) * bullet.speed
                bullet.y = bullet.y + math.sin(bullet.angle) * bullet.speed
                bullet.lifetime = bullet.lifetime + dt

                if bullet.lifetime > self.BulletMaxLifeTime then
                    table.remove(self.bullets, i)
                end
            end

            -- HealthDamage
            for i, asteroid in ipairs(Asteroids.asteroids) do
                local pushbackX, pushbackY = self.x - asteroid.x, self.y - asteroid.y
                local pushbackDist = math.sqrt(pushbackX^2 + pushbackY^2)
                if Gameplay:CirclesCollide(asteroid.x ,asteroid.y, asteroid.size, self.x, self.y, self.CollisionSize) then
                    self.Health = self.Health - 1
                    local pushbackVelX, pushbackVelY = pushbackX / pushbackDist * self.speed, pushbackY / pushbackDist * self.speed
                    self.dx = self.dx + pushbackVelX * 5
                    self.dy = self.dy + pushbackVelY * 5
                end
            end

            if self.Health <= 0 then
                self.IsAlive = false
            end
        end
        
    end

    function Player:PlayerController(dt)
        if love.keyboard.isDown(Data.GamepadKeysMapping.controls.up) then
            self.dy = self.dy - 1
        elseif love.keyboard.isDown(Data.GamepadKeysMapping.controls.down) then
            self.dy = self.dy + 1
        end
        if love.keyboard.isDown(Data.GamepadKeysMapping.controls.left) then
            self.dx = self.dx - 1
        elseif love.keyboard.isDown(Data.GamepadKeysMapping.controls.right) then
            self.dx = self.dx + 1
        end

        -- Decelerate the player if they are not pressing any movement keys
        if not love.keyboard.isDown(Data.GamepadKeysMapping.groups.move) then
            self.dx = self.dx * 0.9
            self.dy = self.dy * 0.9
        end

        -- Player Booster
        if love.keyboard.isDown(Data.GamepadKeysMapping.controls.boost) and self.booster > 0 and 
        self.IsMoving then
            self.speed = 25
            self.CurrentAnimation = self.AnimationBoost

            self.booster = self.booster - 1
            self.BoosterRegenTimer = self.MaxBoosterRegenTime

            Data.Audio.SpaceShipThrust:setPitch(2)
        else
            if self.speed > self.MinSpeed then
                self.speed = self.speed - 1                
            end

            if self.booster < 0 then
                self.booster = 0
            end
            self.CurrentAnimation = self.AnimationMove
            Data.Audio.SpaceShipThrust:setPitch(1)
        end
    end

    function Player:SpawnBullet()
        bullet = {
            x = self.x,
            y = self.y,
            speed = self.BulletSpeed,
            angle = self.angle,
            radius = 2,
            lifetime = 0,
            sound = Data.Audio.LaserShoot
        }
        table.insert(self.bullets, bullet)
        bullet.sound:stop()
        bullet.sound:setVolume(0.3)
        bullet.sound:play()

        return bullet
    end

    function Player:SpawnBulletParticles(bullet)
        BulletParticle = {
            x = bullet.x + math.random(3, 6),
            y = bullet.y + math.random(3, 6),
            speed = math.random(3, 6),
            angle = math.random(0, 360),
            radius = math.random(0.5, 1),
            lifetime = 0,
            opacity = 255,
        }
        table.insert(self.BulletsParticles, BulletParticle)

        return BulletParticle
    end

    function Player:DrawCollision()
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle('line', Player.x, Player.y, Player.CollisionSize)
        for i, bullet in ipairs(self.bullets) do
            love.graphics.circle('line', bullet.x, bullet.y, bullet.radius)
        end
        for i, BulletParticle in ipairs(self.BulletsParticles) do
          love.graphics.circle('line', BulletParticle.x, BulletParticle.y, BulletParticle.radius)
        end
    end
end


return Player
