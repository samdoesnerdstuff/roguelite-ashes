-- manager for all the NPCs

local npc_mgr = {}
npc_mgr.__index = npc_mgr

local hnpc = require("npc_hostile")
local pnpc = require("npc_passive")
local yml = require("yaml")
local path = "assets/data/npc"

function npc_mgr.new()
    local self = setmetatable({}, npc_mgr)
    self.passive_npcs = {}
    self.hostile_npcs = {}
    return self
end

function npc_mgr:load_passive_npcs()
    local passive_path = path .. "/passive"
    if not love.filesystem.exists(passive_path) then
        return nil
    end

    -- Since the npc data dir exists, we can start loading them up
    -- (Surprisingly memory efficient)
    local entries = love.filesystem.getDirectoryItems(passive_path)
    if not entries then
        return nil
    end

    self.passive_npcs = self.passive_npcs or {}

    for _, file in ipairs(entries) do
        if file:match("%.ya?ml$") then
            local fullpath = passive_path .. "/" .. file

            -- love.filesystem reading since relying on the OS is meh
            local content, err = love.filesystem.read(fullpath)
            if not content then
                print("Error reading " .. fullpath .. ": " .. (err or "unknown"))
            else
                local ok, data = pcall(yaml.parse_string, content)
                if not ok then
                    print("YAML error in " .. file .. ": " .. tostring(data))
                elseif validate_passive_struct(data) then
                    local npc = pnpc.new(data.name, data.path_type, data.x, data.y)
                    table.insert(self.passive_npcs, npc)
                else
                    print("Invalid NPC data in: " .. file)
                end
            end
        end
    end
end

function npc_mgr:load_hostile_npcs()
    local hosile_path = path .. "/hostile"
    if not love.filesystem.exists(hostile_path) then
        return nil
    end


end

function npc_mgr:purge()
    self.passive_npcs = {}
    self.hostile_npcs = {}
end

local function validate_passive_struct(data)
    if type(data) ~= "table" then return false end

    local required = {
        name = "string",
        path_type = "string",
        x = "number",
        y = "number"
    }

    for key, expected_type in pairs(required) do
        if type(data[key]) ~= expected_type then
            print(string.format(
                "Invalid passive NPC: %s should be %s (got %s)",
                key, expected_type, type(data[key])
            ))
            return false
        end
    end

    return true
end

local function validate_hostile_struct(data)
end