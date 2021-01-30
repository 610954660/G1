--背包基础数据模型基类
--added by xhd
local BagType = GameDef.BagType
-- local ErrorCode = GameDef.ErrorCode
local Category = GameDef.Category
local ItemUseType = GameDef.ItemUseType
local PackConfiger = require "Game.ConfigReaders.PackConfiger"
local BaseModel = require "Game.FMVC.Core.BaseModel"
local PackBaseModel = class("PackBaseModel",BaseModel)
local PackUpdater = require  "Game.Modules.Pack.PackUpdater"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function PackBaseModel:ctor(params)

	-- 背包类型
	self.__bagType = params.type or 0

	-- 背包容量
	self.__capacity = params.capacity or 0

	-- 累计的时间
	self.__accumulateSecond = params.accumulateSecond or 0

	-- 是否自动分解
	self.__isResolve = params.isResolve or 0

	-- 上一次记录的时间
	self.__lastRecordTime = false

	--当前背包中的物品数量
	self.__itemAmount = 0

	self.__packItems = {} --背包物品,通过id区分

	self.__itemsByIndex = {} --背包物品,通过索引存储

	self.__itemsByCode = {}  --根据物品code查找物品

	self.__itemsByType = {}  --根据类型细分

	self.__itemsByCategory = {} --根据大类细分

	self.__bagConfig = PackConfiger.getPackInfoByType(self.__bagType)
end


function PackBaseModel:clear()
	self.__bagConfig = PackConfiger.getPackInfoByType(self.__bagType)
	self.__itemAmount = 0 --当前背包中的物品数量
	self.__packItems = {} --背包物品,通过id区分
	self.__itemsByIndex = {} --背包物品,通过索引存储
	self.__itemsByCode = {}  --根据物品code查找物品
	self.__itemsByType = {}  --根据类型细分
	self.__itemsByCategory = {} --根据大类细分

end

function PackBaseModel:getPackItems()
	--printTable(1,self.__packItems)
	return  self.__packItems
end

--登录下推背包
function PackBaseModel:setPack(data)
	self:clear()
	for k, v in pairs(data.items) do
		local itemData = ItemsUtil.createItemData({data = v})
		itemData:setBagType(self.__bagType)
		self.__packItems[v.id] = itemData
		self:_addToCodeTable(itemData)
		self.__itemAmount = self.__itemAmount + 1
		self:redCheck(itemData, self.__itemAmount, "init")
	end
	self:initCapacity(data)
	self:initRedMap()
end

function PackBaseModel:initCapacity(data)
	self.__capacity = data.capacity or 0
	self.__accumulateSecond = data.accumulateSecond or 0
	-- self.__lastRecordTime = Cache.serverTimeCache:getServerTime()
	self.__isResolve = data.isResolve or 0
end



function PackBaseModel:getCapacity()
	if self.__capacity == 0 then
		return self.__bagConfig.capacity
	else
		return self.__capacity
	end
end

--是否自动分解
function PackBaseModel:isResolve()
	return self.__isResolve > 0
end

--私有方法
function PackBaseModel:__innerDelete(itemData)
	local posIndex = itemData:getPosIndex()
	local itemId = itemData:getItemId()

	self.__itemsByIndex[posIndex] = nil
	self.__packItems[itemId] = nil

	self:_deleteFromCodeTable(itemData)
	self.__itemAmount = self.__itemAmount - 1
	if self.__itemAmount < 0 then
		self.__itemAmount = 0
	end

	-- itemData:onDestroy()
	return posIndex
end

--增加物品
function PackBaseModel:increateItem(itemData, updateCode)
	local itemId = itemData:getItemId()
	local bagItemData = self:getItemById(itemId)
	local posIndex
	if not bagItemData then  --正常情况都是走这边
		self.__packItems[itemId] = itemData
		posIndex = itemData:getPosIndex()
		if posIndex and posIndex > 0 then
			self.__itemsByIndex[posIndex] = itemData
		else
			self.__itemAmount = self.__itemAmount + 1
			for i = 1, self.__itemAmount do
				if not self.__itemsByIndex[i] then
					posIndex = i
					break
				end
			end
			itemData:setPosIndex(posIndex)
			self.__itemsByIndex[posIndex] = itemData
		end
		self:_addToCodeTable(itemData)
	else
		local preAmount = bagItemData:getItemAmount()
		local afterAmount = preAmount + itemData:getItemAmount()
		bagItemData:setAmount(afterAmount)
	end
	self:redCheck(itemData, itemData:getItemAmount(), "add")
	-- self:__checkAndShowAutoUse(itemData)
	return PackUpdater.itemChange(self.__bagType, itemData, itemData:getItemAmount(), updateCode)
