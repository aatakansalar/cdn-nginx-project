ngx.log(ngx.ERR, "validate_hmac.lua is being executed")

local hmac_signature = ngx.var.arg_hmac

if not hmac_signature then
    ngx.log(ngx.ERR, "Missing HMAC signature")
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

local secret_key = "your-secret-key"

local uri = ngx.var.request_uri

local uri_without_hmac = ngx.re.sub(uri, [[(&|\?)hmac=[^&]*]], "", "jo")
ngx.log(ngx.ERR, "URI without hmac: ", uri_without_hmac)

local cmd = string.format("echo -n '%s' | openssl dgst -sha256 -hmac '%s' -binary | openssl base64 | tr '+/' '-_' | tr -d '='", uri_without_hmac, secret_key)
local handle = io.popen(cmd)
local expected_signature = handle:read("*a")
handle:close()

expected_signature = expected_signature:gsub("\n", "")
ngx.log(ngx.ERR, "Expected Signature: ", expected_signature)
ngx.log(ngx.ERR, "Provided Signature: ", hmac_signature)
if hmac_signature ~= expected_signature then
    ngx.log(ngx.ERR, "Invalid HMAC signature")
    ngx.log(ngx.ERR, "Expected: ", expected_signature)
    ngx.log(ngx.ERR, "Provided: ", hmac_signature)
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end
