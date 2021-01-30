local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local Cache = _G.Cache
local MATH_FLOOR = math.floor
local handle = false
local BaseModel = require "Game.FMVC.Core.BaseModel"
local MaterialCopyModel = class("MaterialCopyModel", BaseModel)


local redTypes = {
    {redType="", moduleId = ModuleId.Copy_Aura.id},
    {redType="", moduleId = ModuleId.Copy_Gold.id},
    {redType="", moduleId = ModuleId.Copy_Equip.id},
    {redType="", moduleId = ModuleId.Copy_Hero.id},
    {redType="", moduleId = ModuleId.Copy_Screct.id},
    {redType="", moduleId = ModuleId.Copy_Jewelry.id},
    {redType="", moduleId = ModuleId.Copy_Rune.id},
}

function MaterialCopyModel:ctor()
end
function MaterialCopyModel:init()
    self.__copyInfo = {} --副本信息
    self.__curCopyInfo = false
    self.__curCopyIsWin = false
    self.__curCopyDiff = false
    self.__curCopyType = false
    self.__AllcopyRed = {}
    self.__FirstLogin = {}
end

function MaterialCopyModel:setAllCopyRed()
	GlobalUtil.delayCallOnce("MaterialCopyModel:setAllCopyRed", function()
		self:materCopyRed()
		 --副本红点
		self:arenaCopyRed()
		 --竞技场红点
		self:pataCopyRed()
		printTable(22, "副本公会boss红点")
        self:guildBossRed()	 --公会boss红点
        self:setExtraordRed()--超凡段位赛红点
	end, self, 0.5)
end


function MaterialCopyModel:setExtraordRed()
    local red=false
    local remainTimes, maxTimes = self:getRemainTumes(GameDef.GamePlayType.CrossSuperMundane)
    local tips1 = ModuleUtil.moduleOpen(ModuleId.ExtraordinarylevelMain.id,false)
    local tips2 = ModuleUtil.getModuleOpenTips(ModuleId.ExtraordinarylevelMain.id)
    if tips1==true and not tips2 then--前端开启了该功能
        if not ExtraordinarylevelPvPModel.isTimeWeehours and remainTimes>0 then
            red=true
        end 
    end
    RedManager.updateValue("V_EXTRAODINARYCOPY", red)
end


function MaterialCopyModel:getAllCopyRed(copyType)
    return self.__AllcopyRed[copyType] or false
end

function MaterialCopyModel:getFirstLoginState(copyType)
    if self.__FirstLogin[copyType] == nil then
        return true
    end
    return self.__FirstLogin[copyType]
end

function MaterialCopyModel:setFirstLoginState(copyType)
    self.__FirstLogin[copyType] = false
end



function MaterialCopyModel:materCopyRed() --可进入次数大于零，或者挑战按钮出现
    local playFigth =PataModel:getPataFloor(2000)
    local copyInfo = DynamicConfigData.t_copy
    local materialRed = false

    local copyList =self:getMeterialCopyInfo()
    local confs={}
    for i = 1, #copyList, 1 do
        local copy = DynamicConfigData.t_copy
		local configInfo = copy[copyList[i]]
        if configInfo then
            local tips1 = ModuleUtil.moduleOpen(configInfo[1].moduleId,false)
            local tips2 = ModuleUtil.getModuleOpenTips(configInfo[1].moduleId)
            if tips1==true and not tips2 then--前端开启了该功能
                confs[copyList[i]] = copyList[i]
            end
        end 
    end

    for copyType, value in pairs(copyInfo) do
        self.__AllcopyRed[copyType] = false
        local remainTimes, maxTimes = self:getRemainTumes(copyType)
        local copyData = copyInfo[copyType]

        if ModelManager.PlayerModel.level >= copyData[1].openCondt[1].value and confs[copyType] then
            if remainTimes > 0 or self:canShowChallgeBtn(playFigth, value) then
                self.__AllcopyRed[copyType] = true
                materialRed = true
            end
        end

        RedManager.updateValue("V_COPY" .. copyType, self.__AllcopyRed[copyType])
    end
    printTable(20, "打印的副本红点", materialRed, self.__AllcopyRed)
    RedManager.updateValue("M_MATERIALCOPYRED", materialRed)
