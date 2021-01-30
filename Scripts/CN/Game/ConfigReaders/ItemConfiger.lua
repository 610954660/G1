--道具配置读取器
--added by xhd
local ItemConfiger = {}
local Category = GameDef.Category

--[[
根据itemCode获取ItemInfo 
@param	itemCode	[number]	物品code
@return	经过封装后的ItemInfo表
]]
function ItemConfiger.getInfoByCode(itemCode, type)
	itemCode = tonumber(itemCode)
	if not itemCode then
		return
	end
	if not type or type ~= 1 then
		if itemCode<=100  then
			itemCode = (2000 + itemCode)
		end
	end
	local baseInfo = DynamicConfigData.t_item[tonumber(itemCode)]
	if not baseInfo then
		printTable(6,"物品表没有物品信息",itemCode);		
		return
	end
	return baseInfo
end

--获取物品名字，也可以获取金钱的名字 type不传时默认是物品
function ItemConfiger.getItemNameByCode(code, type)
	if type == nil then type = CodeType.ITEM end
	if type == CodeType.EXP then
		return Desc["common_expType"..code]
	elseif type == CodeType.MONEY then
		return Desc["common_moneyType"..code]
	elseif type == CodeType.ITEM then
		local item = ItemConfiger.getInfoByCode(code)
		if item then
			return item.name
		end
	end
	return ""
end

function ItemConfiger.getQualityByCode(code)
	local item = ItemConfiger.getInfoByCode(code)
	return item.color
end

--获取item图标 不适用配置表中的奖励道具
function ItemConfiger.getItemIconByCode(code, type, isCost)
	if isCost and (code <= 100 or code == 10000006 or code == 10000064) then
		return "Icon/money/money"..code..".png"
	end
	local item = ItemConfiger.getInfoByCode(code, type)
	if item then
		return "Icon/item/"..item.icon..".png"
	elseif code then
		return "Icon/item/"..code..".png"
	else
		return ""
	end
end

--获取item图标字符串，可以文本框中显示 不适用配置表中的奖励道具
function ItemConfiger.getItemIconStrByCode(code, type, isCost, width, height)
	local iconPath = ItemConfiger.getItemIconByCode(code, type, isCost)
	if not width then width = 40 end
	if not height then height = 40 end
	if iconPath ~= "" then
		return string.format(Desc.common_ImgStr, iconPath,width,height )
	else
		return ""
	end
end

--获取奖励类型的item图标
function ItemConfiger.getItemIconByCodeAndType(type,code)
	local item = ItemConfiger.getInfoByCodeAndType(type,code)
	if item then
		return PathConfiger.getItemIcon(item.icon)
	end
end

function ItemConfiger.getInfoByCodeAndType(itemType,itemCode)
	if not itemCode then
		return
	end
	if itemType==1 then
		itemCode=itemCode  --经验
	elseif itemType ==2 and itemCode<=100  then
		itemCode = (2000 + itemCode)
	elseif itemType ==4 then
		itemCode = (70000000 + itemCode)
	end
	local baseInfo = DynamicConfigData.t_item[tonumber(itemCode)]
	if not baseInfo then
		printTable(6,"物品表没有物品信息",itemCode);		
		return
	end
	return baseInfo
end

--获取碎片种族
function ItemConfiger.getSplitCategory (itemCode)
	local info = DynamicConfigData.t_heroCombine[itemCode]
	if info then return info.category end
	return 0
end

--获取卡牌种族
function ItemConfiger.getHeroCategory (itemCode)
	local info = DynamicConfigData.t_hero[itemCode]
	if info then return info.category end
	return 0
end

return ItemConfiger
