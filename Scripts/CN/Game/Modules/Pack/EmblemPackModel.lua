-- add by zn
-- 纹章背包

local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local EmblemPackModel = class("EmblemPackModel", PackBaseModel);


function EmblemPackModel:setCategoryByUUID(uuid,category)
	for key,item in pairs(self.__packItems) do
		if item:getUuid() == uuid then
			item:setCategory(category)
			break
		end
	end
end

function EmblemPackModel:setLevelExpByUUID(uuid,level,exp)
	for key,item in pairs(self.__packItems) do
		if item:getUuid() == uuid then
			item:setLevelExpByUUID(level,exp)
			break
		end
	end
end
return EmblemPackModel;