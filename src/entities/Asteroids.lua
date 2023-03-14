local Asteroids = {}

function Asteroids:Init()
    self.asteroids = {}
    asteroid = {}
    self.MaxLifeTime = 1000
    self.SpawnRate = 100 -- Number of asteroids to spawn per second
    self.MaxAsteroids = 45 -- Maximum number of asteroids that can exist at once
    self.TimeSinceLastSpawn = 0
    self.AsteroidsSpawned = 0 -- Current number of asteroids in the game
    
    self.AsteroidsParticles = {}
    AsteroidParticle = {}
    self.MaxAsteroidsParticles = 10
    self.MaxAsteroidsParticlesLifetime = math.random(2, 5)
    self.AsteroidsParticlesSpawned = 0

    self.SpriteSheet = love.graphics.newImage('assets/asteroids.png')
    self.AsteroidFrameWidth, self.AsteroidFrameHeight = 32, 32
    self.ImageGrid = Anim8.newGrid(self.AsteroidFrameWidth, self.AsteroidFrameHeight, self.SpriteSheet:getWidth(), self.SpriteSheet:getHeight())

    self.AsteroidType = {}
    self.AsteroidType[1] = Anim8.newAnimation(self.ImageGrid(1,1), 0.1)
    self.AsteroidType[2] = Anim8.newAnimation(self.ImageGrid(2,1), 0.1)

    self.AsteroidParticle = Anim8.newAnimation(self.ImageGrid(3,1), 0.1)
    self.ParticleAnimation = self.AsteroidParticle

    self.CurrentAnimation = self.AsteroidType[math.random(2)]

    self.AsteroidsExplosions = {}
    self.AsteroidExplosionImage = love.graphics.newImage('assets/sfx/Explosion/explodeSheet.png')
    self.AsteroidExplosion_FrameWidth, self.AsteroidExplosion_FrameHeight = 48, 48
    self.AsteroidExplosion_ImageGrid = Anim8.newGrid(self.AsteroidExplosion_FrameWidth, self.AsteroidExplosion_FrameHeight, self.AsteroidExplosionImage:getWidth(), self.AsteroidExplosionImage:getHeight())
    self.AsteroidExplosion_Animation = Anim8.newAnimation(self.AsteroidExplosion_ImageGrid('1-4',1), 0.2, 
    function(a, b)
        if b ~= 0 then
            -- self.AsteroidExplosion_Animation:gotoFrame(1)
            for i, AsteroidExplosion in ipairs(self.AsteroidsExplosions) do
                table.remove(self.AsteroidsExplosions, i)
                self.AsteroidExplosion_Animation:gotoFrame(1)

            end
        end
    end)
      
    function Asteroids:Draw()        
        for i, asteroid in ipairs(self.asteroids) do
            love.graphics.setColor(1, 1, 1)
            asteroid.type:draw(self.SpriteSheet, asteroid.x, asteroid.y, asteroid.rotate, asteroid.size / 13, asteroid.size / 13, self.AsteroidFrameWidth /2, self.AsteroidFrameHeight /2)            
                -- love.graphics.print(asteroid.life, asteroid.x - 30, asteroid.y - 30)
            if asteroid.IsShowingHealth then
                UserInterface:DrawHealthBar(asteroid.x, asteroid.y - 20, 30, 3, asteroid.life, asteroid.MaxLife, {0, 0, 0}, {1, 0, 0})
            end
        end
        for i, AsteroidParticle in ipairs(self.AsteroidsParticles) do
            -- love.graphics.circle('line', AsteroidParticle.x, AsteroidParticle.y, AsteroidParticle.radius)
            self.ParticleAnimation:draw(self.SpriteSheet, AsteroidParticle.x, AsteroidParticle.y, AsteroidParticle.angle, AsteroidParticle.radius / 8, AsteroidParticle.radius / 8, self.AsteroidFrameHeight /2, self.AsteroidFrameHeight /2)
        end
        for i, AsteroidExplosion in ipairs(self.AsteroidsExplosions) do
            AsteroidExplosion.animation:draw(self.AsteroidExplosionImage, AsteroidExplosion.x, AsteroidExplosion.y, 0, AsteroidExplosion.size, AsteroidExplosion.size, self.AsteroidExplosion_FrameWidth /2, self.AsteroidExplosion_FrameHeight /2)
        end
    end

    function Asteroids:Update(dt)

        self.CurrentAnimation:update(dt)
        self.ParticleAnimation:update(dt)
        self.AsteroidExplosion_Animation:update(dt)

        -- Spawn new asteroids
        self.TimeSinceLastSpawn = self.TimeSinceLastSpawn + dt
        if self.AsteroidsSpawned < self.MaxAsteroids then
            local spawnCount = math.floor(self.TimeSinceLastSpawn * self.SpawnRate)
            if self.AsteroidsSpawned + spawnCount > self.MaxAsteroids then
                spawnCount = self.MaxAsteroids - self.AsteroidsSpawned
            end
            for i = 1, spawnCount do
                Asteroids:SpawnAsteroids()
                if asteroid.size < 10 then
                    asteroid.MaxLife = 2
                    asteroid.life = asteroid.MaxLife
                end
            end
            self.TimeSinceLastSpawn = self.TimeSinceLastSpawn - spawnCount / self.SpawnRate
            self.AsteroidsSpawned = self.AsteroidsSpawned + spawnCount
        end
    
        -- Move existing asteroids
        for i, asteroid in ipairs(self.asteroids) do
            asteroid.x = asteroid.x + asteroid.vx * dt
            asteroid.y = asteroid.y + asteroid.vy * dt
            asteroid.rotate = asteroid.rotate + asteroid.RotateSpeed *dt

            -- LifeTimeLimit
            asteroid.lifetime = asteroid.lifetime + dt
            local soundx, soundy = 0, 0
            soundx, soundy = soundx + (soundx - asteroid.x), soundy + (soundy - asteroid.y)

            -- Remove asteroids that are off screen
            if asteroid.x < -asteroid.size or asteroid.x > 2040 + asteroid.size or
            asteroid.y < -asteroid.size or asteroid.y > 980 + asteroid.size or
            asteroid.lifetime > self.MaxLifeTime or asteroid.life <= 0 then
                -- Spawn Particles if asteroids are destroyed
                for i = 1, math.random(10, 20) do
                    Asteroids:SpawnAsteroidsParticles(asteroid)
                end
                table.remove(self.asteroids, i)
                for i = 1, 1 do
                    Asteroids:SpawnAsteroidExplosion(asteroid)                    
                end
                self.AsteroidsSpawned = self.AsteroidsSpawned - 1

            end
            
            for i, bullet in ipairs(Player.bullets) do
                if Gameplay:CirclesCollide(asteroid.x, asteroid.y, asteroid.size, bullet.x, bullet.y, bullet.radius) then
                    asteroid.life = asteroid.life - Player.BulletDamage
                    asteroid.IsShowingHealth = true
                    for i = 1, math.random(2, 4) do
                        Player:SpawnBulletParticles(bullet)
                    end
                    table.remove(Player.bullets, j)
                    asteroid.HitSound:stop()
                    asteroid.HitSound:play()
                    asteroid.HitSound:setVolume(Data:SoundAttenuationToPlayer(asteroid.x, asteroid.y, 300, 1))
                end
            end

            -- Bullet Particles
            for i, BulletParticle in ipairs(Player.BulletsParticles) do
                BulletParticle.x = BulletParticle.x + math.cos(BulletParticle.angle) * BulletParticle.speed * dt
                BulletParticle.y = BulletParticle.y + math.sin(BulletParticle.angle) * BulletParticle.speed * dt
                BulletParticle.lifetime = BulletParticle.lifetime + dt
                BulletParticle.opacity = BulletParticle.opacity - 10 * dt

                if BulletParticle.lifetime > Player.BulletParticleMaxLifeTime then
                    table.remove(Player.BulletsParticles, k)
                end
            end
        end

        -- Asteroids Particles
        for i, AsteroidParticle in ipairs(self.AsteroidsParticles) do
            AsteroidParticle.x = AsteroidParticle.x + AsteroidParticle.vx *AsteroidParticle.speed * dt 
            AsteroidParticle.y = AsteroidParticle.y + AsteroidParticle.vy *AsteroidParticle.speed * dt
            if AsteroidParticle.speed > 0 then
                AsteroidParticle.speed = AsteroidParticle.speed - dt
            end
            AsteroidParticle.angle = AsteroidParticle.angle + dt  
            AsteroidParticle.lifetime = AsteroidParticle.lifetime + AsteroidParticle.RotateSpeed * dt

            if AsteroidParticle.lifetime > self.MaxAsteroidsParticlesLifetime then
                table.remove(self.AsteroidsParticles, i)
            end
        end

        -- Asteroid Explosion
        for i, AsteroidExplosion in ipairs(self.AsteroidsExplosions) do
            AsteroidExplosion.animation:update(dt)
            AsteroidExplosion.sound:setVolume(Data:SoundAttenuationToPlayer(AsteroidExplosion.x, AsteroidExplosion.y, 300, 1))
        end

    end

    function Asteroids:SpawnAsteroids()
        self.CurrentAnimation = self.AsteroidType[math.random(2)]

        asteroid = {}
        asteroid.type = self.CurrentAnimation
        asteroid.x = love.math.random(0, 2040)
        asteroid.y = love.math.random(0, 980)
        asteroid.vx = math.random(-5, 15)
        asteroid.vy = math.random(-5, 15)
        asteroid.size = math.random(9, 20)  
        asteroid.RotateSpeed = math.random(-0.01, 3)
        asteroid.rotate = 0 
        asteroid.lifetime = 0
        asteroid.MaxLife = 5
        asteroid.life = asteroid.MaxLife 
        asteroid.HitSound = Data.Audio.AsteroidHit
        asteroid.IsShowingHealth = false

        table.insert(self.asteroids, asteroid)

        return asteroid
    end

    function Asteroids:SpawnAsteroidsParticles(asteroid)
        AsteroidParticle = {
            x = asteroid.x + math.random(-2, 5),
            y = asteroid.y + math.random(-2, 5),
            vx = math.random(-5, 15),
            vy = math.random(-5, 15),
            speed = 10,
            RotateSpeed = math.random(-0.01, 5),
            angle = math.random(-160, 160),
            radius = math.random(0.1, 5),
            lifetime = 0,
        }
        table.insert(self.AsteroidsParticles, AsteroidParticle)
        
        return AsteroidParticle
    end

    function Asteroids:SpawnAsteroidExplosion(asteroid)
        AsteroidExplosion = {
            x = asteroid.x,
            y = asteroid.y,
            size = 2,
            animation = self.AsteroidExplosion_Animation,
            lifetime = 0,
            sound = Data.Audio.AsteroidExplode

        }
        table.insert(self.AsteroidsExplosions, AsteroidExplosion)
        AsteroidExplosion.sound:stop()
        AsteroidExplosion.sound:play()

        return AsteroidExplosion
    end

    function Asteroids:CollisionDraw()
        for i, asteroid in ipairs(Asteroids.asteroids) do
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle('line', asteroid.x, asteroid.y, asteroid.size)
        end
        for i, AsteroidParticle in ipairs(self.AsteroidsParticles) do
            love.graphics.setColor(255, 255, 255)
            love.graphics.circle('line', AsteroidParticle.x, AsteroidParticle.y, AsteroidParticle.radius)
        end
    end
    
end

return Asteroids
