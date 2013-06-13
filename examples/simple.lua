-- add this into your init_by_lua

-- not sure we gain anything by abstracting away the nginx object
-- maybe enforcing best practices?? or just convienience?

local stardust = require "stardust"
local cjson = require "cjson"
local router = require "stardust.router"

local _M = {}

local function html(res, data)
    res.status = 200
    res.headers["Content-Type"] = "text/html"
    res.body = data
    return res
end

local encode = cjson.encode
local function json(res, data)
    res.status = 200
    res.headers["Content-Type"] = "application/json"
    res.body = encode(data)
    return res
end

local app = stardust.new()
local r = router.new()
app:use(r)

r:get("%.html?$", 
	function(req, res)
	    return html(res, "<html>You came looking for " .. req.path .. "</html>")
	end
       )

local options = { foo = "bar" }

r:get("^/options", 
	function(req, res)
	    local foo = {
		options = options,
		path = req.path
	    }
	    return json(res, foo)
	end
       )

-- add this to content_by_lua like
-- content_by_lua = 'return require("stardust.examples.simple").run(ngx)'

function _M.run(ngx)
    return app:run(ngx)
end

return _M