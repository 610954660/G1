---@class BaseModel
--基础model类
local BaseModel = class("BaseModel")

function BaseModel:ctor()

end

function BaseModel:initListeners()
	local bindMap = self:excludebindMapFun()
	for funcName in pairs(getmetatable(self).__index) do
		if not bindMap[funcName] then
			local pos = string.find(funcName,"_")
			if pos and pos > 1 then
				if not __IS_RELEASE__ then
					--在不在两类事件枚举里面
				end
				Dispatcher.addEventListener(funcName,self)
			end
		end
	end
end

--清掉缓存，相当于重新初始化
function BaseModel:clear()
    
end

function BaseModel:excludebindMapFun()
	return  {}
end

return BaseModel