end

function MaterialCopyModel:canShowChallgeBtn(playFigth, value)
    local isshowBtn = false
    for key, v in pairs(value) do
        local limitFigth = 0
        for k, limit in pairs(v.openCondt) do
            if limit.type == 2 then
                limitFigth = limit.value
            elseif limit.type == 3 then
                limitFigth = limit.value
            end
        end
        local isOpen = false
        if playFigth > limitFigth and self:getDiffItemIsPass(v.gamePlayType, v.difficulty - 1) == true then
            isOpen = true
        end
        local copyList = self:getCopyInfo(v.gamePlayType)
        local isfirstPass = false
        local isPass = false
        if copyList and copyList.diffPass ~= nil then
            isPass = copyList.diffPass.difficultyInfo[v.difficulty]
        end
        if isPass and isPass.passed == true then
        else
            isfirstPass = true
        end
        local dayStr = DateUtil.getOppostieDays()
        local isShow =
            FileCacheManager.getBoolForKey(
            "MaterialCopyViewEnterBtn_isShow" .. v.gamePlayType .. v.difficulty .. dayStr,
            false
        )
        if isOpen and isfirstPass and not isShow then
            isshowBtn = true
            return isshowBtn
        end
    end
    return isshowBtn
end

--竞技场
function MaterialCopyModel:arenaCopyRed()
    -- local red=false
    -- local remainTimes,maxTimes= self:getRemainTumes(185)
    -- if remainTimes>0 then
    -- 	red=true
    -- end
    -- self.__AllcopyRed[185]=red;
    -- RedManager.updateValue("V_ArenaChallenge", red);
    ModelManager.ArenaModel:requestArenInfo(
        function()
        end
    )
end

--爬塔红点
function MaterialCopyModel:pataCopyRed()
    local remainTimes, maxTime = self:getRemainTumes(2000)
    RedManager.updateValue("V_TOWER_SWEEP", remainTimes > 0)
end

function MaterialCopyModel:guildBossRed()
    local configInfo = DynamicConfigData.t_boss
    for copyType, value in pairs(configInfo) do
        local red = false
        self.__AllcopyRed[copyType] = false
        local remainTimes, maxTimes = self:getRemainTumes(copyType)
        if tonumber(copyType) == 501 then
            local canOpen=self:getGuildPosCanOpen()
            local isOpen = GuildModel:getguildBossisOpen(copyType)
            printTable(
                22,
                "缘分范德萨发士大夫",
                isOpen,
                GuildModel.guildHave,
                remainTimes,
                copyType,
                self:getFirstLoginState(copyType)
            )
            if  GuildModel.guildHave == true and ((canOpen and isOpen==false) or (isOpen and remainTimes > 0)) and self:getFirstLoginState(copyType) == true then
                red = true
            end
        else
            if GuildModel.guildHave == true and remainTimes > 0 and self:getFirstLoginState(copyType) == true then
                red = true
            end
        end
        self.__AllcopyRed[copyType] = red
        printTable(22, "打印的boss", self.__AllcopyRed)
        RedManager.updateValue("V_Guild_BOSSITEM" .. copyType, red)
    end
end

function MaterialCopyModel:getGuildPosCanOpen()--得到当前职位是否能开启公会boss
    local isOpen=false
    if GuildModel.guildHave==true then
        local info = GuildModel.guildList
        local cost = GuildModel:getGuildBossOpencost()
        local posTion = GuildModel.guildList.myGuildPosition
        if posTion<=2 and info.activeScore>=cost then
            isOpen=true
        end 
    end
    return isOpen
end

