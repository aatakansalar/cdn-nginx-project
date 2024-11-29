local redis = require "resty.redis"

local function cache_get(cache_key)
    local red = redis:new()
    red:set_timeout(1000) 

    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
        return nil
    end

    local res, err = red:get(cache_key)
    if not res then
        ngx.log(ngx.ERR, "Failed to get key from Redis: ", err)
        return nil
    end

    if res == ngx.null then
        return nil
    end

    return res
end

local function cache_set(cache_key, data, ttl)
    local red = redis:new()
    red:set_timeout(1000)

    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
        return
    end

    local ok, err = red:setex(cache_key, ttl, data)
    if not ok then
        ngx.log(ngx.ERR, "Failed to set key in Redis: ", err)
    end
end

return {
    get = cache_get,
    set = cache_set,
}
