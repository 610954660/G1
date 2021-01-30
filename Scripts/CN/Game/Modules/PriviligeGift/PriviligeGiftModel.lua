-- added by wyz
-- 特权购买
local PriviligeGiftConfiger = require "Game.ConfigReaders.PriviligeGiftConfiger"
local PriviligeGiftModel = class("PriviligeGiftModel", BaseModel)

function PriviligeGiftModel:ctor()
	self.dataStatic  = {} 	-- 特权列表的所有数据 静态数据
	self.dataDynamic = {} 	-- 服务端返回的数据
	self.one 		 = true -- 判断是不是第一次接收服务端数据
	self.timer 		 = {} 	-- 计数器个数 判断不同特权的重置时间
	self.currentTimer = {}  -- 特权结束时间和当前服务器时间的时间差
	self.giftNum 	 = {} 	-- 判断礼包个数有没有发生改变 发生改变显示红点
	self:getStaticData()
	for i = 1, #self.dataStatic do
		self.timer[i] = false
		self.currentTimer[i] = false
	end
	self:initListeners()
	self.canBuy = false --是否可以购买（主界面上会根据这个变量决定是否显示特权按钮）
	self.hasCheckRed = false  --上线后是否已经检查过显示红点了
end

-- 获取特权列表的静态数据
function PriviligeGiftModel:getStaticData()
	self.dataStatic = DynamicConfigData.t_PriviligeGift
	-- self:setDataLimit()
	local data = self.dataStatic
	return data
end

-- 获取需要显示的列表数据
function PriviligeGiftModel:getShowData()
	local listData = {}
	for _,v in ipairs(DynamicConfigData.t_PriviligeGift) do
		local tips =  ModuleUtil.getConditionTip(v)
		if not tips and v.show==1 then
			table.insert(listData, v)
		end
	end
	
	return listData
end

-- 获取礼包状态
function PriviligeGiftModel:getPriviligeGift(type)
	local data = self.dataDynamic.privilegeList
	if data then
		for i = 1,#data do
			if data[i].type == type then
				return data[i].state
			end
		end
	end
	return false
end

function PriviligeGiftModel:getPriviligeGiftById(id)
	local time =0
	local state=false
	local data = self.dataDynamic.privilegeGift
	if data then
		for i = 1,#data do
			if data[i].id == id then
				local ServerTime = ServerTimeModel:getServerTime()
				time=(data[i].resetTime - ServerTime)
				if  time> 0 then
					state=true
				end
			end
		end
	end
	return state,time
end





-- 获取礼包时间
function PriviligeGiftModel:getPriviligeDesc()
	local format_normal = "%d"
	local str=""
	local configInfo= DynamicConfigData.t_PriviligeGift
	local function getId(id)
		for key, value in pairs(configInfo) do
			if id==value.id then
				return value
			end
		end
	end
	local state1,remingTime1= self:getPriviligeGiftById(1)--快速行动特权
	local state6,remingTime6= self:getPriviligeGiftById(6)--快速行动特权
	if state6 and not state1  then
		 local giftName=getId(6).giftName
		 local time6 =remingTime6
		str=string.format( "%s%s天",giftName,ColorUtil.formatColorString1(math.ceil(time6/86400),"#6AFF60"))
	elseif state6 and state1 then
		local giftName=getId(6).giftName
		local time6 =remingTime6
	   str=string.format( "%s%s天",giftName,ColorUtil.formatColorString1(math.ceil(time6/86400),"#6AFF60"))
	elseif not state6 and state1 then
		local giftName=getId(1).giftName
		local time1 =remingTime1
	   str=string.format( "%s%s天",giftName,ColorUtil.formatColorString1(math.ceil(time1/86400),"#6AFF60"))
	end	
	return str
end


-- 购买礼包时的时间戳减去当前时间戳 为零时更新红点
function PriviligeGiftModel:getTimeSub()
	local data = self.dataDynamic.privilegeGift
	for idx in pairs(data) do
		if not self.timer[idx] and data[idx].resetTime > 0 then
			local callbackInterval = 1  
			local function docallback()
				local ServerTime = ServerTimeModel:getServerTimeMS() * 0.001
				self.currentTimer[idx] = data[idx].resetTime - ServerTime
				if self.currentTimer[idx] <= 0 then
					self:requestPriviligeGiftData()
					self.currentTimer[idx] = false
					if self.timer[idx] then
						Scheduler.unschedule(self.timer[idx])
        				self.timer[idx] = false
					end
				end
			end
			self.timer[idx] =  Scheduler.schedule(docallback, callbackInterval)
		end
	end
