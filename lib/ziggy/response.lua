-- A response is really just a table..
-- may add some helper functions
local _M = {}

function _M.new(ngx)
    local self = {
	ngx = ngx,
	status = 200,
	headers = {},
	body = nil
    }
    return self
end

return _M