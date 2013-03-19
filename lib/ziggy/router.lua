local insert = table.insert
local find = string.find

local _M = {}

local function call(self, req, res, nxt)
    local method = req.method
    local routes = self.routes[method]
    if not routes then
	return nil, "unhandled method: " .. method
    end
    for _,item in ipairs(routes) do
	if find(ngx.var.uri, item.pattern) then
	    -- should wrap in pcall??
	    item.func(req, res)
	end
    end
    return nxt(req, res)
end

--- Create a new ziggy router.
-- @return a ziggy router
function _M.new()
    local self = {
	routes = { 
	    GET = {},
	    POST = {},
	    PUT = {},
	    DELETE = {}
	}
    }
    return setmetatable(self, { __index = _M, __call = call })
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
    return self
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

return _M