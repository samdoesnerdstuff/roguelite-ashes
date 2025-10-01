-- a tiny yaml-ish parser for Lua configs
-- NOT yaml 1.1 compliant, intentionally minimal.

local yaml = {}

-- utils
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

local function parse_value(v)
  v = trim(v)

  -- quoted strings
  if v:match('^".*"$') or v:match("^'.*'$") then
    local quote = v:sub(1,1)
    v = v:sub(2, -2) -- strip quotes
    if quote == '"' then
      v = v:gsub('\\"', '"')
    else
      v = v:gsub("\\'", "'")
    end
    return v
  end

  -- booleans
  if v == "true" then return true end
  if v == "false" then return false end

  -- numbers
  local num = tonumber(v)
  if num then return num end

  -- fallback: string
  return v
end

local function parse_yaml(lines, i, indent)
  local obj = {}
  local list_mode = false
  indent = indent or 0
  i = i or 1

  while i <= #lines do
    local line = lines[i]
    -- strip out the comments
    line = line:gsub("#.*$", "")

    if line:match("^%s*$") then
      i = i + 1
      goto continue
    end

    local current_indent = #line:match("^(%s*)")
    if current_indent < indent then
      return obj, i
    end

    line = trim(line)

    if line:match("^%- ") then
      -- list item
      list_mode = true
      local value = trim(line:sub(3))
      if value == "" then
        local sub, ni = parse_yaml(lines, i + 1, indent + 2)
        table.insert(obj, sub)
        i = ni - 1
      else
        table.insert(obj, parse_value(value))
      end
    else
      -- key: value
      local key, value = line:match("^(.-):%s*(.*)$")
      if not key then
        error("Invalid line at " .. i .. ": " .. line)
      end
      if value == "" then
        local sub, ni = parse_yaml(lines, i + 1, indent + 2)
        obj[key] = sub
        i = ni - 1
      else
        obj[key] = parse_value(value)
      end
    end

    i = i + 1
    ::continue::
  end

  return obj, i
end

--- Public API ---

function yaml.parse_string(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  local result = parse_yaml(lines, 1, 0)
  return result
end

function yaml.parse_file(path)
  local f, err = io.open(path, "r")
  if not f then return nil, err end
  local content = f:read("*a")
  f:close()
  return yaml.parse_string(content)
end

return yaml