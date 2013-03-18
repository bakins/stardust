-- add this into your init_by_lua

-- not sure we gain anything by abstracting away the nginx object
-- maybe enforcing best practices?? or just convienience?

local ziggy = require "ziggy"
local cjson = require "cjson"

local _M = {}

local function html(stuff)
    return {
	status = 200,
	headers = {
	    ["Content-Type"] = "text/html",
	},
	body = stuff
   }    
end

local encode = cjson.encode
local function json(data)
    return {
	status = 200,
	headers = {
	    ["Content-Type"] = "application/json",
	},
	body = encode(data)
   }    
end

local app = ziggy.new()

app:get("%.html?$", 
	function(req)
	    return html("<html>You came looking for " .. req.path .. "</html>")
	end
       )

local options = { foo = "bar")

app:get("^/options", 
	function(req)
	    return json(options)
	end
       )

-- add this to content_by_lua like
-- content_by_lua = 'return require("ziggy.examples.simple").run(ngx)'

function _M.run(ngx)
    return app:run(ngx)
end

return _M