end

--删除物品
function PackBaseModel:deleteItem(itemId, updateCode)
	local bagItemData = self:getItemById(itemId)
	if not bagItemData then
		print(string.format("error item with id:%s not exist!", itemId))
		-- MsgManager.showClientErrorByCode(ErrorCode.ItemNotExist)
		return
	end
	-- self:__checkAndShowAutoUse(bagItemData, 0)
	self:__innerDelete(bagItemData)
	self:redCheck(bagItemData, 0, "del")
	return PackUpdater.itemChange(self.__bagType, bagItemData, -bagItemData:getItemAmount(), updateCode)
end

--更新物品
function PackBaseModel:updateItem(item, updateCode)
	local itemId = item.id
	print(1,"PackBaseModel:updateItem=",itemId)
	local bagItemData = self:getItemById(itemId)
	if bagItemData then
		local posIndex = bagItemData:getPosIndex()
		local preAmount = bagItemData:getItemAmount()
		local itemCode = bagItemData:getItemCode()

		local needUpdate = false
		if not item.code then
			item.code = itemCode
		else
			self:_deleteFromCodeTable(bagItemData)
			needUpdate = true
		end

		local curAmount = item.amount
		if (item.uuid) then
			bagItemData:setData(item) -- 普通道具发生新增 发下来的item没有uuid  这样会把uuid直接抹除掉
		else
			bagItemData.__data.amount = curAmount
		end
		if needUpdate then
			self:_addToCodeTable(bagItemData)
		end
		bagItemData:setPosIndex(posIndex)

		if preAmount < curAmount then
			-- self:__checkAndShowAutoUse(bagItemData)
		end
		
		self:redCheck(bagItemData, curAmount, "update")
		return PackUpdater.itemChange(self.__bagType, bagItemData, curAmount - preAmount, updateCode)
	else
		--printWarning(string.format("error item with id:%s not exist!", itemId))
		-- MsgManager.showClientErrorByCode(ErrorCode.ItemNotExist)
	end
end

function PackBaseModel:getItemByIndex(index)
	return self.__itemsByIndex[index]
end

---@return ItemData[]
function PackBaseModel:getAllItems()
	return self.__itemsByIndex
end

---获得背包所有物品的数据
function PackBaseModel:getAllItemDatas()
	local allItemDatas = {}
	for i, v in pairs(self.__itemsByIndex) do
		local data = v:getData()
		table.insert(allItemDatas, data)
	end
	return allItemDatas
end


function PackBaseModel:getItemAmount()
	return self.__itemAmount
end

function PackBaseModel:getSpace()
	return self:getCapacity() - self:getItemAmount()
end

--判断背包是否已经满了
function PackBaseModel:isFull()
	return self:getSpace() <= 0
end


--查询物品
function PackBaseModel:getItemById(id)
	return self.__packItems[id]
end

-- 获取某些type 的物品
function PackBaseModel:getItemsByTypes(typeDict, excludeIdDict)
	local rlt = {}
	if not typeDict then
		return rlt
	end
	if excludeIdDict then
		for i, v in pairs(self.__packItems) do
			if not excludeIdDict[v:getItemId()] and typeDict[v:getType()] then
				table.insert(rlt, v)
			end
		end
	else
		for i, v in pairs(self.__packItems) do
			if typeDict[v:getType()] then
				table.insert(rlt, v)
			end
		end
	end
	return rlt
end


--根据类型获取物品
function PackBaseModel:getItemsByType(type)
	return self.__itemsByType[type] or {}
end

--根据大类获取物品
function PackBaseModel:getItemsByCategory(category)
	return self.__itemsByCategory[category] or {}
end

