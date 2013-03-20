local insert = table.insert
local _M = {}

-- data is the env, so data.key and key are the same, former saves a lookup
-- so template "compilerS" can be helpful in that way
function _M.render(data)
    local body = {}
    insert(body, "<html><head><title>Some awesome title: ")
    insert(body, data.jitter)
    insert(body, "</title></head><body>Hello, ")
    
    if data.jitter > 50 then
	insert(body, "how are you?")
    else
	insert(body, "now go away!")
    end

    insert(body, "</br>I see that you brought me ")
    insert(body, data.baz)
    insert(body, " ")
    insert(body, data.foo)
    
    insert(body, "</body></html>")

    return body
end

return _M