function MaterialCopyModel:getDiffItemIsPass(gamePlayType, difficulty)
    local copyList = ModelManager.MaterialCopyModel:getCopyInfo(gamePlayType)
    local isPass = false
    if difficulty == 0 then
        return true
    end
    if copyList and copyList.diffPass ~= nil then
        isPass = copyList.diffPass.difficultyInfo[difficulty]
    end
    if isPass and isPass.passed == true then
        return true
    else
        return false
    end
end

--返回副本的剩余次数remainTimes和最大次数maxTimes
function MaterialCopyModel:getRemainTumes(copyType)
    local copyList = ModelManager.MaterialCopyModel:getCopyInfo(copyType)
    local copyNum = 0
    if copyType == 501 then --后端要求工会boss特殊处理
        if GuildModel.guildList.boss then
            local bossInfo = GuildModel.guildList.boss[copyType]
            if bossInfo and bossInfo.count then
                copyNum = bossInfo.count
            end
        end
    else
        if copyList and copyList.dailyInfo and copyList.dailyInfo.times then
            copyNum = copyList.dailyInfo.times
        end
    end
    local topUp = 0
    if copyList and copyList.dailyInfo and copyList.dailyInfo.topup then
        topUp = copyList.dailyInfo.topup
    end
    local copyData = DynamicConfigData.t_limit[copyType]
    local maxTimes = copyData and copyData.maxTimes or 0
    local remainTimes = maxTimes + topUp - copyNum
    if remainTimes < 0 then
        remainTimes = 0
    end
    return remainTimes, maxTimes
end

function MaterialCopyModel:getCurCopyItem(copyInfo)
    for i = #copyInfo, 1, -1 do
        local itemData = copyInfo[i]
        local limitLv = 0 --itemData.openCondt.value
        local limitFigth = 0
        for k, limit in pairs(itemData.openCondt) do
            if limit.type == 1 then
                limitLv = limit.value
            end
            if limit.type == 2 then
                limitFigth = limit.value
            end
        end
        local roleLv = PlayerModel.level
        local figth = ModelManager.CardLibModel:getFightVal()
        if roleLv >= limitLv and figth >= limitFigth then
            printTable(5, "当前选择的第个item", i, itemData)
            return itemData, i
        end
    end
    return copyInfo[1], 1
end

function MaterialCopyModel:getCurCopyItem1(copyInfo)
    local pos = 1
    for i = 1, #copyInfo, 1 do
        local itemData = copyInfo[i]
        local copyList = ModelManager.MaterialCopyModel:getCopyInfo(itemData.gamePlayType)
        local isPass = false
        if copyList and copyList.diffPass ~= nil then
            isPass = copyList.diffPass.difficultyInfo[itemData.difficulty]
        end
        if isPass and isPass.passed == true then
            pos = i
        end
    end
    return pos
end

function MaterialCopyModel:getMaterialMaxNum()
    local count = 0
    local copyInfo = DynamicConfigData.t_copy
    for k, value in pairs(copyInfo) do
        count = count + 1
    end
    return count
end