function PackBaseModel:_addToCodeTable(itemData)
	local itemCode = itemData:getItemCode()
	local items = self.__itemsByCode[itemCode]
	if not items then
		items = {}
		self.__itemsByCode[itemCode] = items
	end
	items[itemData] = true


	local type = itemData:getType()
	local items = self.__itemsByType[type]
	if not items then
		items = {}
		self.__itemsByType[type] = items
	end
	items[itemData] = true


	local category = itemData:getCategory()
	local items = self.__itemsByCategory[category]
	if not items then
		items = {}
		self.__itemsByCategory[category] = items
	end
	items[itemData] = true
end


function PackBaseModel:_deleteFromCodeTable(itemData)
	local itemCode = itemData:getItemCode()
	local items = self.__itemsByCode[itemCode]
	if items then
		items[itemData] = nil
		if not next(items) then
			self.__itemsByCode[itemCode] = nil
		end
	end

	local type = itemData:getType()
	local items = self.__itemsByType[type]
	if items then
		items[itemData] = nil
		if not next(items) then  --里面没数据了
			self.__itemsByType[type] = nil
		end
	end

	local category = itemData:getCategory()
	local items = self.__itemsByCategory[category]
	if items then
		items[itemData] = nil
		if not next(items) then  --里面没数据了
			self.__itemsByCategory[category] = nil
		end
	end
end


-- 获取背包中某样物品的全部
--[[
	@itemCode 	物品code
	@isBind 	是否绑定，不指定则取指定物品的绑定跟非绑定的总和
]]
function PackBaseModel:getItemsByCode(itemCode, isBind)
	local rlt = {}
	if not itemCode then
		return rlt
	end

	local itemInfo = ItemConfiger.getInfoByCode(itemCode)
	assert(itemInfo, "配置表物品不存在: ".. itemCode)
	if type(isBind) == "boolean" then
		local targetCode = self:getBindOrUnbindCode(itemInfo, isBind)

		local items = self.__itemsByCode[targetCode]
		if not items then
			return rlt
		end

		for k, v in pairs (items) do
			table.insert(rlt, k)
		end

		--isBind 不传则取出绑定跟非绑定物品
	elseif isBind == nil then
		local bindCode = self:getBindOrUnbindCode(itemInfo, true)
		local unBindCode = self:getBindOrUnbindCode(itemInfo, false)

		local bindItems = self.__itemsByCode[bindCode]
		if bindItems then
			for k, v in pairs (bindItems) do
				table.insert(rlt, k)
			end
		end

		local unBindItems = self.__itemsByCode[unBindCode]
		if unBindItems then
			for k, v in pairs (unBindItems) do
				table.insert(rlt, k)
			end
		end
	end

	return rlt
end

--[[获取某物品绑定/不绑定code]]
function PackBaseModel:getBindOrUnbindCode(itemInfo, isBind)
	if itemInfo.bind == 0 then
		if isBind then
			return itemInfo.code + 1000000
		else
			return itemInfo.code
		end
	else
		if isBind then
			return itemInfo.code
		else
			return itemInfo.code - 1000000
		end
	end

	return 0
end

--获取背包中物品数量 
function PackBaseModel:getAmountByCode(itemCode, isBind)
	local amount = 0
	if type(isBind) == "boolean" then
		local items = self:getItemsByCode(itemCode, isBind)
		for k, v in pairs(items) do
			amount = amount + v:getItemAmount()
		end
	elseif isBind == nil then
		local bindItems = self:getItemsByCode(itemCode, true)
		local unBindItems = self:getItemsByCode(itemCode, false)
        -- printTable(1,bindItems)
        -- printTable(1,unBindItems)
		for k, v in pairs(bindItems) do
			amount = amount + v:getItemAmount()
		end

		for k, v in pairs(unBindItems) do
			amount = amount + v:getItemAmount()
		end
	end
	return amount
end

function PackBaseModel:getItemByUuid( code,uuid )
   local data = self:getItemsByCode(code)
   for k,v in pairs(data) do
   	  if v:getUuid() == uuid then
   	  	 return v 
   	  end
   end
   return nil
end

---检查背包是否有足够的物品并返回结果
function PackBaseModel:checkAmountAndReturn(itemCode, needAmount)
	local curAmount = self:getAmountByCode(itemCode)
	return curAmount-needAmount
end

