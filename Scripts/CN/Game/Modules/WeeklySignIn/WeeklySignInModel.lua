local WeeklySignInModel = class("WeeklySignInModel",BaseModel)

function WeeklySignInModel:ctor()
	self.data = {}
	self.indexDay = 1 -- 签到索引
	self.state = 0  --领取状态
	self.takeIndex = false
	self.time  = false --上次签到时间戳
end

function WeeklySignInModel:initData(data)
    printTable(8848,">>.data>>>",data)
    self.data = data or {}
	self.state = data.state or 0
	self.time = data.time or 0
    self.indexDay = data.indexDay or 0
    self:getTakeIndex()
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.WeeklySignInView_refreshPanal)
end

function WeeklySignInModel:sortData()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.WeekLogin)
    if not actData then return end
    local myData = DynamicConfigData.t_WeekLoginActivity[actData.showContent.moduleId]
    if not myData then return end

    -- for k,v in pairs(myData) do
    --     if self.indexDay >= v.day then
	-- 		local flag = bit.band(self.state, bit.lshift(1, v.day - 1)) > 0
    --         if not flag then
    --             v.take = 1 -- 可领取
    --         else
    --             v.take = 3 -- 已领取
    --         end
    --     else
    --         v.take = 2 -- 不可领取
    --     end
    -- end
    -- local keys ={
    --     {key = "take",asc = false},
    --     {key = "id",asc = false},
    -- }
    -- TableUtil.sortByMap(myData, keys)
    return myData
end

function WeeklySignInModel:redCheck()
	GlobalUtil.delayCallOnce("WeeklySignInModel:redCheck",function()
        self:updateRed()
	end, self, 0.1)
end

function WeeklySignInModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.WeekLogin)
    if not actData then return end
    local myData = {}
    myData = self:sortData()
    if not myData then return end

    local dayStr = DateUtil.getOppostieDays()
    local isShow = FileCacheManager.getBoolForKey("WeeklySignInView_isShow" .. dayStr,false)
    local keyArr={}
    for i=1,#myData do
        local data = myData[i]
        table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.WeekLogin..data.day)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin, keyArr)

    local isTake = true

    for i=1,#myData do
        local data =myData[i]
        if self.indexDay >= data.day then
            local flag = bit.band(self.state, bit.lshift(1, data.day - 1)) > 0
            if not flag then
				-- if not self.takeIndex then self.takeIndex = data.day end
				if self.indexDay >= data.day then 
                    isTake = false 
                    printTable(8848,"self.indexDay>>>>>>>>",self.indexDay)
					RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin..data.day, true)
				else
					RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin..data.day, false)
				end
			else
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin..data.day, false)
            end
        else
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin..data.day, false)
        end
    end
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.WeekLogin, (not isShow) or (not isTake))
	
end

function WeeklySignInModel:getTakeIndex()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.WeekLogin)
    if not actData then return end
    local myData = {}
    myData = self:sortData()
    if not myData then return end
    for i=1,#myData do
        local data =myData[i]
        if self.indexDay >= data.day then
            local flag = bit.band(self.state, bit.lshift(1, data.day - 1)) > 0
            if not flag then
				if not self.takeIndex then self.takeIndex = data.day end
            end
        end
    end
end

return WeeklySignInModel