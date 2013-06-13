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

local response_new = response.new
local request_new = request.new

--- Run the application
-- @param self stardust application
-- @param ngx magic nginx Lua object
-- @usage Add something like this to nginx.conf:
--content_by_lua 'return require("my.stardust.module").run(ngx)';
function _M.run(self, ngx)
    local res = response_new(ngx)
    local req = request_new(ngx)
    local middleware = self.middleware
    for i=1,#middleware do
	local func = middleware[i]
	local rc = func(req, res)
	if rc ~= nil then
	    -- what type of error handling do we want to do
	    -- should we just assume we stop the loop here rather than throwing an error?
	    return ngx.exit(500)
	end
    end
end

return _M