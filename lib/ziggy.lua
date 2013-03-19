--- Ziggy
-- @module ziggy
-- @alias _M


-- Random thoughts
-- maybe have different types of matches? exact, location/trie, regex, pattern

local insert = table.insert
local find = string.find
local len = string.len

local request = require "ziggy.request"
local response = require "ziggy.response"

local _M = {}

--- Create a new ziggy application.
-- @return a ziggy application
function _M.new()
    local self = {
	routes = { 
	    GET = {},
	    POST = {},
	    PUT = {},
	    DELETE = {}
	}
    }
    return setmetatable(self, { __index = _M })
end

--- Add a route
-- @param self ziggy application
-- @param method HTTP method, ie GET, POST
-- @param pattern uri pattern to match
-- @param func function to call when this pattern is matched. fucntion should take 2 arguments: a request object and a response object
-- @usage app = ziggy.new()
--app:route('GET', '/foo', function(req, res) res.body = "hello" end)

function _M.route(self, method, pattern, func)
    local t = self.routes[method]
    if not t then
	return nil, "unhandled method: " .. method
    end
    -- should we test the pattern??
    
    insert(t, { pattern = pattern, func = func })
    return true, nil
end

local route = _M.route

-- be explicit for documentation...

--- Convenience function to add a route for GET
-- @param self ziggy application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.get(self, pattern, func) 
    return route(self, "GET", pattern, func) 
end

--- Convenience function to add a route for POST
-- @param self ziggy application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.post(self, pattern, func) 
    return route(self, "POST", pattern, func) 
end

--- Convenience function to add a route for PUT
-- @param self ziggy application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.put(self, pattern, func) 
    return route(self, "PUT", pattern, func) 
end

--- Convenience function to add a route for DELETE
-- @param self ziggy application
-- @param pattern uri pattern to match
-- @param func function
-- @see route
function _M.delete(self, pattern, func) 
    return route(self, "DELETE", pattern, func) 
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
        headers["Content-Length"] = len(body)
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

local request_new = request.new
local response_new = response.new

--- Runt the application
-- @param self ziggy application
-- @param ngx magix nginx Lua object
-- @usage Add something like this to nginx.conf:
--content_by_lua 'return require("my.ziggy.module").run(ngx)';
function _M.run(self, ngx)
    local method = ngx.req.get_method()
    local routes = self.routes[method]
    if not routes then
	return nil, "unhandled method: " .. method
    end
    for _,item in ipairs(routes) do
	if find(ngx.var.uri, item.pattern) then
	    -- we may want to provide a "wrapped" version of the request??
	    local req, res = request_new(ngx), response_new(ngx)
	    -- should wrap in pcall??
	    item.func(req, res)
	    return send_response(ngx, res)
	end
    end
end

return _M