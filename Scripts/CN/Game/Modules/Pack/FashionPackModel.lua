-- add by lsy
-- 时装背包

local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local FashionPackModel = class("FashionPackModel", PackBaseModel);
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

--获取该英雄所拥有的皮肤
function FashionPackModel:getFashionPackDataByHeroId(heroId)
	local fashionData = {}
	for key,item in pairs(self.__packItems) do
		local heroIdEx = FashionConfiger.getHeroIdByFashionId(item:getItemCode())
		if heroIdEx then 
			if heroIdEx == heroId then
				table.insert(fashionData, item)
			end
		end
	end
	return fashionData
end

--是否拥有该皮肤
function FashionPackModel:getIsHaveFashion(fashionId)
	for key,item in pairs(self.__packItems) do
		if item:getItemCode() == fashionId then 
			return item
		end
	end
	return false
end

--获取时装物品对象
function FashionPackModel:getFashionItemById(fashionId)
	local itemObj
	for key,item in pairs(self.__packItems) do
		if item:getItemCode() == fashionId then 
			if not itemObj or itemObj:getGxpireMS() < item:getGxpireMS() then  --拿在效期最长的那个
				itemObj = item
			end
		end
	end
	return itemObj
end

function FashionPackModel:init()
	self.inited = false
end

function FashionPackModel:initRedMap()
	local redMap1 = {}
	local headRedMap = {}
	-- RedManager.register("V_FASHION_"..self.heroId.."_" ..data.code, redDot)
	for key,data in pairs(DynamicConfigData.t_Fashion) do
		local redMap2 = {}
		for _,v in pairs(data) do
			if v.label ~= -1 then
				table.insert(redMap2, "V_FASHION"..v.heroCode..v.code)
				table.insert(headRedMap, "V_HEAD_"..v.code)
			end
		end
		table.insert(redMap1, "V_FASHION"..key)
		RedManager.addMap("V_FASHION"..key, redMap2)
	end
	
	RedManager.addMap("V_HEAD", headRedMap)

	
	self.inited = true
end

function FashionPackModel:redCheck(itemData, curAmount, updateType)
	if not self.inited then
		self:initRedMap()
	end
	if updateType == "add" then
		local heroCode = FashionConfiger.getHeroIdByFashionId(itemData.__data.code)
		RedManager.updateValue("V_FASHION"..heroCode..itemData.__data.code, curAmount ~= 0)
		RedManager.updateValue("V_HEAD_"..itemData.__data.code, curAmount ~= 0)
	end
end

return FashionPackModel