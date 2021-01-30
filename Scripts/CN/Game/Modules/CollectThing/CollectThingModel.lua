-- added by wyz
-- 集物活动

local CollectThingModel = class("CollectThingModel", BaseModel)
local band = bit.band
local lshift = bit.lshift

function CollectThingModel:ctor()
	self.collectData = {} 
	self.__taskOdm = {} 	-- 每日任务
	self.__taskOnd = {} 	-- 整个活动期间只能完成一次的任务
	self.collectId = false
	self.collectInfoData = false   -- 活动的详细数据
	self.collectEndTime = false 	-- 活动结束时间
	self.showData  	= {}
	self.shopInfo 	= {} 	-- 商品信息
end

-- 初始化集物兑换商店数据
-- # 新英雄商店
-- .PActivity_NewHeroShop {
-- 	buyRecords		1:*PNewHeroShopRecord(id)
-- }
function CollectThingModel:initShopData(data)
    self.shopInfo = data.buyRecords or {}
    Dispatcher.dispatchEvent(EventType.CollectThingShopView_refreshPanel)
end

-- 获取商品数据
function CollectThingModel:getShopData()
    local moduleId = self:getModuleIdByType(GameDef.ActivityType.CollectThingsShop)
    local shopData = DynamicConfigData.t_CollectThingsShop[moduleId]
    for k,v in pairs(shopData) do
        local data = self.shopInfo[v.id]
        if v.limit == 0 then
            v.buyTime   =  -1
        else
            v.buyTime   = v.limit
        end
        if data and v.limit~=0 then
            data.count = data.count or 0
            v.buyTime = v.buyTime - data.count
            if v.buyTime < 0 then
                v.buyTime = 0
            end
        end
    end
    return shopData or {}
end

-- 获取模板id
function CollectThingModel:getModuleIdByType(type)
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(type)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end


function CollectThingModel:initData(data,id)
	self.__taskOdm = {} 	-- 每日任务
	self.__taskOnd = {}
	self.collectData = {} 
	self.collectData = data
	if id then
		self.collectId = id
	end
	self.__taskOdm = data.dailyRecords or {} 			-- 每日任务
	self.__taskOnd = data.hasRecords  or {}			-- 整个活动期间只能完成一次的任务
	self:check_redDot()
	Dispatcher.dispatchEvent(EventType.CollectThingView_upData)
end

function CollectThingModel:initActivityEnd(data)
	self.collectInfoData = data
	self.collectEndTime = data.realEndMs/1000
end

function CollectThingModel:check_redDot()
	local keyArr = {}
	local data = self:getAllShowTask()
	for i = 1, #data do
		table.insert(keyArr,"V_ACTIVITY_".. GameDef.ActivityType.CollectThings.."_" .. i)
	end
	RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.CollectThings, keyArr)

	-- printTable(999,"self.showData",data)
	for i = 1, #data do
		local d = data[i]
		if (d.finish) and (not d.got) then
			RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.CollectThings.."_" .. i, true)
		else
			RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.CollectThings.."_" .. i, false)
		end
	end
end

function CollectThingModel:getCollectThingId()
	return self.collectId
end

function CollectThingModel:getCollectData()
	return self.collectData
end

-- type 1（每日任务） 2（一次性任务）
function CollectThingModel:setAllShowTask(type)
	local configData = {}
	if self.collectData then
		local config = type == 1 and DynamicConfigData.t_CollectThingsTask or DynamicConfigData.t_CollectThingOnceTask
		for i,v in pairs(config) do
			table.insert(configData,v)
		end
	end

	local allData = type == 1 and self.__taskOdm or self.__taskOnd 		-- 服务端下推的任务状态
	if (allData) and (TableUtil.GetTableLen(allData) ~= 0)then
		for i = 1,#configData do
			local firstData = false -- 存储第一条数据
			local haveData 	= false -- 判断有没有数据 没有使用第一条数据
			for k,v in pairs(configData[i]) do
				if not firstData then
					firstData = v 
					firstData.type = type
				end
				for m,n in pairs(allData) do
					if k == m then
						if not n.got then
							haveData = true
							v.got = n.got
							v.acc = n.acc
							v.finish = n.finish
							v.type = type 
							table.insert(self.showData,v)
							break
						elseif (not configData[i][k+1]) then
							haveData = true
							v.got = n.got
							v.acc = n.acc
							v.finish = n.finish
							v.type = type 
							table.insert(self.showData,v)
							break
						end
					end
				end
				if haveData then break end
			end
			-- 没有数据 默认拿第一条数据
			if not haveData then
				table.insert(self.showData,firstData)
			end
		end
	else
		for i = 1,#configData do
			for k,v in pairs(configData[i]) do
				if type == 1 then
					v.acc = false
					v.finish = false
					v.got = false
				end
				table.insert(self.showData,v)
				break
			end
		end
	end
