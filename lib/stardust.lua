--- Ziggy
-- @module stardust

local insert = table.insert
local find = string.find
local len = string.len

local request = require "stardust.request"
local response = require "stardust.response"

local _M = {}

--- Create a new stardust application.
-- @return a stardust application
function _M.new()
    local self = {
	middleware = {
	}
    }
    return setmetatable(self, { __index = _M })
end

--- Add middleware to the stack. Middleware is called in the order it is added. While it is technically possible to add middleware 
-- after the application has started (ie, calling run), this is not supported and may lead to strange results.
-- Also add middleware before adding routes
-- @param self stardust application
-- @param func function to call
function _M.use(self, func)
    insert(self.middleware, func)
    return self
end

-- lifted from, LSD, ouzo, etc
-- could maybe use a function or table for body???

local response_new = response.new

--- Run the application
-- @param self stardust application
-- @param ngx magic nginx Lua object
-- @usage Add something like this to nginx.conf:
--content_by_lua 'return require("my.stardust.module").run(ngx)';
function _M.run(self, ngx)
    local res = response_new(ngx)
    local middleware = self.middleware
    for i=1,#middleware do
	local func = middleware[i]
	local rc = func(ngx, res)
	if rc ~= nil then
	    -- what type of error handling do we want to do
	    return ngx.exit(500)
	end
    end
    return send_response(ngx, res)
end

return _M