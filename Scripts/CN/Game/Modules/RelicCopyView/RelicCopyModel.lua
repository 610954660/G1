local BaseModel = require "Game.FMVC.Core.BaseModel"
local RelicCopyModel = class("RelicCopyModel", BaseModel)

function RelicCopyModel:ctor()
end
function RelicCopyModel:init()
    self.__configIdInfo = {}
    self.__copyOpenInfo = {} --副本开启信息
    self.__curCopyIsWin = false
    self.__countDowmTimer = false
    --添加次数倒计时
    self.__countDowmNum = 0
    --添加次数倒计时
	
	self.lastBattleArrayType = false --上一次进点战斗的类型
end

function RelicCopyModel:getCurViewSeleIdexBtn()
    local configInfo = DynamicConfigData.t_HallowCopy
    for i = 1, #configInfo, 1 do
        local isOpen = self:getCurCopyIsOpen(i) --当前按钮是否开启
        if isOpen == true then
            return i
        end
    end
    return 1
end

function RelicCopyModel:setCountDowm()
    local curtime = ServerTimeModel:getServerTime()
    local serverLimit = self:getserverlimitTime()
    local remainTimes, maxTime = self:getRemainTumes()
    printTable(155, ">>>>>>>>>>>>打印的时间", remainTimes,TimeLib.msToString(curtime*1000), TimeLib.msToString(serverLimit))
    local hangUpMax = math.ceil((serverLimit / 1000) - curtime)
    if hangUpMax > 0 then
        local function onCountDown(time)
            self.__countDowmNum = time
            Dispatcher.dispatchEvent(EventType.HallowCopy_UpdatecuntDown)
            --更新倒计时
        end
        local function onEnd(...)
            self.__countDowmNum = 0
            self:getCopy()
            Dispatcher.dispatchEvent(EventType.HallowCopy_UpdatecuntDown)
        end
        if self.__countDowmTimer then
            TimeLib.clearCountDown(self.__countDowmTimer)
        end
        self.__countDowmTimer = TimeLib.newCountDown(hangUpMax, onCountDown, onEnd, false, false, false)
    else
        if self.__countDowmTimer then
            TimeLib.clearCountDown(self.__countDowmTimer)
        end
        Dispatcher.dispatchEvent(EventType.HallowCopy_UpdatecuntDown)
    end
end

function RelicCopyModel:getCountDowm()
    return self.__countDowmNum
end

function RelicCopyModel:clearCountDowm() --清理
    self.__countDowmNum = 0
    if self.__countDowmNum then
        TimeLib.clearCountDown(self.__countDowmNum)
    end
    Dispatcher.dispatchEvent(EventType.HallowCopy_UpdatecuntDown)
    --更新倒计时
end

function RelicCopyModel:setfirstConfigId()
    local configInfo = DynamicConfigData.t_HallowCopy
    for key, value in pairs(configInfo) do
        for key1, value1 in pairs(value) do
            for key2, value2 in pairs(value1) do
                self.__configIdInfo[value2.id] = value2
            end
        end
    end
end

function RelicCopyModel:getCurCopyIsOpen(copytype) --当前按钮是否开启
    local isOpen = false
    if self.__copyOpenInfo and self.__copyOpenInfo.openCopyInfo then
        local open = self.__copyOpenInfo.openCopyInfo[copytype]
        if open and open.isOpen == true then
            isOpen = true
        end
    end
    return isOpen
end

function RelicCopyModel:getCurCopyDiff(copytype) --当前按钮困难度
    local copy = copytype
    local copyDiff = 1
    if self.__copyOpenInfo and self.__copyOpenInfo.openCopyInfo then
        local open = self.__copyOpenInfo.openCopyInfo[copytype]
        if open then
            copyDiff = open.bossType
        end
    end
    return copy, copyDiff
end

--红点
function RelicCopyModel:relicCopyRed()
    local remainTimes, maxTime = self:getRemainTumes()
    local allCount, maxLimit = self:getAllCount()
    RedManager.updateValue("V_RELICCOPYRED", remainTimes > 0 and allCount < maxLimit)
   -- RedManager.updateValue("V_RELICCOPYRED", false)
end

--最大上限次数只给红点用
function RelicCopyModel:getAllCount()
    local allCount = 0
    local maxLimit = 0
    if self.__copyOpenInfo and self.__copyOpenInfo.data then
        allCount = self.__copyOpenInfo.data.count
    end
    local configInfo = DynamicConfigData.t_HallowConst[1]
    maxLimit = configInfo.maxLimit
    return allCount, maxLimit
end

--返回副本的剩余次数remainTimes和最大次数maxTimes
function RelicCopyModel:getRemainTumes()
    local maxTimes = 0
    local data = self.__copyOpenInfo and self.__copyOpenInfo.data or {}
    local remainTimes = data.leftTimes or 0
    local configInfo = DynamicConfigData.t_HallowConst[1]
    maxTimes = configInfo.limitTimes or 0
    if remainTimes < 0 then
        remainTimes = 0
    end
    local freeTime = data.leftExtraTimes or 0;
    local buyTime = data.buyTimes or 0;
    return remainTimes, maxTimes, freeTime, buyTime
end

function RelicCopyModel:getlimitTime() --倒计时时间
    local limitTime = 0
    local configInfo = DynamicConfigData.t_HallowConst[1]
    limitTime = configInfo.recovery
    return limitTime
end

