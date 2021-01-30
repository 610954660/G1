local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local ActATourGiftModel = class("ActATourGiftModel",BaseModel)
--一番巡礼
function ActATourGiftModel:ctor()
	self.moduleId = 1
	self.actType = GameDef.ActivityType.ElfHis
	self.data = {}
	self.aniFlag = false
	self.tempData = false
end

function ActATourGiftModel:setTourTempCode()
    if self.data.wish> 0 then
		self.tempData = self:getCodeById(self.data.wish)
    else
        self.tempData = false
    end
end

function ActATourGiftModel:getTourTempCode()
    return  self.tempData 
end

function ActATourGiftModel:getAniFlag(  )
	self.aniFlag = FileCacheManager.getBoolForKey("atourGift",false)
	return self.aniFlag
end

function ActATourGiftModel:setAniFlag(flag )
	self.aniFlag = flag
	FileCacheManager.setBoolForKey("atourGift",self.aniFlag)
end

--获取对应的模块ID
function ActATourGiftModel:getModuleId()
  local moduleId = 1
  local actData = ModelManager.ActivityModel:getActityByType(self.actType)
  moduleId = actData and actData.showContent.moduleId or 1
  return moduleId
end

function ActATourGiftModel:getActivityId( )
	local viewData = ActivityModel:getActityByType( self.actType )
	return viewData.id
end

--设置数据
function ActATourGiftModel:setData( data )
	self.data = data
	-- printTable(1,self.data)
	self.moduleId  = self:getModuleId()
	Dispatcher.dispatchEvent(EventType.ActATourGiftView_refresh)
end


--获取精灵大奖池
function ActATourGiftModel:getWishPool()
	return self.data.wishPool
end

function ActATourGiftModel:getLimitbyCode( code )
	if self.data.wishPool and self.data.wishPool[code] then
		return self.data.wishPool[code].limit
	end
	return 0
end


function ActATourGiftModel:getData( ... )
	return  self.data
end

function ActATourGiftModel:getLastAwardShow(  )
	local showConfig = {}
	local showConfig2 = {}
	local config = DynamicConfigData.t_ElfOneDrop[self.moduleId]
	if self.data.pool and #self.data.pool>0 then
		for k,v in pairs(self.data.pool) do
			for i2,v2 in pairs(config) do
				if tonumber(v2.row) == 1 and v2.id == v then
					table.insert(showConfig,v2.reward[1])
					break
				end
				if tonumber(v2.row) == 2 and v2.id == v then
					table.insert(showConfig2,v2.reward[1])
					break
				end
			end
		end
	end
	return showConfig,showConfig2
end

--获取单抽 10抽配置
function ActATourGiftModel:getOneDrawConfig(num)
	local config =  DynamicConfigData.t_ElfOneDraw[self.moduleId]
	if config then
		return config[num]
	end
end


function ActATourGiftModel:getElfOneShowText(  )
	local config =  DynamicConfigData.t_ElfOneShow[self.moduleId]
	return config.desc
end

--获取可选心愿道具配置
function ActATourGiftModel:getOneChooseConfig(  )
	local arr = {}
	local config = DynamicConfigData.t_ElfOneChoose[self.moduleId]
	for i,v in pairs(config) do
		table.insert(arr,v)
	end
	arr = TableUtil.sortBy(arr, "id", true)
	return arr
end


function ActATourGiftModel:getCodeById(id)
	local config = DynamicConfigData.t_ElfOneChoose[self.moduleId]
	for i,v in pairs(config) do
		if v.id == id then
			return v.reward[1]
		end
	end
	return 0
end


--红点检测  只有10抽 页签才有红点
function ActATourGiftModel:checkRedot()
	RedManager.updateValue("V_ACTIVITY_"..self.actType,false)
	local keyArr = {}
	-- table.insert(keyArr,"V_ACTIVITY_"..self.actType.."_hadFlag")
	-- table.insert(keyArr,"V_ACTIVITY_"..self.actType.."_dan")
	table.insert(keyArr,"V_ACTIVITY_"..self.actType.."_shi")
	
	RedManager.addMap("V_ACTIVITY_" ..self.actType, keyArr)

	local config = self:getOneChooseConfig(  )
	GlobalUtil.delayCallOnce("ActATourGiftModel:checkRedot", function ()
		-- RedManager.updateValue("V_ACTIVITY_"..self.actType.."_hadFlag",false)
		Dispatcher.dispatchEvent(EventType.ATourRed_panelCheck,{1,false})
		for i=1,#config do
			local hadNum = self:getLimitbyCode( config[i].id )
			local limit = config[i].limit
			if hadNum<limit and  self.data.wish and self.data.wish<=0 then
				-- RedManager.updateValue("V_ACTIVITY_"..self.actType.."_hadFlag",true)
				Dispatcher.dispatchEvent(EventType.ATourRed_panelCheck,{1,true})
				break
			end
		end
		local config =self:getOneDrawConfig(1)
		local cost = config.costItem
		local hadItemNum = PackModel:getItemsFromAllPackByCode(cost[1].code)
		if hadItemNum >=1 then
			-- RedManager.updateValue("V_ACTIVITY_"..self.actType.."_dan",true)
			Dispatcher.dispatchEvent(EventType.ATourRed_panelCheck,{2,true})
		else
			-- RedManager.updateValue("V_ACTIVITY_"..self.actType.."_dan",false)
			Dispatcher.dispatchEvent(EventType.ATourRed_panelCheck,{2,false})
		end
		if hadItemNum >=10 then
			RedManager.updateValue("V_ACTIVITY_"..self.actType.."_shi",true)
		else
			RedManager.updateValue("V_ACTIVITY_"..self.actType.."_shi",false)
		end
	end, self, 0.5)
end
	
	
	
return ActATourGiftModel