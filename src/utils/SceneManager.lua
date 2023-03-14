local Scene_Manager = {}

function Scene_Manager:DrawLoad(name)
    name()
end

function Scene_Manager:UpdateLoad(name, dt)
    name(dt)
end

return Scene_Manager