function RelicCopyModel:getserverlimitTime() --服务器倒计时时间
    local limitTime = 0
    if self.__copyOpenInfo and self.__copyOpenInfo.data then
        if self.__copyOpenInfo.data.nextEndTimeMs ~= nil then
            limitTime = self.__copyOpenInfo.data.nextEndTimeMs
        end
    end
    return limitTime
end

function RelicCopyModel:getCurDiffIsFirstPass(copyType, diffId, point) --是否是首通false为不首通true为首通过
    local id = self:getIdByCopyType(copyType, diffId, point)
    local firstPass = false
    if self.__copyOpenInfo and self.__copyOpenInfo.data then
        if self.__copyOpenInfo.data.copyRecord then
            local has = self.__copyOpenInfo.data.copyRecord[id]
            if has then
                firstPass = true
            end
        end
    end
    return firstPass
end

function RelicCopyModel:getIdByCopyType(copyType, diffId, point)
    local id = 1
    if point == 0 then
        return id
    end
    --printTable(155, ">>>>>>>>>>>>>??????", copyType, diffId, point)
    local configInfo = DynamicConfigData.t_HallowCopy
    if configInfo then
        id = configInfo[copyType][diffId][point].id
    end
    return id
end

function RelicCopyModel:getCopyTypeById(id)
    local copyType = 1
    local diffId = 1
    local point = 1
    local configValue = self.__configIdInfo[id]
    if configValue then
        copyType = configValue.copyType
        diffId = configValue.bossType
        point = configValue.level
    end
    return copyType, diffId, point
end

function RelicCopyModel:getBtnState(copyType, diffId, point)
    local remainTimes, maxTime, freeTime = self:getRemainTumes()
    local openState = 1 --0开启，1未开启，2扫荡，3带图片的扫荡
    local copyIsOpen = self:getCurCopyIsOpen(copyType)
    if copyIsOpen == false then
        return 1
    end
    local isFirst = self:getCurDiffIsFirstPass(copyType, diffId, point)
    remainTimes = remainTimes + freeTime;
    --是否是首通false为不首通true为首通过
    if point == 1 then
        if isFirst == false then
            openState = 0
        else
            if remainTimes > 0 then
                openState = 2
            else
                openState = 4 -- 3(之前是次数用完变购买  现在取消购买)
            end
        end
    else
        local shangFirst = self:getCurDiffIsFirstPass(copyType, diffId, point - 1)
        if copyIsOpen == true and shangFirst == true and isFirst == false then
            openState = remainTimes > 0 and 0 or 4
        elseif copyIsOpen == true and shangFirst == false and isFirst == false then
            openState = 1
        elseif copyIsOpen == true and shangFirst == true and isFirst == true and remainTimes > 0 then
            openState = 2
        elseif copyIsOpen == true and shangFirst == true and isFirst == true and remainTimes <= 0 then
            openState = 4--3
        end
    end
    return openState
end

-- function RelicCopyModel:getCurCopyItem1(copyInfo)
--     local pos = 1
--     for i = 1, #copyInfo, 1 do
--         local itemData = copyInfo[i]
--         local copyList = ModelManager.RelicCopyModel:getCopyInfo(itemData.gamePlayType)
--         local isPass = false
--         if copyList and copyList.diffPass ~= nil then
--             isPass = copyList.diffPass.difficultyInfo[itemData.difficulty]
--         end
--         if isPass and isPass.passed == true then
--             pos = i
--         end
--     end
--     return pos
-- end

--request副本数据请求
function RelicCopyModel:getCopy()
    local function success(data)
        printTable(8, "副本请求返回成功", data)
        self.__copyOpenInfo = {}
        self.__copyOpenInfo = data
        GlobalUtil.delayCallOnce(
            "RelicCopyModel:setAllCopyRed",
            function()
                self:relicCopyRed()
            end,
            self,
            0.5
        )
        self:setCountDowm()
        Dispatcher.dispatchEvent(EventType.HallowCopy_getInfoUpdate)
    end
    local info = {}
    printTable(5, "副本请求发送的参数", info)
    RPCReq.Hallow_GetCopyInfo(info, success)
end

--request进入副本
function RelicCopyModel:enterCopy(id)
    local function success(data)
        printTable(8, "副本请求返回成功", data)
        if data and data.result ~= nil then
            self.__curCopyIsWin = data.result
        else
            self.__curCopyIsWin = false
        end
        self.__copyOpenInfo = {}
        self.__copyOpenInfo = data
        local params = {}
        params.isWin = data.result
        params.reward = data.addRes
        params.type = GameDef.GamePlayType.Hallow
        ModelManager.PlayerModel:set_awardData(params)
        self:relicCopyRed()
        self:setCountDowm()
        Dispatcher.dispatchEvent(EventType.HallowCopy_battleEndUpdate)
    end
    local info = {
        id = id
    }
    printTable(5, "副本请求发送的参数", info)
    RPCReq.Hallow_StartFight(info, success)
end

--request扫荡副本
function RelicCopyModel:sweepCopy(id)
    local function success(data)
        printTable(5, "副本扫荡返回成功", data)
        self.__curCopyIsWin = true
        self.__copyOpenInfo = {}
        self.__copyOpenInfo = data
        self:relicCopyRed()
        self:setCountDowm()
        Dispatcher.dispatchEvent(EventType.HallowCopy_battleEndUpdate)
    end
    local info = {
        id = id
    }
    -- self.__curCopyDiff = difficulty
    -- self.__curCopyType = gamePlayType
    printTable(5, "副本扫荡发送的参数", info)
    RPCReq.Hallow_MopUp(info, success)
end

return RelicCopyModel
