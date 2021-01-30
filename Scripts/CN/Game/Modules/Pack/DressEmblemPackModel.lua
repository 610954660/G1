-- add by zn
-- 已穿戴纹章背包

local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local DressEmblemPackModel = class("DressEmblemPackModel", PackBaseModel);

function DressEmblemPackModel:setCategoryByUUID(uuid,category)
	for key,item in pairs(self.__packItems) do
		if item:getUuid() == uuid then
			item:setCategory(category)
			break
		end
	end
end

function DressEmblemPackModel:setLevelExpByUUID(uuid,level,exp)
	for key,item in pairs(self.__packItems) do
		if item:getUuid() == uuid then
			item:setLevelExpByUUID(level,exp)
			break
		end
	end
end

return DressEmblemPackModel;