--背包中是否存在某物品
function PackBaseModel:isItemExist(itemCode, isBind)
	local itemInfo = ItemConfiger.getInfoByCode(itemCode)
	if type(isBind) == "boolean" then
		local targetCode = self:getBindOrUnbindCode(itemInfo, isBind)
		local items = self.__itemsByCode[targetCode]
		return items and next(items)

	elseif isBind == nil then
		local bindCode = self:getBindOrUnbindCode(itemInfo, true)
		local unBindCode = self:getBindOrUnbindCode(itemInfo, false)

		local bindItems = self.__itemsByCode[bindCode]
		if bindItems and next(bindItems) then
			return true
		end

		local unBindItems = self.__itemsByCode[unBindCode]
		if unBindItems and next(unBindItems) then
			return true
		end
	end
	return false
end


--自动使用
function PackBaseModel:__checkAndShowAutoUse(itemData, num)
	if PackConfig.cannotAutoUse(self.__bagType) then
		return
	end

	local itemInfo = itemData:getItemInfo()
	local quickUse = itemInfo.quickUse
	local hintViewShow = true

	if ItemsUtil.isOfflineHangUpCard(itemData) then --离线挂机卡
		local offlineData = Cache.settingCache:getOfflineData()
		local maxSec = ConstVars.OfflineHangHpMaxSec
		local sec = offlineData.leftSec or 0
	    if itemData:getItemInfo().effect * 3600 + sec > maxSec then
	        hintViewShow = false
	    end
	end
	
	if ItemsUtil.isCondtGift(itemData) then	--达到开启条件的礼包
		--累充、累计消费达到固定金额时弹出自动使用（得到的时候不弹
		--开启次数的在登陆时判断，今日有使用次数时弹出来
		-- 不满足就不弹
		hintViewShow = false
		if ItemsUtil.isDailyOpenTimesGift(itemData) then
			if ItemsUtil.isGiftMatchCondt(itemData) then
				hintViewShow = true
			end
		end	
	end

	num = num or itemData:getItemAmount()
	if hintViewShow and num > 0 and quickUse == 1 then
		Dispatcher.dispatchEvent(EventType.HINT_VIEW_SHOW, {
			key = tostring(itemData:getItemId()),
			title = "使用",
			btnText = "快捷使用",
			text = itemInfo.name,
			itemData = itemData,
			onClick = function()
				local useType = itemData:getUseType()
				if useType == ItemUseType.CanUseMultiple then
					--烟花庆典礼包
					if ItemsUtil.isFireworkCelebrationGift(itemData) then
						local btn = ItemCellFunction.getUseBtn(itemData)
						if btn and btn.onClick then
							btn.onClick()
						end
					else
						local btn = ItemCellFunction.getBatchUseBtn(itemData)
						if btn and btn.onClick then
							btn.onClick()
						end
					end
				else
					local btn = ItemCellFunction.getUseBtn(itemData)
					if btn and btn.onClick then
						btn.onClick()
					end
				end
			end
		})
	else
		Dispatcher.dispatchEvent(EventType.HINT_VIEW_REMOVE, {
			key = tostring(itemData:getItemId()),
		})
	end
end

--背包数据格式不改变 整理出来提供给页面使用
function PackBaseModel:sort_bagDatas( ... )
	local data = {}
	for k,v in pairs(self.__packItems) do
		 table.insert(data,v)
	end
	--排序
	table.sort(data,function(a,b) 
		if (not a) or (not b) then
			return false
		end
		local aitemInfo = a:getItemInfo()
		local bitemInfo = b:getItemInfo()
		if (not aitemInfo) or (not bitemInfo) then
			return false
		end
		local asortFirst = 0
		local bsortFirst = 0
		if  type(aitemInfo.sortFirst) =="number" then
			asortFirst = aitemInfo.sortFirst
		else
			asortFirst = 0
		end

		if type(bitemInfo.sortFirst) =="number" then
			bsortFirst = bitemInfo.sortFirst	
		else
			bsortFirst = 0
		end
		if asortFirst == bsortFirst then
			if aitemInfo.color == bitemInfo.color then
				return aitemInfo.code < bitemInfo.code
			else
				return aitemInfo.color > bitemInfo.color
			end
		else
			return asortFirst>bsortFirst
		end
	end)
	return data
end

function PackBaseModel:initRedMap(t)
	--初始化红点关系（背包信息下推后执行）
end

function PackBaseModel:redCheck(itemData, curAmount, updateType)
	--红点检测
end


return PackBaseModel
