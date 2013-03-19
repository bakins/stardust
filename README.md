Ziggy Stardust
==========

Ziggy Stardust (or just "ziggy") is a simple nginx/Lua framework inspired by
[Sinatra](http://www.sinatrarb.com/),
[Express](http://expressjs.com/), and
[Mercury](https://github.com/nrk/mercury).

It is currently in development and is little more than a toy. It may
east your data and crash your computer.

Sample
------
The easiest way to explain ziggy is to show an example.

    local ziggy = require "ziggy"
    local router = require "ziggy.router"
    
    local app = ziggy.new()
    local r = router.new()
    app:use(r)
    
    r:get("%.txt?$",
        function(req, res)
            res.body = "hello, it seems you requested " .. req.path
        end
       )
       
    function _M.run(ngx)
        return app:run(ngx)
    end

    return _M
    
And the add something like this to your nginx virtual server config:

    location / {
        content_by_lua 'return require("redis").run(ngx)';
    }
    
There are more examples in the `examples` directory.


# Concepts Building Blocks #

The modules are documented using
[ldoc](http://stevedonovan.github.com/ldoc/). Check that for the
"real" documentation.

## Core ##
Lua module `ziggy`

The core of ziggy doesn't do much. It is used to create and run and
app. It is also used to register middleware for an app.

## Middleware ##
Middleware is where the actual work happens. Here's and extremely
simple example of creating and using middleware:

    
    local app = ziggy.new()
    local r = router.new()
    app:use(r)
    
    app:use(function(req, res) 
        res.body = string.upper(res.body)
    end
    
    r:get("%.txt?$",
        function(req, res)
            res.body = "hello, it seems you requested " .. req.path
        end
       )
       
 In this example, the body of the response will be converted to
 uppercase. The middleware can live in a module or be created "on the
 fly" -- ziggy doesn't care, it just needs to be a function that
 accepts a request and a response. Middleware should generally return `nil`  
