local ziggy = require "ziggy"
local router = require "ziggy.router"
local template = require "ziggy.template"
local random = math.random
local _M = {}

local FILE = string.sub(debug.getinfo(1, "S").source, 2)

function dirname(path)
    return string.match(path, "(.*)/([^/]*)$")
end

local app = ziggy.new()
local r = router.new()
app:use(r)

local dir = dirname(FILE)

t = template.new(dir .. "/templates")

-- could load at request time, but do it now
t:load("sample")

r:get("%.html?$", 
      function(req, res)
	  res.headers["Content-Type"] = "text/html"
	  t:render("sample", res, { foo = "bars", baz = 42, jitter = random(1, 100) })
      end
     )

function _M.run(ngx)
    return app:run(ngx)
end


return _M