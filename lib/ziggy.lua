-- Random thoughts
-- maybe have different types of matches? exact, location/trie, regex, pattern

local insert = table.insert
local find = string.find
local len = string.len

local request = require "ziggy.request"

local _M = {}

function _M.new()
    local self = {
	routes = { 
	    GET = {},
	    POST = {},
	    PUT = {},
	    DELETE = {}
	}
    }
    return setmetatable(self, { __index = _M }
end

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
for _,m in ipairs({ "get", "post", "put", "delete"}) do
    m = string.upper(m)
    function _M[m] = function(self, pattern, func) return route(self, m, pattern, func) end
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

function _M.run(self, ngx)
    local method = ngx.req.get_method
    local routes = self.routes[method]
    if not routes then
	return nil, "unhandled method: " .. method
    end
    for _,item in ipairs(routes) do
	if find(ngx.var.uri, item.pattern) then
	    -- we may want to provide a "wrapped" version of the request??
	    return send_response(ngx, item.func(request_new(ngx)))
	end
    end
end

return _M