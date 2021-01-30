---@class PackUpdater
--背包更新类 added by xhd
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local PackUpdater = {}

local BagType = GameDef.BagType
local UpdateCode = GameDef.UpdateCode

local _packEvents = {
	[BagType.Normal] = {changeEventName = EventType.pack_item_change},
	[BagType.Equip] = {changeEventName = EventType.pack_equip_change},
	[BagType.Special] = {changeEventName = EventType.pack_special_change},
	[BagType.HeroComponent] = {changeEventName = EventType.pack_herocomp_change},
	[BagType.Rune] = {changeEventName = EventType.pack_rune_change},
	[BagType.Jewelry] = {changeEventName = EventType.pack_jewelry_change},
	[BagType.PveStarTemple] = {changeEventName = EventType.pveStarTemple_change},
	[BagType.Elf] = {changeEventName = EventType.pack_elves_change},
	[BagType.HeadBorder] = {changeEventName = EventType.pack_headBoarder_change},
	[BagType.Heraldry] = {changeEventName = EventType.pack_emblem_change},
	[BagType.DressHeraldry] = {changeEventName = EventType.pack_emblem_equiped_change},
	[BagType.CrownTitle] = {changeEventName = EventType.pack_crownTitle_change},
	[BagType.Fashion] = {changeEventName = EventType.pack_fashion_change},
	[BagType.HonorMedalWall] = {changeEventName = EventType.pack_HonorMedalWall_change},
}

-- local _basePacks = {
-- 	[BagType.Normal] = true,
-- 	[BagType.Equip] = true,
-- }

-- local _notShowTip = {
-- 	[UpdateCode.Bag_ExchangeEquip] = true,
-- }

--道具数据刷新
function PackUpdater.itemChange(packType, itemData, amountChange, updateCode)
	local itemCode = itemData:getItemCode()
	local info = ItemConfiger.getInfoByCode(itemCode)
	if info == nil then
		print(1,itemCode, "item config is nil")
		return
	end

	--基础物品背包
	-- if _basePacks[packType] then
	-- 	--物品背包变更消息弹字
	-- 	if amountChange ~= 0 then
	-- 		print(1, "updateCode", updateCode)
	-- 		-- if not _notShowTip[updateCode] then
	-- 		-- 	local isAdd = amountChange > 0
	-- 		-- 	if isAdd  then
	-- 		-- 		local changeDesc = "描述"
	-- 		-- 		local str = string.format("%s [color=%s]%s[/color]×%d", changeDesc, GameDefConfig.getColorStr(info.color), info.name, math.abs(amountChange))
	-- 		-- 		MsgManager.showRollTipsMsg(str)
	-- 		-- 	else
	-- 		-- 		if __DEBUG__ then
	-- 		-- 			local changeDesc = "描述"
	-- 		-- 			local str = string.format("%s [color=%s]%s[/color]×%d", changeDesc, GameDefConfig.getColorStr(info.color), info.name, math.abs(amountChange))
	-- 		-- 			str = "debug:" .. str
	-- 		-- 			MsgManager.showRollTipsMsg(str)
	-- 		-- 		end
	-- 		-- 	end
	-- 		-- end
	-- 	end
	-- end

	if not __IS_RELEASE__ then
		if amountChange ~= 0 then
			local isAdd = amountChange > 0
			local changeDesc = Desc.bag_getdesc
			if not isAdd then
				changeDesc = Desc.bag_losedesc
			end
			local info = ItemConfiger.getInfoByCode(itemCode)
			if info == nil then
				printWarning(itemCode, "item config is nil")
				return
			end
			local str = string.format("%s[%s] %s[color=%s]%s[/color]×%d", Desc.bag_bagtype,packType, changeDesc, info.name, math.abs(amountChange),itemCode)
			print(1,str)
		end
	end

	local itemId = itemData:getItemId()
	return _packEvents[packType].changeEventName, {
		itemData = itemData,
		bagType = packType,
		itemCode = itemCode,
		type = itemData:getType(),
		amountChange = amountChange,
		itemId = itemId,
		updateCode = updateCode,
		extend = false
	}
end

function PackUpdater.getChangeEventName(bagType)
	return _packEvents[bagType].changeEventName
end

function PackUpdater.handleItemUpdateEvent(args)
	local bagType = args.bagType
	if bagType == BagType.Normal then --普通背包
		return PackUpdater.handleBagNormalAmountChange(args)
	elseif bagType == BagType.Special then --特殊装备背包 
		return PackUpdater.handleBagSpecialAmountChange(args)
	elseif bagType == BagType.Equip then --道具装备背包
		return PackUpdater.handleBagEquipAmountChange(args)
	elseif bagType == BagType.HeroComponent then --卡牌碎片
		return PackUpdater.handleBagHeroCompAmountChange(args)
	end
end

-- 物品背包物品数量变化时调用，细分事件，规范添加
function PackUpdater.handleBagNormalAmountChange(args)
	local itemData = args.itemData
	local itemInfo = itemData:getItemInfo()
	local itemCategory = itemData:getCategory()
	local itemType = itemData:getType()

	local event = nil
	-- 根据物品的类型，分发不同的事件
	if ItemsUtil.isNormalEquipment(itemData) then -- 正常的装备更新
		event = EventType.ITEM_NORMAL_EQUIPMENT
	elseif ItemsUtil.isFashionMaterial(itemData) then
		event = EventType.FASHION_MATERIAL 
	end

	return event
end

function PackUpdater.handleBagSpecialAmountChange(args)
	local itemData = args.itemData
	local itemInfo = itemData:getItemInfo()
	local itemCategory = itemData:getCategory()
	local itemType = itemData:getType()
	local event = nil
	
	-- 根据物品的类型，分发不同的事件
	if ItemsUtil.isPetSwallowMaterial(itemData) then
		event = EventType.ITEM_PET_SWALLOW_MATERIAL
	elseif ItemsUtil.isFashionStoneMaterial(itemData) then
		event = EventType.FASHION_STONE_MATERIAL
	end
	
	return event
end

function PackUpdater.handleBagEquipAmountChange(args)
	local itemCode = args.itemCode
	local itemData = ItemData.new {code = itemCode}

	local itemInfo = itemData:getItemInfo()
	local itemCategory = itemData:getCategory()
	local itemType = itemData:getType()

	local event = nil

	if ItemsUtil.isWing(itemData) then
		event = EventType.EQUIP_WING_UPDATE

	end
	return event
end

function PackUpdater.handleBagHeroCompAmountChange(args)
	local itemCode = args.itemCode
	local itemData = ItemData.new {code = itemCode}

	local itemInfo = itemData:getItemInfo()
	local itemCategory = itemData:getCategory()
	local itemType = itemData:getType()

	local event =nil

	if ItemsUtil.isFate(itemData) then
		event = EventType.EQUIP_WING_UPDATE
	end
	return event
end

return PackUpdater