local M = class("SevenDayActivityModel", BaseModel)
local NewSevenDayConfiger = require("Game.ConfigReaders.NewSevenDayConfiger")
local ActivityType = GameDef.ActivityType
local RecordType = GameDef.RecordType
local band = bit.band
local lshift = bit.lshift

function M:_activityType()
    return ActivityType.SevenDayRecord
end

function M:_configer()
    return NewSevenDayConfiger.new()
end

function M:ctor()
    self.__odmData = false
end

function M:getOdmData()
    return self.__odmData or DT
end

function M:setOdmData(data)
    self.__odmData = data
end

-- 活动的红点Key
function M:getAcitivityReddotKey()
    return string.format("V_ACTIVITY_%d", self:_activityType())
end

-- 积分奖励红点Key
function M:getPointRewardReddotKey(index)
    return string.format("%s_POINTREWARD%d", self:getAcitivityReddotKey(), index)
end

-- 日标签的红点Key
function M:getDayTabReddotKey(day)
    return string.format("%s_DAY%d", self:getAcitivityReddotKey(), day)
end

-- 某个日标签下任务分类标签的红点Key
function M:getTaskTypeTabReddotKey(day, index)
    return string.format("%s_TASKTYPE%d", self:getDayTabReddotKey(day), index)
end

-- 超值礼包页签红点Key
function M:getGoodsTypeTabReddotKey(day)
    return string.format("%s_GOODS", self:getDayTabReddotKey(day))
end

--
function M:mapReddotKeys()
    -- 积分奖励红点Key的映射
    local reddotKeyMapList = {}
    for index = 1, 5 do
        table.insert(reddotKeyMapList, self:getPointRewardReddotKey(index))
    end
    -- 天数红点Key的映射
    -- reddotKeyMapList = {}
    for day = 1, 7 do
        local dayTabReddotKey = self:getDayTabReddotKey(day)
        local taskTypeReddotToDayTabReddot = {}
        for taskType = 1, 3 do
            table.insert(taskTypeReddotToDayTabReddot, self:getTaskTypeTabReddotKey(day, taskType))
        end
        table.insert(taskTypeReddotToDayTabReddot, self:getGoodsTypeTabReddotKey(day))

        RedManager.addMap(dayTabReddotKey, taskTypeReddotToDayTabReddot)
        table.insert(reddotKeyMapList, dayTabReddotKey)
    end
    --
    RedManager.addMap(self:getAcitivityReddotKey(), reddotKeyMapList)
end

-- 获得的总积分
function M:getCurrentTotalPoint()
    return self:getOdmData().pointRecord or 0
end

-- 现在是活动的第几天
function M:getCurrentDay()
    local day = self:getOdmData().curDay or 1
    if day > 7 then
        day = 7
    end
    return day
end

-- 活动结束时间戳
function M:getEndTimeMs()
    return self:getOdmData().endDateStamp or 0
end

-- 某个任务库里的任务是否都“已完成”，这里的“已完成”指的是任务完成且对应的奖励也已领取
function M:haveCompletedAllTask(libraryId)
    local taskList = self:_configer():getTaskList(libraryId)
    for _, config in ipairs(taskList) do
        if self:getTaskStatus(config.taskId) ~= 2 then
            return false
        end
    end
    return true
end

-- 获取某个任务的状态；0：未完成，1：未领取，2：已领取
function M:getTaskStatus(taskId, round)
    round = round or 1
    local u32Index = math.ceil(round / 32)
    local bitIndex = (round - 1) % 32
    local record = self:getOdmData().records[taskId]
    --
    if not record then
        return 0
    end
    local finish = record.finish
    if not finish then
        return 0
    end
    local flagBits = finish[u32Index]
    if not flagBits then
        return 0
    end
    if band(flagBits, lshift(1, bitIndex)) == 0 then
        return 0
    end
    --
    local got = record.got
    if not got then
        return 1
    end
    flagBits = got[u32Index]
    if not flagBits then
        return 1
    end
    if band(flagBits, lshift(1, bitIndex)) == 0 then
        return 1
    end

    return 2
end

-- 获得单个任务的某轮的完成进度，和进度最大值
function M:getTaskProgress(taskId, round)
    round = round or 1
    local task = self:_configer():getTaskDetail(taskId)
    --
    if self:getTaskStatus(taskId, round) ~= 0 then
        return task.batch, task.batch
    end
    --
    for beforeRound = 1, round - 1 do
        if self:getTaskStatus(taskId, beforeRound) == 0 then -- 如果之前有某轮任务没完成，那么当前查询的这轮进度必然为0
            return 0, task.batch
        end
    end
    --
    if task.recordType == RecordType.Level then -- 由于该活动服务端不把RecordType.Level类任务的进度累加到acc中，所以要进行特殊处理
        --
        return math.min(PlayerModel.level, task.batch), task.batch
    elseif task.recordType == RecordType.CopyLevel then -- 爬塔
        local currentPassFloor = ModelManager.PataModel:getPataFloor(2000) - 1
        return math.min(currentPassFloor, task.batch), task.batch
    else
        local record = self:getOdmData().records[taskId]
        if record then
            return (record.acc or 0)-(round-1)*task.batch, task.batch
        else
            return 0, task.batch
        end
    end
end

-- 该任务是否为登陆任务
function M:isLoginTask(taskId)
    if not taskId then
        return false
    end
    local detail = self:_configer():getTaskDetail(taskId)
    if detail.recordType == RecordType.Login then
        return true
    end
    return false
end

-- 获取某个礼包的剩余购买次数和最大购买次数
function M:getGoodsRemainingBuyTimesAndMaxBuyTimes(day, id)
    local maxBuyTimes = self:_configer():getShopGoods(day, id).buyTime
    local dayGiftStatus = self:getOdmData().dayGiftStatus or DT
    dayGiftStatus = dayGiftStatus[day]
    if not dayGiftStatus then
        return maxBuyTimes, maxBuyTimes
    end
    local giftStatus = dayGiftStatus.giftStatus[id]
    if not giftStatus then
        return maxBuyTimes, maxBuyTimes
    end
    return maxBuyTimes-giftStatus.buyTimes, maxBuyTimes
end

-- 获取积分奖励的领取状态：0未满足，1可领取，2已领取
function M:getPointRewardStatus(index)
    local config = self:_configer():getPointRewardList()[index] or DT
    if self:getCurrentTotalPoint() < config.needPoint then
        return 0
    end

    local rewardStatus = self:getOdmData().rewardStatus
    if not rewardStatus then
        return 1
    end
    rewardStatus = rewardStatus[index]
    if rewardStatus and rewardStatus.status then
        return 2
    end

    return 1
end

-- 领取积分奖励
function M:getPointReward(index)
    RPCReq.Activity_SevenDayRecord_GetPointReward({
        index = index,
        activityType = self:_activityType(),
    })
end

-- 购买每日礼包
function M:buyGift(day, id, times)
    times = times or 1
    RPCReq.Activity_SevenDayRecord_BuyRecordGift({
        day = day,
        id = id,
        times = times,
        activityType = self:_activityType(),
    })
end

-- 获得任务奖励
function M:getTaskReward(taskId, round)
    round = round or 1
    RPCReq.Activity_SevenDayRecord_GetRecordReward({
        taskId = taskId,
        seq = round,
        activityType =self:_activityType(),
    })
end

return M
