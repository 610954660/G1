--added by xhd
--普通背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local NormalPackModel = class("NormalPackModel", PackBaseModel)
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

function NormalPackModel:packRedCheck()
	local canUse = false
	for _,v in pairs(self.__packItems) do
		local data = v:getItemInfo()
		local config = DynamicConfigData.t_item[data.code]
		local fashionRedDot = false 
		if config.type == GameDef.ItemType.FashioDebris then --时装碎片红点
			local fashionComposeInfo = FashionConfiger.getFashionComposeConfigerByFashionId(config.effect)
			local needNum = fashionComposeInfo and fashionComposeInfo.consume and fashionComposeInfo.consume[1] and fashionComposeInfo.consume[1].amount
			local haveNum = v:getItemAmount()
			fashionRedDot = needNum and haveNum >= needNum or false
		end
		if config.type == 4 or config.type == GameDef.ItemType.ElfSkin or fashionRedDot then
			canUse = true
			break
		end
	end
	RedManager.updateValue("V_BAG_NOR", canUse)
end

function NormalPackModel:redCheck(itemData, curAmount)
	--红点检测
	local itemInfo = itemData:getItemInfo()
	local type = itemInfo.type
	local code = itemInfo.code
	local ItemType = GameDef.ItemType
	if(type == ItemType.FairyLandItem) or (type == ItemType.FairyLandItemEx) then
		ModelManager.FairyLandModel:redCheck()
	end
	
	if(type == ItemType.TacticalItem) then
		ModelManager.TacticalModel:redCheck()
	end
	
	GlobalUtil.delayCallOnce("NormalPackModel:packRedCheck",self.packRedCheck, self, 0.1)
	
	if code ==10000004 or code == 10000005 or code ==10000050 or code ==10000053 or code ==10000067  or code ==10000070 or code ==10000096 then
		GetCardsModel:checkRedot()
		GetCardsYjActivityModel:checkRedDot()
	end
	Dispatcher.dispatchEvent(EventType.packItem_change,code)
	
	if code ==10000072 then
		TwistEggModel:redCheck()
	end
end

function NormalPackModel:decompose(reslist, cb)
	RPCReq.Bag_DecomposeItemCommon({resList = reslist}, function (param)
		if (cb) then cb() end
	end)
end

return NormalPackModel
