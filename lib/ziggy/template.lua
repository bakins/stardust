--- Ziggy Template
-- @module ziggy.template
-- @alias _M

local gsub = string.gsub
local _M = {}

-- Should template cache be global? would have to use full path name, I think
-- to avoid possible collisions

-- some of this probably needs to be wrapped in pcalls
-- could do a special loader??
function _M.load(self, name) 
    local t = self.templates[name]
    if t then
	return t
    end
    name = gsub(name, "%.", "/")
    local filename = self.dir .. "/" .. name .. ".lua"
    local file = io.open(filename, "r")
    if not file then
	return nil, "open failed: " .. filename
    end
    local f = loadstring(file:read("*a"))
    -- we expect this to be a table with a render function
    -- TODO: error handling, etc
    t = f()
    local func = t.render
    self.templates[name] = func
    return func
end

local load = _M.load

function _M.render(self, template, res, data)
    if type(template) == "string" then
	template = load(self, template)
    end
    local func = function(d) 
	setfenv(1, d)
	
	return template(d)
    end
    
    local rc, t = pcall(func, data)
    if not rc then
	-- what kind of error handling? 500?
	res.status = 500
	res.body = nil
	return nil, t
    end
    -- for now, we just expect a string, or table of strings back
    if type(t) == "table" or type(t) == "string" then
	res.body = t
    end
    -- IMO, setting headers should be in controller. agree??
    return res
end

function _M.new(dir)
    local self = {
	dir = dir,
	templates = {}
    }
    return setmetatable(self, { __index = _M })
end

return _M