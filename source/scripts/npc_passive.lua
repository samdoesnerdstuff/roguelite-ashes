local npc = {}
local npc.__index = npc

function npc.new(name, path_type, x, y)
    local self = setmetatable({}, npc)
    self.name = name
    self.path_type = path_type
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.direction = nil
    return self
end

function npc:draw()
end

function npc:update(dt)
end