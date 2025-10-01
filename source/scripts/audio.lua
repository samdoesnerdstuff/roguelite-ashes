-- sound / sfx / music manager for Lua

local sound_mgr = {}
sound_mgr.__index = sound_mgr

function sound_mgr.new()
    local self = setmetatable({}, sound_mgr)
    self.sounds = {}
    self.music = {}
    self.current_music = nil
    self.sfx_volume = 1         -- global volume for sfx
    self.music_volume = 1       -- global volume for music
    self.fade_speed = 0.5       -- fade in units of volume per second
    self.fading_in = false      -- flag for fade-in
    self.fading_out = false     -- flag for fade-out
    self.target_volume = 1      -- target volume when fading in
    return self
end

-- Loads a sound effect for short sound file
function sound_mgr:load_sound(name, path, pool_size)
    pool_size = pool_size or 6
    self.sounds[name] = {}
    for i = 1, pool_size do
        table.insert(self.sounds[name], love.audio.newSource(path, "static"))
    end
end

-- Loading a song into the table to be streamed as needed
function sound_mgr:load_music(name, path)
    self.music[name] = love.audio.newSource(path, "stream")
end

-- Play a sound effect once, using first free source in pool
function sound_mgr:play_sound(name, vol)
    local pool = self.sounds[name]
    if not pool then
        print("Error: Sound '" .. name .. "' not found")
        return
    end

    for _, sfx in ipairs(pool) do
        if not sfx:isPlaying() then
            sfx:setVolume((vol or 1) * self.sfx_volume)
            sfx:play()
            return
        end
    end

    -- if all are busy, cut off and play anyways
    local sfx = pool[1]
    sfx:setVolume((vol or 1) * self.sfx_volume)
    sfx:stop()
    sfx:play()
end

-- Play music, optional loops w/ optional fade-in
function sound_mgr:play_music(name, vol, loop, fade_in)
    local track = self.music[name]
    if not track then
        print("Error: Music '" .. name .. "' not found.")
        return
    end

    -- force stop current music if any
    if self.current_music then
        self:stop_music(false) 
    end

    track:setVolume(0)
    track:setLooping(loop == nil and true or loop) -- default loop=true if not specified
    track:play()
    self.current_music = track

    if fade_in then
        self.fading_in = true
        self.fading_out = false
        self.target_volume = (vol or 1) * self.music_volume
    else
        track:setVolume((vol or 1) * self.music_volume)
    end
end

-- Stops music, fading out optional
function sound_mgr:stop_music(fade_out)
    if self.current_music then
        if fade_out then
            self.fading_out = true
            self.fading_in = false
        else
            self.current_music:stop()
            self.current_music = nil
        end
    end
end

function sound_mgr:pause_music()
    if self.current_music then
        self.current_music:pause()
    end
end

function sound_mgr:resume_music()
    if self.current_music then
        self.current_music:play()
    end
end

-- Update method: handles current music state and fading
function sound_mgr:update(dt)
    if self.current_music then
        if not self.current_music:isPlaying() and not self.fading_in and not self.fading_out then
            self.current_music = nil
        end

        -- Fading in handle
        if self.fading_in then
            local v = self.current_music:getVolume() + self.fade_speed * dt
            if v >= self.target_volume then
                v = self.target_volume
                self.fading_in = false
            end
            self.current_music:setVolume(v)
        end

        -- Handle fade out
        if self.fading_out then
            local v = self.current_music:getVolume() - self.fade_speed * dt
            if v <= 0 then
                v = 0
                self.current_music:stop()
                self.current_music = nil
                self.fading_out = false
            else
                self.current_music:setVolume(v)
            end
        end
    end
end

-- Set global SFX / music volume
function sound_mgr:set_sfx_volume(vol)
    self.sfx_volume = math.max(0, math.min(vol, 1))
end

function sound_mgr:set_music_volume(vol)
    self.music_volume = math.max(0, math.min(vol, 1))
    if self.current_music and not self.fading_in and not self.fading_out then
        -- apply new global music volume
        local current = self.current_music:getVolume()
        -- scale current relative to new global
        local scaled = math.min(current, self.music_volume)
        self.current_music:setVolume(scaled)
    end
end

return sound_mgr