local upper = string.upper
local ziggy = require "ziggy"
local router = require "ziggy.router"

local _M = {}

-- stupid simple middleware that just uppercases response

local function middleware(req, res)
    res.body = upper(res.body)
end

local app = ziggy.new()
local r = router.new()
app:use(r)
app:use(middleware)

r:get("/", 
      function(req, res)
	  res.body = req.path .. "\n"
      end
     )

function _M.run(ngx)
    return app:run(ngx)
end


return _M