end

function CollectThingModel:getAllShowTask()
	self.showData = {}
	self:setAllShowTask(2)
	self:setAllShowTask(1)
	-- 给要显示的任务重新索引
	for i = 1,#self.showData do
		self.showData[i].index = i
	end
	table.sort(self.showData,function(a,b)
		if (not a) or (not b) then return end
		local status1 = a.got    and 1 or 0  	-- 1已领取  0未领取
		local status2 = b.got 	 and 1 or 0
		local finish1 = a.finish and 1 or 0 	-- 1完成 0未完成
		local finish2 = b.finish and 1 or 0
		if (not a.got) and (not b.got) then
			if finish1 == finish2 then
				return a.index < b.index 
			else
				return finish1 > finish2
			end
		else
			return status1 < status2
		end
	end)
	return self.showData
end

-- 获取任务完成状态
function CollectThingModel:updateRewardStatus(updateInfo)
	if (updateInfo.gamePlayType ~= GameDef.GamePlayType.ActivityCollectThingsDaily) 
		and (updateInfo.gamePlayType ~= GameDef.GamePlayType.ActivityCollectThingsHas) then
		return
	end
	if updateInfo.gamePlayType == GameDef.GamePlayType.ActivityCollectThingsDaily then
		if not self.__taskOdm then return end
		local data = updateInfo
		self.__taskOdm[data.recordId] 	  =  self.__taskOdm[data.recordId] or {}
		self.__taskOdm[data.recordId].got =  data.got
	else
		if not self.__taskOnd then return end
		local data = updateInfo
		self.__taskOnd[data.recordId] 	  =  self.__taskOnd[data.recordId] or {}
		self.__taskOnd[data.recordId].got =  data.got
	end
	self:check_redDot()
	Dispatcher.dispatchEvent(EventType.CollectThingView_upData)
end

-- 获取任务完成次数
function CollectThingModel:updateProgress(updateInfo)
	if (updateInfo.gamePlayType ~= GameDef.GamePlayType.ActivityCollectThingsDaily) 
		 and (updateInfo.gamePlayType ~= GameDef.GamePlayType.ActivityCollectThingsHas) then
		return
	end

	if updateInfo.gamePlayType == GameDef.GamePlayType.ActivityCollectThingsDaily then
		if not self.__taskOdm then return end
		local data = updateInfo
		self.__taskOdm[data.recordId] 		 	 =  self.__taskOdm[data.recordId] or {}
		self.__taskOdm[data.recordId].recordId 	 =  data.recordId
		self.__taskOdm[data.recordId].acc 	 	 =  data.acc
		self.__taskOdm[data.recordId].finish 	 =  data.finish and data.finish or self.__taskOdm[data.recordId].finish
	else
		if not self.__taskOnd then return end
		local data = updateInfo
		self.__taskOnd[data.recordId] 			 =  self.__taskOnd[data.recordId] or {}
		self.__taskOnd[data.recordId].recordId 	 =  data.recordId
		self.__taskOnd[data.recordId].acc 		 =  data.acc
		self.__taskOnd[data.recordId].finish 	 = 	data.finish and data.finish or self.__taskOnd[data.recordId].finish
	end
	self:check_redDot()
	Dispatcher.dispatchEvent(EventType.CollectThingView_upData)
end

return CollectThingModel