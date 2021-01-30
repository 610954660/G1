--道具帮助类 added by xhd
local BagType = GameDef.BagType
local ItemType = GameDef.ItemType
local Category = GameDef.Category
local ItemsUtil = {}
local TableUtil = require "Game.Utils.TableUtil"
--工厂化创建对应道具类型对象
function ItemsUtil.createItemData(dataInfo)
     --if(dataInfo.type==ItemType.Shoes) then
     	--local itemClass = require "Game.Modules.Pack.ItemShoes"
         --return itemClass.new()
     --elseif(dataInfo.type==ItemType.Weapon) then
     	--local itemClass = require "Game.Modules.Pack.ItemWeapon"
         --return itemClass.new()
     --else
       --策划的配置类型需要转换成对应的道具表code
        local newData = TableUtil.DeepCopy(dataInfo)
        if newData.data.type==1 then
        	newData.data.code =1  --经验
		elseif newData.data.type ==2 and newData.data.code<=100  then
			newData.data.code = (2000 + newData.data.code)
		elseif newData.data.type ==5 and newData.data.code<=100  then
			newData.data.code = (5000 + newData.data.code)
        end
    	local itemClass = require "Game.Modules.Pack.ItemBase"
    	return itemClass.new(newData)
     --end
end

--获取与itemCode对应的unbindCode
function ItemsUtil.getUnbindCode(itemCode)
	return itemCode - itemCode % 10000 + itemCode % 1000
end

--获取与itemCode对应的bindCode
function ItemsUtil.getBindCode(itemCode)
	return ItemsUtil.getUnbindCode(itemCode) + 1000
end

function ItemsUtil.isBindCode(itemCode)
	return itemCode == ItemsUtil.getBindCode(itemCode)
end

function ItemsUtil.getDesc(itemInfo)
	local str = itemInfo.descStr

	if str and str ~= "" then
		str = Desc.itemtips_shuoming .. str
	end

	if itemInfo.usageDesc and itemInfo.usageDesc ~= "" then
		str = str .. "\n" .. Desc.itemtips_fangfa .. itemInfo.usageDesc
	end

	if itemInfo.gainDesc and itemInfo.gainDesc ~= "" then
		str = str .. "\n" .. Desc.itemtips_tujing .. itemInfo.gainDesc
	end

	return str
end

-- 时效性道具
function ItemsUtil.isTimeItem(itemData)
	local itemInfo = itemData:getItemInfo()
	return itemInfo.existTime and itemInfo.existTime > 0
end


--添加cost到一个cost列表（如果原来有了，加到amount，没有的话直接加在后面）
function ItemsUtil.addCost(costList, cost)
	
	for _,v in ipairs(costList) do
		if v.type == cost.type and v.code == cost.code then
			v.amount =v.amount + cost.amount
			return costList
		end
	end
	table.insert(costList, cost)
	return costList
end


return ItemsUtil