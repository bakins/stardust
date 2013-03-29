--- Ziggy Router
-- @module ziggy.router
-- @alias _M

local insert = table.insert
local find = string.find
local lower = string.lower

local _M = {}

local function call(self, req, res)
    local method = req.method
    local routes = self.routes[method]
    if not routes then
	return nil, "unhandled method: " .. method
    end
    for _,item in ipairs(routes) do
	if item.pattern(ngx.var.uri) then
	    -- should wrap in pcall??
	    item.func(req, res)
	end
    end
end

--- Create a new ziggy router.
-- @return a ziggy router
function _M.new()
    local self = {
	routes = { 
	    -- what about HEAD? count as head??
	    GET = {},
	    POST = {},
	    PUT = {},
	    DELETE = {}
	}
    }
    return setmetatable(self, { __index = _M, __call = call })
end

-- is using __call slow???
local pattern_mt = {
    __tostring = "pattern: " .. self.pattern,
    __call = function(self, ngx) return find(ngx.var.uri, self.pattern) end
}

function _M.pattern(self, pattern)
    return setmetatable({ pattern = pattern })
end

local exact_mt = {
    __tostring = "exact: " .. self.pattern,
    __call = function(self, ngx) 
	local uri = self.caseless and lower(ngx.var.uri) or ngx.var.uri
	return uri == self.pattern 
    end
}

function _M.exact(self, pattern, caseless)
    return setmetatable({ pattern = caseless and lower(pattern) or pattern, caseless = caseless })
end

local regex_mt = {
    __tostring = "regex: " .. self.pattern,
    __call = function(self, ngx) 
	return ngx.re.match(ngx.var.uri, self.pattern,  self.caseless and "io" or "o")
    end
}

function _M.regex(self, pattern, caseless)
    return setmetatable({ pattern = pattern, caseless = caseless })
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
    if type(pattern) == "string" then
	pattern = _M.pattern(self, pattern)
    end
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