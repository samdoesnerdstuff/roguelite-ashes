local player = {
    x = 0,
    y = 0,

    -- stats and stuff
    hp_current = 0,
    hp_max = 0,
    sanity = 1.0,               -- 0.10 loss per day
    hydration = 1.0,            -- 0.33 loss per day
    hunger = 1.0,               -- 0.09 loss per day

    -- movement
    stamina = 1.0,
    stamina_loss_rate = 0.01,
    stamina_regen_rate = 0.009,
    speed = 133,

    -- flags
    has_done_sanity_retaining_activity = false,
    has_eaten_today = false,
    has_hydrated_today = false,
    gone_insane = false,
    is_dehydrated = false,

}

-- handles both player movement and sprinting logic
function player:move(dt)
    local speed_mul
    local original_spd = self.speed

    if love.keyboard.isDown("lshift") then
        speed_mul = 1.50
        self.stamina = math.max(0, self.stamina - self.stamina_loss_rate)
    else
        speed_mul = 1.00
        self.stamina = math.min(1.0, self.stamina + self.stamina_regen_rate)
    end

    -- checking if stamina is depleted
    if self.stamina == 0.0 then
        speed_mul = 1.00
    end

    self.speed = self.speed * speed_mul
    if love.keyboard.isDown("w") then self.y = self.y - self.speed * dt end
    if love.keyboard.isDown("s") then self.y = self.y + self.speed * dt end
    if love.keyboard.isDown("a") then self.x = self.x - self.speed * dt end
    if love.keyboard.isDown("d") then self.x = self.x + self.speed * dt end

    self.speed = original_spd
end

function player:update(dt)
    player:move(dt)
end

function player:draw()
    love.graphics.rectangle("fill", self.x, self.y, 32, 32)
end

function player:status()
    print(string.format("HP: %d/%d | Stamina: %.3f | pos: X:%d Y:%d", 
            self.hp_current, self.hp_max, self.stamina, self.x, self.y))
end

function player:advance_day()
end

return player