local player = require("scripts/player")

function love.load()

end

function love.draw()
    player:draw()
end

function love.update(dt)
    player:status()
    player:update(dt)
end
