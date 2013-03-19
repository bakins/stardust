--- Ziggy Request
-- @module ziggy.request
-- @alias _M


-- wraps an nginx request
-- copy something like http://expressjs.com/api.html#req.params ?
-- or something "rack-like"
-- I prefer my method of doing responses, however

local lower = string.lower
local gsub = string.gsub

local _M = {}

-- raw index functions get the actual ngx object
local raw_index_funcs = {
}

-- normal index functions get a "request" object
local normal_index_funcs = {
}

function _M.register_raw_index(key, func)
    raw_index_funcs[key] = func
end

function _M.register_index(key, func)
    normal_index_funcs[key] = func
end

local register_raw_index = _M.register_raw_index

register_raw_index("header", function(ngx) return ngx.var["http_" .. gsub(lower(key), "-", "_")] end)
register_raw_index("method", function(ngx) return ngx.req.get_method() end)

local simple_indexes = {
    query = "args",
    -- should provide a parse mechanism for cookies??
    cookies = "http_cookies",
    ip = "remote_addr",
    path = "uri",
    host = "host"
}
for k,v in pairs(simple_indexes) do
    register_raw_index(k, function(ngx) return ngx.var[v] end)
end

local function index_function(t, k)
    local func = rawget(raw_index_funcs, k)
    if func then
	local ngx = rawget(t, "ngx")
	return func(ngx)
    else
	func = rawget(normal_index_funcs, k)
	if func then
	    return func(t)
	end
    end
    return nil
end

local function newindex_function(t, key, val)
    -- this should probably throw an error??
end

--- Create a new request object.
-- A response object a table with some helper functions. You generally only access it via the helper functions
-- or the magic of its metatable
-- @param ngx magic nginx lua object
-- @return a response object
function _M.new(ngx)
    local self = {
	ngx = ngx,
	ctx = {}
    }
    return setmetatable(self, { __index = index_function, __newindex = newindex_function })
end

--- Request object can be access like a table.
-- @field path path portion of the url
-- @field query query string
-- @field cookies raw cookie header
-- @field ip client remote address
-- @field host HTTP host header or the virtual server name
-- @field header table like container of http request headers. req.header["User-Agent"]
-- @table request


return _M