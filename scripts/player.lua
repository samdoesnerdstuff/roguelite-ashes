local player = {
    x = 0,
    y = 0,

    -- stats and stuff
    hp_current = 75,
    hp_max = 75,
    sanity = 1.000,               -- 0.100 loss per day
    hydration = 1.000,            -- 0.330 loss per day
    hunger = 1.000,               -- 0.090 loss per day
    radiation = 0.000,            -- 0.001 gain per day
    rad_gain_rate = 0.001,
    days_survived = 0,
    hours_slept = 0,

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
    immune_to_radiation = false,

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
    print(string.format("HP: %d/%d | Stm: %.3f | pos: X:%d Y:%d", 
            self.hp_current, self.hp_max, self.stamina, self.x, self.y))
end

-- this is a weird long func filled with day-advance logic that tracks a lot
-- of flags and changes long-term stats like level, radiation, hunger, thirst
-- so on and so forth...
function player:advance_day()
    -- check if eaten, display message if at some threshold
    if not self.has_eaten_today then
        self.hunger = self.hunger - 0.090
        if self.hunger < 0.80 then
            print("Starting to get hungry...")
        elseif self.hunger < 0.70 then
            print("Getting quite hungry now...")
        elseif self.hunger < 0.50 then
            print("The hunger is starting to hurt...")
        elseif self.hunger < 0.25 then
            print("You feel weak from hunger...")
        elseif self.hunger < 0.10 then
            -- 0.000 -> 0.090 -> death
            print("You're starving...")
        else
            print("You've died of starvation.")
        end
    end

    -- hydration check (remember to drink water when coding)
    -- unlike hunger, dehydration kills you considerably faster
    if not self.has_hydrated_today then
        self.hydration = self.hydration - 0.330
        if self.hydration < 0.67 then
            print("Feeling thirsty...")
        elseif self.hydration < 0.34 then
            print("Feeling very thirsty...")
        elseif self.hydration > 0 and self.hydration < 0.33 then
            print("Extremely thirsty...")
        else
            -- everying below 0.33 results in death the following day
            print("You've died of dehydration.")
        end
    end

    -- sanity check! remember to stay sane even in the face of demise
    -- "sanity retaining" meaning things like relaxation, sleeping for greater
    -- than 6 hours, lowering a starvation or thirst level, leveling up, etc.
    if not self.has_done_sanity_retaining_activity or self.hours_slept < 6 then
        self.sanity = self.sanity - 0.100
        if self.sanity < 0.80 then
            print("You need to relax a little...")
        elseif self.sanity < 0.60 then
            print("You could use a break...")
        elseif self.sanity < 0.40 then
            print("You're starting to hear things...")
        elseif self.sanity < 0.20 then
            print("The voices are filling your ears...")
        elseif self.sanity < 0.10 then
            print("You aren't sure what is and isn't reality anymore...")
        else
            -- for sanity 0.000 - 0.090, you are deemed insane by the game
            -- and that's pretty bad D:
            self.gone_insane = true
            if self.gone_insane then
                -- massive loss to stamina
                self.stamina_loss_rate = 0.03
                self.stamina_regen_rate = 0.0045
            else
                self.stamina_loss_rate = 0.01
                self.stamina_regen_rate 0.009
            end
            if self.sanity < 0.000 then
                self.sanity = 0.000
            end
        end
    end

    if self.has_done_sanity_retaining_activity and self.gone_insane then
        self.sanity = 0.50
        print("You feel a lot better now...")
    end

    -- radiation is a much slower killer, for most peoples runs it is basically
    -- a non-issue unless things are real dire
    if not self.immune_to_radiation then
        self.radiation = self.radiation + self.rad_gain_rate

        if self.radiation == 0.010 then 
            self.rad_gain_rate = 0.002

        elseif self.radiation == 0.030 then
            self.rad_gain_rate = 0.003

        elseif self.radiation == 0.050 then
            self.rad_gain_rate = 0.006

        elseif self.radiation == 0.090 then
            self.rad_gain_rate = 0.020

        elseif self.radiation >= 0.40 then
            self.rad_gain_rate = 0.099
            self.sanity = self.sanity - 0.250
            print("The acute radiation is driving you mad...")
        end
    end

    -- And finally at the end of this logical chain we can advance the day
    self.days_survived = self.days_survived + 1
end

return player