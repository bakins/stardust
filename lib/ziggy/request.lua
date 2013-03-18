-- wraps an nginx request
-- copy something like http://expressjs.com/api.html#req.params ?
-- or something "rack-like"
-- I prefer my method of doing responses, however

local lower = string.lower
local gsub = string.gsub

local _M = {}

local simple_indexes = {
    query = args,
    -- should provide a parse mechanism for cookies??
    cookies = http_cookies,
    ip = remote_addr,
    path = uri,
    host = host
}

local index_funcs = {
    header = function(ngx) return ngx.var["http_" . .gsub(lower(key), "-", "_")] end
}

for k,v in pairs(simple_indexes) do
    index_funcs[k] = function(ngx) return ngx.var[k] end
end

local function index_function(t, k)
    local ngx = rawget(t, "ngx")
    local func = index_funcs[k]
    if func then
	return func(ngx)
    else
	return nil
    end
end

local function newindex_function(t, key, val)
    -- this should probably throw an error??
end

function _M.new(ngx)
    local self = {
	ngx = ngx
    }
    return setmetatable(self, { __index = index_function, __newindex = newindex_fucntion)
end

return _M