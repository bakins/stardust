--- Ziggy Response
-- @module ziggy.response
-- @alias _M

local _M = {}

--- Create a new response object.
-- A response object is just a table with some helper functions.
-- @param ngx magic nginx lua object
-- @return a response object/table
-- @usage You can directly manipulate the reponse object fields: 
-- * status - should be an http code as an integer
-- * headers - a table of http response headers
-- * body - a string of the http response
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