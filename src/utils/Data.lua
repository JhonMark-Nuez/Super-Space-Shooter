local Data = {}

Data.PlayerStats = {}
Data.PlayerStats.PlayetHealth = 10
Data.PlayerStats.PlayerBoost = 100
Data.PlayerStats.BulletDamage = 1
Data.PlayerStats.BulletType = 'Single'

Data.Audio = {}
Data.Audio.SpaceShipThrust = love.audio.newSource('assets/sfx/SpaceShipThrust.ogg', 'static')
Data.Audio.LaserShoot = love.audio.newSource('assets/sfx/LaserShoot.wav', 'static')
Data.Audio.AsteroidHit = love.audio.newSource('assets/sfx/AsteroidHit.wav', 'static')
Data.Audio.AsteroidExplode = love.audio.newSource('assets/sfx/AsteroidExplode.wav', 'static')

Data.GamepadKeysMapping = {
    controls = {
        left = 'a'or 'left', 
        up = 'w', right = 'd', down = 's',
        boost = 'space'
    },
    groups = {
        move = {'a', 'w', 'd', 's'},
    }
}

Data.MouseKeysMapping = {
    action = 1
}

function Data:SoundAttenuationToPlayer(ax, ay, MaxDistance, MaxVolume)
    local distance = math.sqrt((Player.x - ax)^2 + (Player.y - ay)^2)
    local volume = MaxVolume * (1 - (distance / MaxDistance))
    return math.max(volume, 0)
end


return Data