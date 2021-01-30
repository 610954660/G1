--Date :2021-01-20
--Author : added by xhd
--Desc : --节日活动boss

local ActCommonBossModel = class("ActCommonBoss", BaseModel)

function ActCommonBossModel:ctor()
    self.commonBossShopData = {}
    self:initListeners()
    self.bossData = {}
    self.bossRecord = false
    self.bossResult = {}
    self.actType = GameDef.ActivityType.HolidayBoss
end

function ActCommonBossModel:init()

end

function ActCommonBossModel:setCommonBossShopData(data)
    self.commonBossShopData = data
end
function ActCommonBossModel:getCommonBossShopData()
    return self.commonBossShopData
end

function ActCommonBossModel:getActData()
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HolidayExchange)
	return actData
end

function ActCommonBossModel:setActCommonBossShopRedFirst() --活动出现红点
    local t_HolidayExchange = DynamicConfigData.t_HolidayExchange
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HolidayExchange)
    local moduleId = actData and actData.showContent.moduleId or 1
    local showData = t_HolidayExchange[moduleId]
    local showState = false
    for key,value in pairs(showData) do
        local count = 0
        if self.commonBossShopData.buyRecords and self.commonBossShopData.buyRecords[key] then
            count = self.commonBossShopData.buyRecords[key].count
        end
        local num = ModelManager.PlayerModel:getMoneyByType(value.price[1].code)
        if num > value.price[1].amount and value.reward[1].amount - count > 0 then
            showState = true
            break
        end
    end
    GlobalUtil.delayCallOnce(
    "OperatingActivitiesModel:setActCommonBossShopRedFirst",
    function()
        local dayStr = DateUtil.getOppostieDays()
        local isShow = FileCacheManager.getBoolForKey("setCommonBossShopRedFirst_isShow" .. dayStr, false)
        RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.HolidayExchange, not isShow and showState)
    end,self,0.1)
end


--通用Boss活动
function ActCommonBossModel:getActivityId()
    local viewData = ActivityModel:getActityByType( self.actType )
	return viewData.id
end

function ActCommonBossModel:getModuleId()
    local moduleId = 1
    local actData = ModelManager.ActivityModel:getActityByType(self.actType)
    moduleId = actData and actData.showContent.moduleId or 1
    return moduleId
end

function ActCommonBossModel:getData( ... )
	return  self.bossData
end

function ActCommonBossModel:initBossData( data )
    self.bossData = data
    self:checkRedDot()
    Dispatcher.dispatchEvent(EventType.reflash_CommonBossView)
end


function ActCommonBossModel:getHeroRecommendConfig()
    local config = DynamicConfigData.t_HeroRecommend
    local arr = {}
    for k,v in pairs(config) do
        table.insert(arr,v)
    end
    return arr
end

function ActCommonBossModel:checkIdInArray(code)
    local config = DynamicConfigData.t_HeroRecommend
    for k,v in pairs(config) do
        if tonumber(v.heroCard) == tonumber(code) then
            return true
        end
    end
    return false
end

function ActCommonBossModel:getBossConfig(  )
    return DynamicConfigData.t_HolidayBOSS[1]
end



function ActCommonBossModel:reqBossReCord( )
    local params = {}
    params.activityType = self.actType
    params.onSuccess = function (res )
       if res and  res.records then
          self.bossRecord = res.records
          Dispatcher.dispatchEvent("update_bossView_reCord")
       end
    end
    RPCReq.Activity_HolidayActvity_GetBattleRecord(params, params.onSuccess)
end

function ActCommonBossModel:reqBossBattle(callfunc)
    local params = {}
    params.activityType = self.actType
    params.onSuccess = function (res )
        local data = {}
        data.curNum = res.curNum
        data.maxNum = res.maxNum
        self.bossResult = data
        if callfunc then
            callfunc()
        end
    end
    RPCReq.Activity_HolidayActvity_OnBattle(params, params.onSuccess)
end

--检测红点
function ActCommonBossModel:checkRedDot()
    if self.bossData  and self.bossData.restTimes and self.bossData.restTimes>0 then --有次数
       RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HolidayBoss, true)
    else
        RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HolidayBoss, false)
    end
end

function ActCommonBossModel:reqSaveBossBattle(callfunc)
    local params = {}
    params.activityType = self.actType
    params.onSuccess = function (res )
        if callfunc then
            callfunc()
        end
    end
    RPCReq.Activity_HolidayActvity_OnSaveBattle(params, params.onSuccess)
end


function ActCommonBossModel:getBossResult(  )
    return self.bossResult
end

function ActCommonBossModel:getBossRecordData(  )
	return  self.bossRecord
end

function ActCommonBossModel:getFightSceenNeed( battleData )
    local arr = {}
    local hpMax = 0 
    for i,v in ipairs(battleData.playData.battleObjSeq) do
        if v.type == 2 then
            hpMax = v.hpMax 
            local everyHp = hpMax/DynamicConfigData.t_HolidayBOSS[1].HpNum
            for i = 1, DynamicConfigData.t_HolidayBOSS[1].HpNum do
                table.insert(arr,everyHp)
            end
        end
    end
    return arr,hpMax
end


return ActCommonBossModel