end



-- 设置礼包介绍信息
function PriviligeGiftModel.setStaticDataDec(str)
	local newEff = string.format(Desc.privilige_limit, string.match(str, "+%d+"))
    local richText = string.gsub(str, "+%d+", newEff, 1)
    return richText
end

-- 设置限制文本的信息
function PriviligeGiftModel:setDataLimit()
	local cfg = {Desc.privilege_week,Desc.privilege_month,Desc.privilege_permanent}
	for idx in pairs(self.dataStatic) do
		local info = self.dataStatic[idx]
		info.limt = cfg[idx]
	end
end

-- 获取某种特权的剩余时间
function PriviligeGiftModel:getGiftLeaveTime(id)
	return self.currentTimer and self.currentTimer[id] or 0
end

function PriviligeGiftModel:getGiftStatusById( id )
	if self.dataDynamic and self.dataDynamic.privilegeGift then
		if self.dataDynamic.privilegeGift[id] then
			if self.dataDynamic.privilegeGift[id].buyTime >0 then
				return true
			end
		end
	end
	return false
end

-- -- 从服务端获取礼包的信息
function PriviligeGiftModel:getDataDynamic(data)
	self.dataDynamic = data

	for idx,v in pairs(data.privilegeGift) do
		-- LuaLogE(idx)
		local selfData = self.dataStatic[idx]
		if not selfData then return  end
		local confData = data.privilegeGift[selfData.id]
		if (confData) then
			local limitNum = selfData.buyTime - confData.buyTime
			limitNum = limitNum < 0 and 0 or limitNum
			self.dataStatic[idx].limitNum = limitNum
			self.dataStatic[idx].state 	  = 1
			self.dataStatic[idx].reType2   = 99999
			if self.dataStatic[idx].reType ~= -1 then
				self.dataStatic[idx].reType2 = self.dataStatic[idx].reType
			end
			if limitNum == 0 then 	-- 购买完了
				self.dataStatic[idx].state = 99999
			elseif self.dataStatic[idx].reType == -1 then
				self.dataStatic[idx].state = 88888 	--永久限购的
			else 	-- 周月限购的
				self.dataStatic[idx].state = self.dataStatic[idx].reType
			end
			if confData.resetTime > 0 then
				self:getTimeSub()
			end
		end
	end
	if self.one then
		self.giftNum[1] = #data.privilegeGift
	end
	self.giftNum[2] = #data.privilegeGift
	self:setDataList()
	self:updateRed()
	
	Dispatcher.dispatchEvent("PriviligeGift_upGiftData")
	Dispatcher.dispatchEvent("update_ActivateCtrl")
end

-- 请求特权礼包数据
function PriviligeGiftModel:requestPriviligeGiftData()
	RPCReq.Privilege_SendInfo({})
end

-- 列表排序
function PriviligeGiftModel:setDataList()
	local keys ={
		{key = "state",asc = false},
		{key = "reType2",asc = false},
		{key = "id",asc = false},
	}
	TableUtil.sortByMap(self.dataStatic,keys)
	-- table.sort( self.dataStatic, function(a,b) 
	-- 	if #self.dataStatic < 4 then
	-- 		return a.id < b.id
	-- 	else
	-- 		if a.limitNum and b.limitNum and a.limitNum ~= b.limitNum then
	-- 			return a.limitNum > b.limitNum
	-- 		else
	-- 			return a.id < b.id
	-- 		end
	-- 	end
	-- end)
end


-- 更新红点
function PriviligeGiftModel:updateRed()
	local isCanbuy = false
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("PriviligeGiftView_isShow" .. dayStr,false)
	for idx in pairs(self.dataStatic) do
		local data = self.dataStatic[idx]
		if data.limitNum > 0 and not self:getGiftStatusById(idx) then
			isCanbuy = true
			break
		end
	end
	isCanbuy =(not isShow) and isCanbuy
	self.canBuy = isCanbuy
	Dispatcher.dispatchEvent(EventType.mainui_updateLeftTopBtns)
	--上线后只检查一次(上线后只显示一次红点，点击后消失)
	if not self.hasCheckRed then 
		self.hasCheckRed = true
		RedManager.updateValue("V_PRIVILIGEGIFT", isCanbuy)
	end
end

-- 监听钻石变化
-- function PriviligeGiftModel:money_change()
-- 	self:updateRed()
-- end

return PriviligeGiftModel