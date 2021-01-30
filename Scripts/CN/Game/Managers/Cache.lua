local Cache = {}


Cache.networkCache = {}

--切换帐号时的清理
function Cache.clear(changeRole)
	--不需要清理的表
	local excludeTable = {
		_M = true,
		networkCache = true,
		rolePackCache = true,
		equipPackCache = true
	}

	for k,v in pairs(_G.Cache) do 
		if not excludeTable[k] and type(v) == "table" then
			if k == "loginCache" then
				print(10,"清理缓存~~~",k)
				v:clear(changeRole)
			else
				print(10,"清理缓存",k)
				v:clear()
			end
		end
	end
end

return  Cache