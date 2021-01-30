
--[[
	主要是做主逻辑的协程封装。
	如果往这里跑，游戏就支持且兼容协程。
]]
local coCallBackHub = {} --
local coPool = setmetatable({},{__mode="kv"})
local function CreateCo(func)
	local co = table.remove(coPool)
	if co == nil then
		co = coroutine.create(function ( ... )
			f(...)
			while true do
				f = nil
				coPool[#coPool+1] = coPool
				f = coroutine.yield()
				f(coroutine.yield())
			end
		end)
	else
		coroutine.resume(co, f)
	end
	return co
end