function MaterialCopyModel:getMeterialCopyInfo()
    --[[local temp={}
	local copyInfo=DynamicConfigData.t_copy;
	for category, groupInfos in pairs(copyInfo) do
		for k, v in pairs(groupInfos) do
			temp[#temp+1]=v
		end
	end
	return temp
	]]
  --  local temp = {1002, 1000, 1003, 1004, 1006, 1007, 1005}
    local temp={}
    local copyInfo=DynamicConfigData.t_copy;
    for category, groupInfos in pairs(copyInfo) do
    	temp[#temp+1]=category
    end
    table.sort(temp,function(a,b)
    	return a<b;
    end)
    printTable(5, "bubuububusbdubfusfbus", temp)
    return temp
end

function MaterialCopyModel:setCopyLimit(data)
    if data and data.daily then
        for k, copyInfo in pairs(data) do
            for copyCode, daily in pairs(data.daily) do
                local dailyList = self.__copyInfo[copyCode] or {}
                dailyList["dailyInfo"] = daily
                self.__copyInfo[copyCode] = dailyList
            end
        end
        printTable(5, "副本信息dailyInfo", self.__copyInfo)
        self:setAllCopyRed()
    end
end

function MaterialCopyModel:setCopyInfos(data)
    printTable(5, "副本信息", data)
    for copyCode, daily in pairs(data) do
        local dailyList = self.__copyInfo[daily.gamePlayType] or {}
        dailyList["diffPass"] = daily
        self.__copyInfo[daily.gamePlayType] = dailyList
    end
    printTable(5, "副本信息diffPass", self.__copyInfo)
    self:setAllCopyRed()
end

function MaterialCopyModel:getCopyInfo(copyCode)
    return self.__copyInfo[copyCode]
end
--获取今日操作次数
function MaterialCopyModel:getCopyCount(copyCode)
    local copy_info = self.__copyInfo[copyCode]
    --printTable(1 , "副本信息： " , copy_info , copyCode , self.__copyInfo)
    if copy_info and copy_info.dailyInfo then
        return copy_info.dailyInfo.times
    end
    return 0
end

function MaterialCopyModel:enterMeteriCopy(copyType, dif)
    printTable(5, "进入副本》》》》》", copyType, dif)
    self:enterCopy(copyType, dif)
end

--#请求提升次数上限
function MaterialCopyModel:spendForTopup(copyType, times, cb)
    local function success(data)
        printTable(5, "请求提升次数上限返回成功", data)
        if (cb) then
            cb()
        end
        --Dispatcher.dispatchEvent(EventType.cardView_levelUpSuc,data);
    end
    local info = {
        type = copyType, --0:integer      #次数限制类型
        times = times --1:integer      #提升多少次上限
    }
    printTable(5, "请求提升次数上限", info)
    RPCReq.Limit_SpendForTopup(info, success)
end

--request进入副本
function MaterialCopyModel:enterCopy(copyType, diff)
    local function success(data)
        printTable(8, "副本请求返回成功", data)
        if data and data.isSuccess ~= nil then
            self.__curCopyIsWin = data.isSuccess
        end
        local params = {}
        params.isWin = data.isSuccess
        params.reward = data.reward
        params.type = copyType
        printTable(12, "11111111111111111111111", params)
        ModelManager.PlayerModel:set_awardData(params)
        --Dispatcher.dispatchEvent(EventType.cardView_levelUpSuc,data);
    end
    local info = {
        gamePlayType = copyType, --0:integer #场景玩法Id
        difficulty = diff --1:integer #难度
    }
    --print(4,"发送的参数",uuid)
    printTable(5, "副本请求发送的参数", info)
    self.__curCopyDiff = diff
    self.__curCopyType = copyType
    RPCReq.Copy_EnterCopy(info, success)
end

--request扫荡副本
function MaterialCopyModel:sweepCopy(gamePlayType, difficulty, times)
    local function success(data)
        printTable(5, "副本扫荡返回成功", data)
        self.__curCopyIsWin = true
        --ViewManager.open("MateriCopyEndLayer")
        --Dispatcher.dispatchEvent(EventType.cardView_levelUpSuc,data);
    end
    local info = {
        gamePlayType = gamePlayType, --0:integer #场景玩法Id
        difficulty = difficulty, --1:integer #难度
        times = times --2:integer #扫荡次数
    }
    self.__curCopyDiff = difficulty
    self.__curCopyType = gamePlayType
    --print(4,"发送的参数",uuid)
    printTable(5, "副本扫荡发送的参数", info)
    RPCReq.Copy_SweepCopy(info, success)
end

--副本结束
function MaterialCopyModel:fightCopyEnd()
    printTable(5, "副本结束")
    RPCReq.Copy_EndCopy()
end

function MaterialCopyModel:clear()
    -- if handle then
    -- 	Scheduler.unschedule(handle)
    -- 	handle = false
    -- end
    --self:init()
end
-- if handle==false then
-- 	MaterialCopyModel:init()
-- end

return MaterialCopyModel
