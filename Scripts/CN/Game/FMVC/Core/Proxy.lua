
local Proxy = class("Proxy")
local Cache = _G.Cache

function Proxy:ctor()
	
end

function Proxy:invoke(interface,params)
	local params = params or {}
	local args = params.args
	local success = params.success
	local exception = params.exception
	local bindData = params.bindData

	assert(type(interface) == "string" and interface ~= "","interface must be a string!")
	RPCReq[interface](Cache.networkCache,args,success,exception,bindData)
end



return Proxy