--- Ziggy
-- @module stardust
-- @alias _M


-- Random thoughts
-- maybe have different types of matches? exact, location/trie, regex, pattern

local insert = table.insert
local find = string.find
local len = string.len

local request = require "stardust.request"
local response = require "stardust.response"

local _M = {}

local function dummy_last_middleware(ngx, res, nxt)
    -- http://wiki.nginx.org/HttpLuaModule#ngx.req.discard_body
    -- if noone else read it, just throw it away
    ngx.req.discard_body()
end

--- Create a new stardust application.
-- @return a stardust application
function _M.new()
    local self = {
	middleware = { 
	    dummy_last_middleware
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
    -- this is horrible, but makes sure our dummy function stays last
    local t = self.middleware
    local size = #t
    local dummy = t[size]
    t[size] = func
    t[size+1] = dummy
    return self
end

-- lifted from, LSD, ouzo, etc
-- could maybe use a function or table for body???
local function send_response(ngx, response)
    local headers = response.headers or {}
    local status = tonumber(response.status) or 500
    
    if status < 500 then
        local content_type = headers["Content-Type"]
        if not content_type then
            headers["Content-Type"] = "text/plain"
        end
        local body = response.body or ""
	if type(body) == "string" then
	    headers["Content-Length"] = len(body)
	end
        ngx.status = status
        for k,v in pairs(headers) do
            ngx.header[k] = v
        end
        
        ngx.print(body)
        ngx.eof()
    else
        local error = response.error
        if error then
            ngx.log(ngx.ERR, status .. ": " .. error) 
        end
        return ngx.exit(status)
    end
end

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