--Date :2020-12-17
--Author : generated by FairyGUI
--Desc : 

local BloodAbyssModel = class("BloodAbyss", BaseModel)

function BloodAbyssModel:ctor()
    self.boss = {}
    self.allScore = 0
    self.allHurt = 0
    self.times = 0
    self.totalTimes = 5
    self.myRank = 100
    self.curBoss = false
    self.myRankData = {}
    self.rewards = {}
    self.rankBossInfo = false
    self.isSend = false
    self.isFirst = true
    self.todayTime = 5
end

function BloodAbyssModel:init()

end

function BloodAbyssModel:initData(data)
    printTable(33,"BloodAbyssModel:initData(data)",data)
    
    local moduleId = self:getModuleId()
    
    self.times = data.times or 0
    self.totalTimes = data.totalTimes or 0
    if data.boss and next(data.boss) then
        self.boss = data.boss
        for i=1,3 do
            if not self.boss[i] then
                self.boss[i] = {bossId = i,difficulty = 1,maxScore = 0,maxHurt = 0,totalScore = 0,totalHurt = 0}
            else
                self.boss[i].bossId     = self.boss[i].bossId or i
                self.boss[i].difficulty = self.boss[i].difficulty or 1
                self.boss[i].maxScore   = self.boss[i].maxScore or 0
                self.boss[i].maxHurt    = self.boss[i].maxHurt or 0
                self.boss[i].totalScore = self.boss[i].totalScore or 0
                self.boss[i].totalHurt  = self.boss[i].totalHurt or 0
            end
        end
    else
        self.boss = {
            {bossId = 1,difficulty = 1,maxScore = 0,maxHurt = 0,totalScore = 0,totalHurt = 0},
            {bossId = 2,difficulty = 1,maxScore = 0,maxHurt = 0,totalScore = 0,totalHurt = 0},
            {bossId = 3,difficulty = 1,maxScore = 0,maxHurt = 0,totalScore = 0,totalHurt = 0},
        }
    end

    
    local t_reward = DynamicConfigData.t_BloodAbyssReward[moduleId]
    local dreward = data.reward or {}
    self.rewards = {}
    for i=1,#t_reward do
        self.rewards[i] = {}
        self.rewards[i].times = t_reward[i].times
        self.rewards[i].reward = t_reward[i].reward
        if self.totalTimes >= self.rewards[i].times then
            self.rewards[i].status = dreward[t_reward[i].times] and dreward[t_reward[i].times].status or 2
        else
            self.rewards[i].status = dreward[t_reward[i].times] and dreward[t_reward[i].times].status or 1
        end
    end


    local config = DynamicConfigData.t_BloodAbyssMonster
    self.allScore = 0
    self.allHurt = 0
    for i=1,3 do 
        local bossCf = self.boss[i]
        bossCf.monsterId = config[bossCf.bossId][bossCf.difficulty].monsterId
        bossCf.heroId = config[bossCf.bossId][bossCf.difficulty].heroId
        bossCf.desc = config[bossCf.bossId][bossCf.difficulty].desc
        self.allScore = self.allScore + bossCf.totalScore
        self.allHurt = self.allHurt + bossCf.totalHurt
    end

    self.todayTime =  DynamicConfigData.t_BloodAbyss[moduleId].times - self.times

    Dispatcher.dispatchEvent("bloodAbyss_updateView")
	
	--需要复制一份保存
	
	self:updateRed()
end

-- 获取模板id
function BloodAbyssModel:getModuleId()
	local moduleId = 1
	local actData = ActivityModel:getActityByType(GameDef.ActivityType.BloodAbyss)
	moduleId = actData and actData.showContent.moduleId or 1
	return moduleId
end

-- 获取活动id
function BloodAbyssModel:getActivityId()

	local activityId = 1
	local actData = ActivityModel:getActityByType(GameDef.ActivityType.BloodAbyss)
	activityId = actData and actData.id or 1
	return activityId
end


-- 获取活动结束时间
function BloodAbyssModel:getEndTime()
	local endTime = 1000
	local actData = ActivityModel:getActityByType(GameDef.ActivityType.BloodAbyss)
	endTime = actData and actData.realEndMs or 1000
	return endTime/1000
end

-- 获取活动状态
function BloodAbyssModel:getStatus()
	local status = 1000
	local actData = ActivityModel:getActityByType(GameDef.ActivityType.BloodAbyss)
    status = actData and actData.status or 1
    local time = 0
    local serverTime = ServerTimeModel:getServerTime()
    if status == 1 then
        local endTime = actData.realEndMs/1000
        if serverTime > endTime then
            status = 3
        elseif serverTime + (actData.showContent.rewardTime or 0) > endTime then
            status = 4
        end
    elseif status == 2 then
        time = actData.realStartMs/1000 + actData.readyTime- serverTime
    end
    return status,time
end

-- 获取当前boss伤害榜名字
function BloodAbyssModel:getCurRankName()
    local rankName = string.split(self.rankBossInfo.rankname,"·")
    return rankName[1]..Desc.bloodAbyss_hurt
end

-- 红点更新
function BloodAbyssModel:updateRed()

    local key1 = "V_ACTIVITY_"..GameDef.ActivityType.BloodAbyss.."battle"
    local key2 = "V_ACTIVITY_"..GameDef.ActivityType.BloodAbyss.."reward"
    local key3 = "V_ACTIVITY_"..GameDef.ActivityType.BloodAbyss.."enter"
    local keyArr = {}
    
	for k,v in pairs(self.rewards) do
        if v.status == 2 then
            table.insert(keyArr, key2)
            RedManager.updateValue(key2 , true)
			break
		end
    end
    
    if #keyArr < 1 then
        RedManager.updateValue(key2 , false)
    end


    if self.todayTime > 0 then
        table.insert(keyArr, key1)
        RedManager.updateValue(key1 , true)
    else
        RedManager.updateValue(key1 , false)
    end

    if #keyArr > 0 then
        table.insert(keyArr, key3)
        RedManager.updateValue(key3 , true)
    else
        RedManager.updateValue(key3 , false)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.BloodAbyss, keyArr)
end

-- 获取排行榜
function BloodAbyssModel:getMyRank(type,collectionId,fun)
    local rankId = 0
    if collectionId then
        rankId = collectionId
    end
    if not self.myRankData[rankId] then 
        self.myRankData[rankId] = {time = 0,rank = 100 }
    end

    local curServerTime = ServerTimeModel:getServerTime() 
    if curServerTime - self.myRankData[rankId].time > 10  then
        printTable(33,"Rank_GetMyRankData",{type = type,collectionId = collectionId})
        RPCReq.Rank_GetMyRankData({rankType = type,collectionId = collectionId},function(data)
            printTable(33,"Rank_GetMyRankData call",data)
            self.myRankData[rankId] = data.rankData
            self.myRankData[rankId].time = curServerTime
            self.myRankData[rankId].rank = self.myRankData[rankId].rank or 0
            if fun then fun(self.myRankData[rankId]) end
            end)
    else
        if fun then fun(self.myRankData[rankId]) end
    end
    
end

-- 保存积分
function BloodAbyssModel:saveScore(save)
    local params = {}
    params.activityId = self:getActivityId()
    params.boss = self.curBoss.bossId
    params.save = save
    RPCReq.Activity_BloodAbyss_Save(params, function()end)
end

return BloodAbyssModel
