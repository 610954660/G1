
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local ElvesSystemModel = class("ElvesSystemModel",BaseModel)
local ElvesPlanArray = require "Game.Modules.ElvesSystem.ElvesPlanArray"

--  用于备战界面获取敌人的精灵阵容
--  一个玩法里面有多个阵容类型 并且区分攻击阵容和防守阵容的时候需要在这添加一下阵容类型
--  攻击阵容的键值对应 防守阵容的键值
local __enemyArryType = {
    --高阶竞技场
    [GameDef.BattleArrayType.HigherPvpAckOne] = GameDef.BattleArrayType.HigherPvpDefOne,
    [GameDef.BattleArrayType.HigherPvpAckThree] = GameDef.BattleArrayType.HigherPvpDefThree,
    [GameDef.BattleArrayType.HigherPvpAckSix] = GameDef.BattleArrayType.HigherPvpDefSix,
    --天域赛PVP
    [GameDef.BattleArrayType.HorizonPvpAckOne] = GameDef.BattleArrayType.HorizonPvpDefOne,
    [GameDef.BattleArrayType.HorizonPvpAckThree] = GameDef.BattleArrayType.HorizonPvpDefThree,
    [GameDef.BattleArrayType.HorizonPvpAckSix] = GameDef.BattleArrayType.HorizonPvpDefSix,
    --跨服竞技场
    [GameDef.BattleArrayType.CrossArenaAckOne] = GameDef.BattleArrayType.CrossArenaDefOne,
    [GameDef.BattleArrayType.CrossArenaAckTwo] = GameDef.BattleArrayType.CrossArenaDefTwo,
    [GameDef.BattleArrayType.CrossArenaAckThree] = GameDef.BattleArrayType.CrossArenaDefThree,
    --跨服超凡段位赛
    [GameDef.BattleArrayType.CrossSuperMundaneAckFirst] = GameDef.BattleArrayType.CrossSuperMundaneDefFirst,
    [GameDef.BattleArrayType.CrossSuperMundaneAckTwo] = GameDef.BattleArrayType.CrossSuperMundaneDefTwo,
}


local __itemCode = 10000079
function ElvesSystemModel:ctor()
    self.elvesData = {}
    self.planInfo   = {}     -- 方案     
    self.reasonType = false  -- 更新类型 1 升级 2升星 3 经验 4添加
    self.cumulateTimes  = 0      -- 召唤次数
    self.upLvOldPower   = 0
    self.currentElvesPosIndex = false
    self.currentElvesUid = false  -- 当前升星/升级精灵的UId
    self.elvesPreEnterList  = {} -- 上阵精灵列表 备战
    self.elvesFightEnterList = {}
    self.elvesAllData    = {} -- 所有精灵数据
    self.planReqData = {}            -- 请求自己的精灵方案数据
    self.otherReqData = {}           -- 请求敌人的阵容信息
    self.battlePrepareIsShow = false -- 判断是不是在战斗界面

    self.elvesOpenState = true      -- 判断战斗界面是否开启精灵模块
    self.battleData = {}            -- 战报数据
    self.elvesDataSeq = {}          -- 精灵每一回合的战报
    self.maxHistoryTimes   = 0         -- 精灵召唤历史次数（不重置）
    self.summonElvesNum = 0         -- 召唤到的精灵个数（第一个弹）
    self.summonRewardNum = 0        -- 召唤获得的奖励（第二个弹）
    self.summonAccRewardNum = 0     -- 召唤的累计奖励（第三个弹）
    self.summonReward     = {}      -- 召唤精灵获得的奖励
    self.summonElves      = {}      -- 召唤获得精灵
    self.summonRewardMark = 0       -- 召唤累计奖励领取状态
    self.summonCanRewardTimes = 0   -- 召唤累计奖励可领取的轮次
    self.summonHistoryTimes   = 0   -- 累计召唤次数（会重置）
    self.arrays     = {}            -- 每个玩法的阵容信息
    self.planId     = {}
    self.playArrays = {}
    self.battleElvesData = {}   -- 精灵战斗后台数据  用玩法做键值
    self.elvesFightRound = {}
    self.pageIndex       = 0        -- 左侧页签
    self.limitFetterCount  = {}     -- 羁绊提升次数
    self.skinData        = {}       -- 精灵皮肤(所有已经激活的皮肤)
    self.elvesOtherPrepareInfo = {}     -- 敌方备战界面精灵数据
    self:initListeners()
    self.limitMaxNum     = DynamicConfigData.t_limit[GameDef.GamePlayType.Elf].maxTimes -- 钻石限制召唤最大次数
    self.limitNum        = 0    -- 钻石限制召唤次数
end

function ElvesSystemModel:initLimit(limit)
    printTable(8848,">>>limit>>>",limit)
	if limit and limit.weekly then
		local data = limit.weekly[GameDef.GamePlayType.Elf]
		if data then
			self.limitNum = data.times
		end
	end
end

function ElvesSystemModel:addLimitNum(val)
	self.limitNum = self.limitNum + val
	Dispatcher.dispatchEvent(EventType.ElvesSummonView_refreshPanal)
end
function ElvesSystemModel:setLimitNum(num)

	self.limitNum = num
	Dispatcher.dispatchEvent(EventType.ElvesSummonView_refreshPanal)
end

function ElvesSystemModel:getResidueNum()
	local residue = self.limitMaxNum - (self.limitNum or 0)
	if residue < 0 then
		residue = 0
	end
	return residue
end

-- 设置方案名
function ElvesSystemModel:setPlanName(name,planId)
    self.planInfo[planId].name = name
end

-- 精灵所有数据
function ElvesSystemModel:initElvesData(data)
    self.elvesData = data or {}
    -- printTable(8848,">>>data>>>",data)
    self.planInfo  = data.paln or {}
    self.arrays = data.arrays or {}
    self.limitFetterCount = data.useItem or {}
    self.skinData = data.skin or {}
    if data.summon then
        if data.summon[1] and data.summon[1].maxHistoryTimes then
            self.maxHistoryTimes = data.summon[1].maxHistoryTimes or 0
        end
        if data.summon[1] and data.summon[1].rewardMark then
            self.summonRewardMark = data.summon[1].rewardMark or 0
        end
        if data.summon[1] and data.summon[1].canRewardTimes then
            self.summonCanRewardTimes = data.summon[1].canRewardTimes
        end
        if data.summon[1] and data.summon[1].historyTimes then
            self.summonHistoryTimes = data.summon[1].historyTimes
        end
    end
    self:initPlan()
    self:initElvesInfo()
    self:elvesInitPlanData()
end

-- 没有方案的时候使用这个数据
function ElvesSystemModel:initPlan()
    for i = 1,3 do
        local tempPlan = {}
        local data = self.planInfo[i]
        if not data then
            tempPlan.id = i
            tempPlan.pos ={}
            for j = 1,3 do
                tempPlan.pos[j]={}
                tempPlan.pos[j].pos = j
                tempPlan.pos[j].uuid =""
            end
            tempPlan.name = Desc["ElvesSystem_planPage"..i]
            table.insert(self.planInfo,tempPlan)
        end
    end
end

-- 获取当前精灵所在的位置
function ElvesSystemModel:getElvesIndex(elvesPageIndex,elvesIndex)
    if self.currentElvesUid then
        for k,v in pairs(self.elvesAllData[elvesPageIndex]) do
            if v.uuid == self.currentElvesUid then
                self.currentElvesUid = false
                return k
            end
        end
    end
    return false
end


-- 精灵数据更新 升级/升星/经验/添加
function ElvesSystemModel:elvesUpdate(data)
    -- printTable(8848,"data>>>",data)
    if data.reasonType == 1 then
        self:upLvElves(data.elf)
    elseif data.reasonType == 2 then
        self:upStarElves(data.elf)
    elseif data.reasonType == 3 then
    elseif data.reasonType == 4 then
        self:addElves(data.elf)
    end
    Dispatcher.dispatchEvent(EventType.ElvesSystemBaseView_refreshPanal)
end

-- 初始化方案列表
function ElvesSystemModel:elvesInitPlanData()
    for i=1,3 do 
        if not self.elvesPreEnterList[i] then
            self.elvesPreEnterList[i] = {}
        end
    end
    for k,v in pairs(self.planInfo) do 
        local data = v.pos
        for o,p in pairs(data) do
            local elvesData = self:getElvesDataByUid(p.uuid)
            if elvesData then
                table.insert(self.elvesPreEnterList[k],elvesData)
            end
        end
    end
end

-- 通过uuid获取某个精灵的数据
function ElvesSystemModel:getElvesDataByUid(uuid)
    local elvesData = self.elvesAllData[1]
    local tempData = {}
    for k,v in pairs(elvesData) do
        if uuid == v.uuid and v.uuid ~= "" then
            tempData = v
            return tempData
        end
    end
    return false
end

-- 初始化精灵数据
function ElvesSystemModel:initElvesInfo()
    local dataReq = self.elvesData.elfList or {}
    local dataCfg = DynamicConfigData.t_ElfMain
    for i=1,5 do 
        if not self.elvesAllData[i] then 
            self.elvesAllData[i] = {}
        end
    end
    local function _findElf(id)
        local tempData = {}
        for k ,v in pairs(dataReq) do
           if  v.id == id then
           if not tempData[v.id] then tempData[v.id] = {} end
                tempData[v.id] = v
                return tempData
            end
        end
    end

    for k,v in pairs(dataCfg) do  -- 所有精灵数据
        local power = 0
        local tempData = {}
        local data = _findElf(k)
        if data then
            tempData = v[data[k].level]
            power = self:getElvesPower(tempData,data[k].star)
            tempData.have = 1
            tempData.power = power
            tempData.star  = data[k].star
            tempData.uuid  = data[k].uuid 
            tempData.exp   = data[k].exp
            tempData.skinId = data[k].skinId or 1
            if tempData.skinId == 0 then
                tempData.skinId = 1
            end
        else
            tempData = v[1]
            power = self:getElvesPower(tempData,1)
            tempData.have = 0
            tempData.power = power
            tempData.star  = 1
            tempData.uuid  = ""
            tempData.exp   = 0
            tempData.skinId = 1
        end
        table.insert(self.elvesAllData[1],tempData)
        if  v[1].color == 3 then
            table.insert(self.elvesAllData[2],tempData)
        elseif  v[1].color == 4 then
                table.insert(self.elvesAllData[3],tempData)
        elseif v[1].color == 5 then
            table.insert(self.elvesAllData[4],tempData)
        elseif v[1].color == 6 then  
            table.insert(self.elvesAllData[5],tempData)  
        end
    end
    -- printTable(8848,">>self.elvesAllData>>",self.elvesAllData)
    self:sortElves()
end

-- 新增精灵
function ElvesSystemModel:addElves(newElvesData)
    -- 改变精灵状态
    for i = 1,#self.elvesAllData do
        for k,v in pairs(self.elvesAllData[i]) do
            for nk,nv in pairs(newElvesData) do
                if nv.id == v.elfId then
                    v.have = 1;
                    -- print(8848,">>>>v.have>>>",v.have)
                    v.uuid = nv.uuid;
                    break;
                end
            end
        end
    end

    -- 重新排序
    self:sortElves()
end

-- 精灵升级
function ElvesSystemModel:upLvElves(newElvesData)
    local newPower = 0
    local dataCfg = DynamicConfigData.t_ElfMain
    for i = 1,#self.elvesAllData do
        for k,v in pairs(self.elvesAllData[i]) do
            for nk,nv in pairs(newElvesData) do
                if nv.id == v.elfId then
                    local tempData = self:getElvesDataByIdAndLv(nv,nv.id,nv.level)
                    newPower = tempData.power
                    self.elvesAllData[i][k] = tempData
                    self.currentElvesUid = nv.uuid
                    break;
                end
            end
        end
    end

    -- 弹战力
    local addNum = newPower - self.upLvOldPower
    RollTips.showAddFightPoint(addNum)

    -- 重新排序
    self:sortElves()
end

-- 精灵升星
function ElvesSystemModel:upStarElves(newElvesData)
    local newPower = 0
    local dataCfg = DynamicConfigData.t_ElfMain
    for i = 1,#self.elvesAllData do
        for k,v in pairs(self.elvesAllData[i]) do
            for nk,nv in pairs(newElvesData) do
                if nv.id == v.elfId then
                    local tempData = self:getElvesDataByIdAndLv(nv,nv.id,nv.level)
                    newPower = tempData.power
                    print(8848,"self.upLvOldPower>>>",self.upLvOldPower)
                    print(8848,"newPower>>>",newPower)
                    self.elvesAllData[i][k] = tempData
                    self.currentElvesUid = nv.uuid
                    break;
                end
            end
        end
    end

    -- 弹战力
    local addNum = newPower - self.upLvOldPower
    RollTips.showAddFightPoint(addNum)

    -- 重新排序
    self:sortElves()
end

-- 精灵排序
function ElvesSystemModel:sortElves()
    for i=1,#self.elvesAllData do
        local keys ={
            {key = "have",asc = true},
            {key = "power",asc = true},
            {key = "color",asc = true},
            {key = "elfId",asc = true},
        }
        TableUtil.sortByMap(self.elvesAllData[i], keys)
        
    end
    self:updategradeRed()
    self:updatestarRed()
    self:updatesummonRed()
    self:updateAttribRed()
    self:updateElvesBagRed()
  --  printTable(8848,"self.elvesAllData[1]>>>",self.elvesAllData[1])
end

-- 通过Id和等级获取精灵数据
function ElvesSystemModel:getElvesDataByIdAndLv(data,id,level)
    local dataCfg = DynamicConfigData.t_ElfMain
    local tempData = dataCfg[data.id][data.level]
    --printTable(8848,"tempData>>>",tempData)
    local newPower = self:getElvesPower(tempData,data.star)
    tempData.have = 1
    tempData.power = newPower
    tempData.star  = data.star
    tempData.uuid  = data.uuid 
    tempData.exp   = data.exp
    tempData.skinId   = data.skinId or 1
    if tempData.skinId == 0 then tempData.skinId = 1 end
    return tempData
end


-- 获取当前拥有精灵的数量
function ElvesSystemModel:getHaveElvesNum()
    local elvesNum = 0
    if not self.elvesAllData or not self.elvesAllData[1] then
        return 0
    end
    for k,v in pairs(self.elvesAllData[1]) do
        if v.have > 0 then
        elvesNum = elvesNum + 1  
        end
    end
    return elvesNum
end

-- 通过类型获取精灵
function ElvesSystemModel:getElvesInfoByType(typeColor)
    return self.elvesAllData[typeColor] or {}
end


-- 计算已拥有的所有精灵的属性值数据
function ElvesSystemModel:getElvesAttr(skin)
   local elvesData = self:getElvesInfoByType(1)
   local attribute = {}
   for i =1,6 do 
    attribute[i] = {}
    attribute[i].value = 0
   end
   for k,v in pairs(elvesData) do
        if v.have > 0 then
            for o,p in pairs(v.attribute) do
                local skinValue = 0     -- 所有皮肤的相同属性的数值
                if skin then
                    -- 获取该精灵的所有皮肤信息
                    local elfSkinInfo = DynamicConfigData.t_ElfSkin[v.elfId] or {}
                    -- 判断每一个皮肤是否都已经激活
                    for i,m in pairs(elfSkinInfo) do
                        local isHavaSkin = self:checkSkinById(m.skinId)
                        if isHavaSkin then
                            local basicAttr = m.basicAttr
                            for ik,iv in pairs(basicAttr) do
                                if iv.type == p.type then
                                    skinValue = skinValue + iv.value
                                end
                            end
                        end
                    end
                end
                attribute[p.type].value = attribute[p.type].value + p.value + skinValue
                attribute[p.type].type  = p.type
            end
        end
   end
   return attribute 
end

-- 累计召唤奖励
function ElvesSystemModel:getCumulateReward(isAsc)
    local rewardData = DynamicConfigData.t_ElfReward
    local tempData   = {}
    for k,v in pairs(rewardData) do
        table.insert(tempData,v)
    end
    local keys ={
        {key = "times",asc = isAsc},
    }
    TableUtil.sortByMap(tempData, keys)
    return tempData
end

-- 获取召唤奖励的最大次数
function ElvesSystemModel:getCumulateRewardMaxTimes()
    local data = self:getCumulateReward(true)
    return data[1].times
end

-- 计算精灵战力
function ElvesSystemModel:getElvesPower(data,star)
    local power = 0
    local attr = {}
    for o,p in pairs(data.attribute) do
        attr[p.type] = p.value
    end
    power = HeroConfiger.CaleAttrPower(attr)
    if data.skillCombat then
        power = power + data.skillCombat
    end
    local starData = DynamicConfigData.t_ElfStar
    local starPower = starData[data.elfId][star].attrCombat
    if starPower and starPower ~="" then 
        power = power + starPower
    end

    -- 获取该精灵的所有皮肤信息
    local elfSkinInfo = DynamicConfigData.t_ElfSkin[data.elfId] or {}
    -- 判断每一个皮肤是否都已经激活
    local allSkinPower = 0
    for k,v in pairs(elfSkinInfo) do
        local isHavaSkin = self:checkSkinById(v.skinId)
        if isHavaSkin then
            local skinPower = self:getElvesSkinPower(v)
            allSkinPower = allSkinPower + skinPower
        end
    end
    -- 获取单个皮肤的战力

    power = power + allSkinPower

    return power
end

-- 计算精灵总属性战力
function ElvesSystemModel:getAllElvesAttrPower()
    local power = 0
    local attr = {}
    local elvesAttrData = self:getElvesAttr()
    for k,v in pairs(elvesAttrData) do
        if not v.type then return power end
        attr[v.type] = v.value
    end
    power = HeroConfiger.CaleAttrPower(attr)
    return power
end

-- 判断精灵有没有上阵
function ElvesSystemModel:planJudgeById(planId,elfId)
    local enterData = self:getElvesEnterData(planId)
    for k,v in pairs(enterData) do
        if v.elfId == elfId then
            return true
        end
    end
    return false
end

-- 设置上阵精灵列表
function ElvesSystemModel:setElvesEnterData(elves,planId,elfId)
    -- 将精灵移除
    if elfId then
        for k,v in pairs(self.elvesPreEnterList[planId]) do
            if elfId == v.elfId then
                table.remove(self.elvesPreEnterList[planId], k)
                return
            end
        end
    end
    -- 添加精灵到上阵列表
    table.insert(self.elvesPreEnterList[planId],elves)
end

-- 获取上阵精灵列表
function ElvesSystemModel:getElvesEnterData(planId,isBattle)
    return self.elvesPreEnterList[planId] or {}
end

function ElvesSystemModel:getElvesFightEnterData(planId)
    return self.elvesFightEnterList[planId] or {}
end

-- 设置升级前的战力
function ElvesSystemModel:setUpElvesOldPower(power)
    self.upLvOldPower = power
end

-- 通过精灵id判断有没有该精灵
function ElvesSystemModel:isHaveElvesById(elfId,iconId)
    if iconId then
        local data = DynamicConfigData.t_ElfCombine[elfId]
        if data then
            elfId = data.elfList[3]
        end
    end
    if self.elvesAllData[1] and TableUtil.GetTableLen(self.elvesAllData[1])>0 then
        for k,v in pairs(self.elvesAllData[1]) do
            if elfId == v.elfId then
                if v.have > 0 then
                    return true
                else
                    return false
                end
            end
        end
    end
    return false
end


-- 获得自己的精灵阵容信息
function ElvesSystemModel:getMyElvesBattleInfo(configType)
    printTable(8848,">>>>myconfigType>>>",configType)
    local reqInfo = {
        arrayType = configType,
    }
    RPCReq.Elf_GetArraysPalnIdInfo(reqInfo,function(params)
        -- 将信息发送到精灵备战界面
        -- 返回了阵容类型和方案id
        printTable(8848,">>>请求到自己的精灵阵容信息为>>>",params)
        self.planReqData = {}
        self.planReqData.arrayType = params.data.arrayType or configType
        self.planReqData.planId = params.data.planId or 1

        if TableUtil.GetTableLen(self:getElvesEnterData(1)) == 0 and 
        TableUtil.GetTableLen(self:getElvesEnterData(2)) == 0 and 
        TableUtil.GetTableLen(self:getElvesEnterData(3)) == 0 then
            Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
            return
        end

        local saveElvesPlan = function(params)
            if not self.arrays[params.data.arrayType] then
            self.arrays[params.data.arrayType] = {}
            end
            table.insert(self.arrays[params.data.arrayType],params.data)
            -- 刷新界面
            local data = {
                arrayType = params.data.arrayType,
                planId    = self.planReqData.planId,
            }
            self.planId[params.data.arrayType] = data.planId
            self:setMyElvesBattleReqInfo(data.arrayType,data.planId)
            Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        end

        local reqInfo2 = {
            arrayType = params.data.arrayType, -- 阵容类型
            planId    = self.planReqData.planId, -- 方案id
        }

        local planArray = ElvesPlanArray[params.data.arrayType]
        if planArray then
            for k,v in pairs(planArray) do
                reqInfo2 = {
                    arrayType = v,
                    planId    = self.planReqData.planId,
                }
                RPCReq.Elf_SetArraysPalnId(reqInfo2,function(params)
                    if k == 1 then
                        saveElvesPlan(params)
                    end
                end)
            end
        end
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
    end)
end



-- 获取敌人的精灵阵容
function ElvesSystemModel:getOtherElvesBattleInfo(playerId,configType)
    if __enemyArryType[configType] then
        configType = __enemyArryType[configType]
    end
    local reqInfo = {
        playerId = playerId,
        arrayType = configType,
    }
    printTable(8848,"reqInfo>>>",reqInfo)
    if not playerId or playerId < 0 then
        self.otherReqData = {}
        return
    end
    RPCReq.Elf_GetOtherPlayerElfRecords(reqInfo,function(params)
        printTable(8848,">>>请求到敌人的精灵阵容信息为>>>",params)
        self.otherReqData = params.data or {}
        self:setOtherData()
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
    end)
end

-- 获取敌人备战界面阵容
function ElvesSystemModel:setOtherElvesPrepareInfo(playerId,configType,serverId)
    if __enemyArryType[configType] then
        configType = __enemyArryType[configType]
    end
    local reqInfo = {
        playerId = playerId,
        arrayType = configType,
        serverId  = serverId,
    }
    local elvesData = {}  
    local function _findElf(code)
        for k,v in pairs(self.elvesAllData[1]) do
            if v.elfId == code then
                return v
            end
        end
    end
    if playerId and playerId > 0 then
        RPCReq.Elf_GetOtherPlayerElfRecords(reqInfo,function(params) 
            printTable(8848,">>敌方精灵阵容>>params>>>",params)
            local reqData = params.data or {}
            for k,v in pairs(reqData) do
                if (v.pos >=251 and v.pos <= 253) or (v.pos >=1 and v.pos <= 3) then
                    local data = _findElf(v.id)
                    table.insert(elvesData,data)
                end
            end
            self.elvesOtherPrepareInfo = elvesData
            Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        end)
    else
        self.elvesOtherPrepareInfo = {}
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
    end
end



-- 获取请求到的敌人的精灵阵容信息
function ElvesSystemModel:getotherElvesBattleReqInfo()
    return self.otherReqData
end

-- 获取请求到的自己的阵容信息
function ElvesSystemModel:getMyElvesBattleReqInfo()
    return self.planReqData
end

-- 设置敌人的精灵阵容的数据 添加精灵消耗的能量值
function ElvesSystemModel:setOtherData()
    local dataCfg = DynamicConfigData.t_ElfMain
    local function _findElf(id,level)
        local tempData = {}
        for k ,v in pairs(dataCfg) do
           if  k == id then
                tempData = v[level]
                return tempData
            end
        end
    end
    for k,v in pairs(self.otherReqData) do
        local tempData = _findElf(v.id,v.level) 
        self.otherReqData[k].costEnergy = tempData.costEnergy
    end
end

function ElvesSystemModel:setMyElvesBattleReqInfo(arrayType,planId)
    self.planReqData.arrayType = arrayType 
    self.planReqData.planId = planId
end

-- 获取方案id
function ElvesSystemModel:getPlanId(arrayType)
    if self.arrays and self.arrays[arrayType] and self.arrays[arrayType].planId and not self.playArrays[arrayType] then
        self.playArrays[arrayType] = true
        self.planId[arrayType] = self.arrays[arrayType].planId
        return self.arrays[arrayType].planId
    else
        return self.planId[arrayType] or 1
    end
end

-- 通过精灵Id获取精灵信息
function ElvesSystemModel:getElvesDataById(elfId)
    -- local dataCfg = DynamicConfigData.t_ElfMain
    -- local tempData = {}
    -- for k ,v in pairs(dataCfg) do
    --     if  k == elfId then
    --         tempData = v[1]
    --         return tempData
    --     end
    -- end
    for k,v in pairs(self.elvesAllData[1]) do
        if v.elfId == elfId then
            return v
        end
    end
end

-- 设置召唤的数据
function ElvesSystemModel:setSummonData(data,isfresh)
    self.maxHistoryTimes = data.maxHistoryTimes or 0
    self.summonHistoryTimes = data.historyTimes or 0
    self.summonCanRewardTimes = data.canRewardTimes or 0
    if isfresh then
        Dispatcher.dispatchEvent(EventType.ElvesSummonView_refreshPanal)
    end
end

function ElvesSystemModel:checkGradeRedByIndex(index)
    local elvesInfoData = self:getElvesInfoByType(index)
    for k,v in pairs(elvesInfoData) do
        local haveNum       = 0
        local needNum       = 0 
        local itemCode      = false
        local ElfCfg        = DynamicConfigData.t_ElfMain[v.elfId]
        if ElfCfg[v.level + 1] then
            needNum     = ElfCfg[v.level + 1].experience
            itemCode    = ElfCfg[v.level + 1].itemCode
            haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
        else
            needNum     = ElfCfg[v.level].experience
            itemCode    = ElfCfg[v.level].itemCode
            haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
        end
        local num = #ElfCfg
        local have = self:isHaveElvesById(v.elfId)
        local ElfCfg   = DynamicConfigData.t_ElfMain[v.elfId]

        local otherState = false
        if v.level == #ElfCfg then
        elseif ElfCfg[v.level + 1].stage <= v.star then
            otherState = true
        else
        end
        if (haveNum >= needNum and v.level ~= #ElfCfg and have and otherState) then
            return (haveNum >= needNum and v.level ~= #ElfCfg and have and otherState)
        end
    end
    return false
end

function ElvesSystemModel:checkGradeRed(elfId)
    local elvesInfoData = self:getElvesInfoByType(1)
    for k,v in pairs(elvesInfoData) do
        if elfId and (v.elfId == elfId ) then
            local haveNum       = 0
            local needNum       = 0 
            local itemCode      = false
            local ElfCfg        = DynamicConfigData.t_ElfMain[v.elfId]
            if ElfCfg[v.level + 1] then
                needNum     = ElfCfg[v.level + 1].experience
                itemCode    = ElfCfg[v.level + 1].itemCode
                haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
            else
                needNum     = ElfCfg[v.level].experience
                itemCode    = ElfCfg[v.level].itemCode
                haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
            end
            local num = #ElfCfg
            local have = self:isHaveElvesById(v.elfId)
            local ElfCfg   = DynamicConfigData.t_ElfMain[v.elfId]

            local otherState = false
            if v.level == #ElfCfg then
            elseif ElfCfg[v.level + 1].stage <= v.star then
                otherState = true
            else
            end 
            return (haveNum >= needNum and v.level ~= #ElfCfg and have and otherState)
        end
    end
    return false
end


-- 更新升级红点
function ElvesSystemModel:updategradeRed(noRed)
    RedManager.updateValue("V_ELVES_ATTRIB",self:checkGradeRedByIndex(1) or self:checkPromoteRed())
    Dispatcher.dispatchEvent(EventType.ElvesSystemBaseView_refreshPanal)
end

function ElvesSystemModel:checkStarRedById(index)
    local elvesInfoData = self:getElvesInfoByType(index)
    for k,v in pairs(elvesInfoData) do
        local starData = DynamicConfigData.t_ElfStar[v.elfId]
        local costData = false
        if starData[v.star + 1] then
            costData = starData[v.star + 1].cost
        else
            costData = starData[v.star].cost
        end
        local canStar = true 
        for is,vs in pairs(costData) do
            local hasNum = 0  
            if vs.type == CodeType.MONEY then
                hasNum = ModelManager.PlayerModel:getMoneyByType(vs.code)
            else
                hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(vs.code)
            end
            if canStar and hasNum < vs.amount then
                canStar = false
            end
        end
        local have = self:isHaveElvesById(v.elfId)
        if canStar and v.star ~= #starData and have then
            return canStar and v.star ~= #starData and have
        end
    end
    return false
end

function ElvesSystemModel:checkStarRed(elfId)
    local elvesInfoData = self:getElvesInfoByType(1)
    for k,v in pairs(elvesInfoData) do
        if elfId and v.elfId == elfId then
            local starData = DynamicConfigData.t_ElfStar[v.elfId]
            local costData = false
            if starData[v.star + 1] then
                costData = starData[v.star + 1].cost
            else
                costData = starData[v.star].cost
            end
            local canStar = true 
            for is,vs in pairs(costData) do
                local hasNum = 0  
                if vs.type == CodeType.MONEY then
                    hasNum = ModelManager.PlayerModel:getMoneyByType(vs.code)
                else
                    hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(vs.code)
                end
                if canStar and hasNum < vs.amount then
                    canStar = false
                end
            end
            local have = self:isHaveElvesById(v.elfId)
            return canStar and v.star ~= #starData and have
        end
    end
    return false
end


-- 更新升星红点
function ElvesSystemModel:updatestarRed()
    RedManager.updateValue("V_ELVES_UPSTAR",self:checkStarRedById(1))
end

-- 更新召唤红点
function ElvesSystemModel:updatesummonRed()
    local summonPro    = DynamicConfigData.t_ElfSummonCost
    if summonPro then 
        summonPro = summonPro[1]
    end
    local costItem = summonPro.costItem
    local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(costItem[1].code)
    RedManager.addMap("V_ELVES_SUMMOM", {"V_ELVES_SUMMOM_ONE","V_ELVES_SUMMOM_TEN"})
    RedManager.updateValue("V_ELVES_SUMMOM".."_ONE",hasNum >= 1)
    RedManager.updateValue("V_ELVES_SUMMOM".."_TEN",hasNum >= 10)
    Dispatcher.dispatchEvent(EventType.ElvesSystemBaseView_refreshPanal)
end

-- 更新精灵属性红点
function ElvesSystemModel:updateAttribRed()
end

function ElvesSystemModel:checkPromoteRed()
    local configInfo = DynamicConfigData.t_ElfAttrItem
    local itemCode = configInfo[__itemCode].itemCost
    local maxLimit = configInfo[__itemCode].limit
    local count = self.limitFetterCount[itemCode] or 0
    if count ~= 0 then
		count = count.limit or 0
	end
    local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)

    return (hasNum >= 1) and (maxLimit ~= count)
end

-- 更新精灵背包红点
function ElvesSystemModel:updateElvesBagRed()
    local listData  = ModelManager.PackModel:getElvesBag():sort_bagDatas()
    local showRed   = false
    for _,data in pairs(listData) do
        local __data = data.__data
		local __itemInfo = data.__itemInfo
		local itemCom = DynamicConfigData.t_ElfCombine[__data.code] or {}
		local _needNum = itemCom.amount or 0
		local _hasNum  = __data.amount
		local isHave = self:isHaveElvesById(__itemInfo.icon,true)
		if _hasNum >= _needNum and (not isHave) then
            showRed = true
            break
		end
    end

    RedManager.updateValue("V_ELVES_BAG",showRed)
end


function ElvesSystemModel:pack_item_change()
    self:updategradeRed()
    self:updatestarRed()
    self:updatesummonRed()
    self:updateAttribRed()
    self:updateElvesBagRed()
end

function ElvesSystemModel:money_change()
    self:updatestarRed()
end

function ElvesSystemModel:battle_end(_,args)
    self.battleElvesData[args.arrayType] = false
    self.battleElvesData[args.arrayType] = {}
end

-- 初始化精灵出手回合
function ElvesSystemModel:initFightData(arrayType)
    local battleData    = FightManager.getBettleData(arrayType)      -- 战报数据
    if (not battleData) or (not battleData.roundDataSeq) then return {} end
    local roundDataSeq  = battleData.roundDataSeq
    for iIndex,iVal in pairs(roundDataSeq) do
        local findMySeatId = {}
		local findOtherSeatId = {}
		for i=151,153 do 
			if not self.elvesFightRound[i] then
                self.elvesFightRound[i] = {}
                findMySeatId[i] = false
			end
        end
        for i=251,253 do 
			if not self.elvesFightRound[i] then
                self.elvesFightRound[i] = {}
                findOtherSeatId[i] = false
			end
		end
		for kIndex,kVal in pairs(iVal.dataSeq) do
			local fightObjDataSeq = kVal.fightObjDataSeq
			local seatId = fightObjDataSeq[1].id
            if seatId >=151 and seatId <=153 then
				findMySeatId[seatId] = true
			end
			if seatId >=251 and seatId <=253 then
				findOtherSeatId[seatId] = true
			end
        end
        for i=151,153 do 
			self.elvesFightRound[i][iIndex] = findMySeatId[i]
        end
        for i=251,253 do 
			self.elvesFightRound[i][iIndex] = findOtherSeatId[i]
        end
    end
    printTable(8848,">>>self.elvesFightRound>>",self.elvesFightRound)
	return self.elvesFightRound
end

-- 根据战报获取战斗中自己的精灵数据
function ElvesSystemModel:getBattleElvesData(arrayType)
    local battleData    = FightManager.getBettleData(arrayType)
    if not battleData or (not battleData.battleObjSeq) then return {} end
    local battleObjSeq = battleData.battleObjSeq      --#战斗角色数据
    local elvesData = {}  
    local function _findElf(code)
        for k,v in pairs(self.elvesAllData[1]) do
            if v.elfId == code then
                return v
            end
        end
    end
    for k,v in pairs(battleObjSeq) do
        if v.type == 4 and v.id >=151 and v.id <= 153 then
            local data = _findElf(v.code)
            table.insert(elvesData,data)
        end
    end
    return elvesData
end

-- 根据战报获取战斗中敌人的精灵数据
function ElvesSystemModel:getBattleOtherElvesData(arrayType)
    local battleData    = FightManager.getBettleData(arrayType)
    if not battleData or (not battleData.battleObjSeq) then return {} end
    local battleObjSeq = battleData.battleObjSeq      --#战斗角色数据
    local elvesData = {}  
    local function _findElf(code)
        for k,v in pairs(self.elvesAllData[1]) do
            if v.elfId == code then
                return v
            end
        end
    end
    for k,v in pairs(battleObjSeq) do
        if v.type == 4 and v.id >=251 and v.id <= 253 then
            local data = _findElf(v.code)
            table.insert(elvesData,data)
        end
    end
    return elvesData
end


-- 获取精灵每一回合的战报 （包括自己的和敌人的）
function ElvesSystemModel:getElvesBattleDataSeq(arrayType,roundNum)
    local battleData    = FightManager.getBettleData(arrayType)
    if not battleData then return {} end
    local roundDataSeq  = battleData.roundDataSeq
    if not roundDataSeq[roundNum] then return {} end
    for i = 1,roundNum do
        local dataSeq = roundDataSeq[i].dataSeq
        for k,v in pairs(dataSeq) do
            if (v.fightObjDataSeq[1].id >= 151 and  v.fightObjDataSeq[1].id <= 153) or (v.fightObjDataSeq[1].id >= 251 and  v.fightObjDataSeq[1].id <= 253) then
                if not self.elvesDataSeq[v.fightObjDataSeq[1].id] then
                    self.elvesDataSeq[v.fightObjDataSeq[1].id] = {}
                end
                self.elvesDataSeq[v.fightObjDataSeq[1].id] = v.fightObjDataSeq[1]
            end
        end
    end
    return self.elvesDataSeq
end

-- 回合总数
function ElvesSystemModel:getLastRoundNum(arrayType)
    local battleData    = FightManager.getBettleData(arrayType)      -- 战报数据
    if (not battleData) or (not battleData.roundDataSeq )then return 1 end
	local roundDataSeq  = battleData.roundDataSeq
	return TableUtil.GetTableLen(roundDataSeq)
end


-- 精灵当前回合之前的能量值总数
function ElvesSystemModel:getCurrentEnergyByRound(roundNum)
    local ElfEnergyData     = DynamicConfigData.t_ElfEnergy     -- 所有回合要加的能量值数据
    local totalEnergyNum    = 0

    for i = 1,roundNum do
        local roundEnergyNum    = ElfEnergyData[i].addEnergy -- 每一回合要加的能量值
        totalEnergyNum = totalEnergyNum + roundEnergyNum
    end
    return totalEnergyNum
end

-- 当前回合之前精灵出手消耗的能量值（包括当前回合）
function ElvesSystemModel:getEnergyByRound(roundNum,data,owner)
    local currentEnergy = self:getCurrentEnergyByRound(roundNum)
    local seadId = owner and 150 or 250
    for k,v in pairs(self.elvesFightRound) do
        for i = 1,3 do
            local costEnergy = 0 
            if data and data[i] then
                costEnergy = data[i].costEnergy
            end
            for o,p in pairs(v) do
                if k == (i+seadId) and o <= roundNum then
                    currentEnergy = currentEnergy - costEnergy
                end
            end
        end
    end
    return currentEnergy
end


-- 精灵羁绊使用道具
function ElvesSystemModel:reqElfFetterUseItem()
    local configInfo = DynamicConfigData.t_ElfAttrItem
    local __itemCode = 10000079
    local itemCode = configInfo[__itemCode].itemCost
    local reqInfo = {
        itemCode = itemCode,
    }
    local oldPower =  ModelManager.CardLibModel:getFightVal()
    RPCReq.Elf_UseItem(reqInfo,function(params)
        self.limitFetterCount[params.itemCode] = params or 0
        self:updateAttribRed()
        local attMap=configInfo[__itemCode].addAttr
        local attr = {}
        for o,p in pairs(attMap) do
            attr[p.type] = p.value
        end
        local addNum = HeroConfiger.CaleAttrPower(attr) or 0
        local newPower  = ModelManager.CardLibModel:getFightVal()
        RollTips.showAddFightPoint(newPower-oldPower,true)
        Dispatcher.dispatchEvent(EventType.ElvesPromoteView_refreshPanal)
    end)
end

-- #激活皮肤
-- Elf_AchieveSkin 3006 {
-- 	request {
-- 		itemUuid 				0:string #皮肤道具UUID (从背包道具里拿)
-- 	}
-- 	response {
-- 		skinId 					0:string #皮肤道具ID
-- 	}
-- }
function ElvesSystemModel:reqElfAchieveSkin(skinUid,skinId,elfId)
    local isHaveElves = self:isHaveElvesById(elfId)
    if not isHaveElves then
        RollTips.show(Desc.ElvesSystem_pleaseActivate)
        return
    end
    local reqInfo = {
        itemUuid = skinUid,    
    }
    RPCReq.Elf_AchieveSkin(reqInfo,function(params)
        if not self.skinData[skinId] then
            self.skinData[skinId] = {}
            self.skinData[skinId].code    = skinId
            self.skinData[skinId].achieve = 1
        else
            self.skinData[skinId].code    = skinId
            self.skinData[skinId].achieve = 1
        end
        for i = 1,#self.elvesAllData do
            for k,v in pairs(self.elvesAllData[i]) do
               if v.elfId == elfId then
                   local power =  self:getElvesPower(v,v.star)
                   v.power = power
               end
            end
        end

        local skinData = self:getElvesSkinInfoById(elfId,skinId)
        print(8848,">>>激活精灵皮肤>>>" ..skinData.name )
        ViewManager.open("ElvesGetSkinView",{elfId=elfId,data = skinData})
        Dispatcher.dispatchEvent(EventType.ElvesSkin_refreshPanal)
        Dispatcher.dispatchEvent(EventType.ElvesSystemBaseView_refreshPanal)
    end)
end

-- #设置皮肤
-- Elf_SetSkin 17966 {
-- 	request {
-- 		elfUuid 			0:string #精灵UUID
-- 		skinId 				1:integer #皮肤ID
-- 	}
-- 	response {
-- 		elfUuid 			0:string #精灵UUID
-- 		skinId 				1:integer #皮肤ID
-- 	}
-- }
function ElvesSystemModel:reqElfSetSkin(elfUid,skinId,elfId)
    if skinId == 1 then skinId = 0 end
    local reqInfo = {
        elfUuid = elfUid,
        skinId = skinId,
    }
    --printTable(8848,">>>设置精灵皮肤>>>" ,reqInfo )
    -- :getElvesBaseAttr(elfId,skinId)
    RPCReq.Elf_SetSkin(reqInfo,function(params)
        for i = 1,#self.elvesAllData do
            for k,v in pairs(self.elvesAllData[i]) do
                if v.elfId == elfId then
                    if skinId == 0 then skinId = 1 end
                    v.skinId = skinId
                end
            end
        end
        local skinData = self:getElvesSkinInfoById(elfId,skinId)
        print(8848,">>>设置精灵皮肤>>>" ..skinData.name )
        Dispatcher.dispatchEvent(EventType.ElvesSkin_refreshPanal)
        Dispatcher.dispatchEvent(EventType.ElvesSystemBaseView_refreshPanal)
    end)
end

-- #分解皮肤 
-- Elf_DecomposeSkin 18335 {
-- 	request {
-- 		skinId 				1:integer #皮肤ID
-- 	}
-- 	response {
-- 		elfUuid 			0:string #精灵UUID
-- 		skinId 				1:integer #皮肤ID
-- 	}
-- }

function ElvesSystemModel:reqElfDecomposeSkin(skinId)
    local reqInfo = {
        skinId = skinId,
    }
    RPCReq.Elf_DecomposeSkin(reqInfo,function(params)
        local skinData = self:getSkinInfoBySkinId(skinId)
        print(8848,">>>分解皮肤>>>" ..skinData.name )
    end)
end

-- #desc 分解指定格子道具
-- Bag_DecomposeItem 6914 {
-- 	request {
-- 		items 				0:*PItem_Decompose #分解
-- 	}
-- 	response {
-- 		res						1:*Common_GameRes #分解获得的道具列表
-- 	}
-- }
-- #分解道具结构
-- .PItem_Decompose {
--     bagType             1:integer #背包类型
--     itemId              2:integer #物品ID
--     amount              3:integer #物品数量
-- }

function ElvesSystemModel:reqElfDecomposeSkin2(reqInfo)
    RPCReq.Bag_DecomposeItem({items=reqInfo},function(params)
        printTable(8848,reqInfo,">>>分解精灵皮肤>>>")
    end)
end

-- 获取某个精灵的所有皮肤
function ElvesSystemModel:getElvesSkinData(elfId)
    local skinDataCfg = DynamicConfigData.t_ElfSkin[elfId] or {}
    local skinData = {}
    local function _findElf(elfId)
        for k,v in pairs(self.elvesAllData[1]) do
            if v.elfId == elfId then
                return v
            end
        end
    end
    local elfData = _findElf(elfId)   
    if not skinDataCfg[1] then --  插入精灵默认皮肤的信息
        skinDataCfg[1] = {}
        skinDataCfg[1].skinId = 1
        skinDataCfg[1].elfId = elfId
        skinDataCfg[1].model = elfData.model
        skinDataCfg[1].have  = elfData.have
        skinDataCfg[1].name  = elfData.elfName
    end
    local ll = 1
    for k,v in pairs(skinDataCfg) do 
        if v.skinId == 1 then
            v.sort = 2
            table.insert(skinData,v)
        else
            if ll == 2 then
                ll = ll + 1
            end
            v.sort = ll
            ll = ll + 1
        end
        table.insert(skinData,v)
    end
    local keys ={
        -- {key="sort",asc = false},
        {key="skinId",asc = false},
    }
    TableUtil.sortByMap(skinData,keys)
    table.insert(skinData,skinData[#skinData])
    TableUtil.sortByMap(skinData,keys)
    return skinData or {}
end

-- 获取精灵皮肤属性
function ElvesSystemModel:getElvesBaseAttr(elfId,skinId)
    local skinInfo = self:getElvesSkinInfoById(elfId,skinId)
    local basicAttr = skinInfo.basicAttr or {}   -- 基础属性
    local attrDesc = skinInfo.attrDesc or {} -- 特殊属性
    local t_combat = DynamicConfigData.t_combat
    local attribute = {}
    for k,v in pairs(basicAttr) do
        local data = {}
        data.type = v.type
        data.value = v.value
        data.name  = t_combat[v.type].name or ""
        table.insert(attribute,data)
    end
    local ll = 1000
    for k,v in pairs(attrDesc) do
        local data  = {}
        data.type   = ll
        data.value  = 0
        data.desc = v   -- 特殊属性直接使用描述字段显示数值
        data.name = "" --t_combat[v.type].name or ""
        table.insert(attribute,data)
        ll = ll + 1
    end
    local keys = {
        {key="type",asc=false},
    }
    TableUtil.sortByMap(attribute,keys)
    return attribute or {}
end

-- 通过精灵id和皮肤id获取精灵皮肤信息
function ElvesSystemModel:getElvesSkinInfoById(elfId,skinId)
    if skinId == 0 then skinId = 1 end
    local skinData = self:getElvesSkinData(elfId)
    local function _findSkin(skinId)
        for k,v in pairs(skinData) do
            if v.skinId == skinId then
                return v
            end
        end
        return {}
    end
    local skinInfo = _findSkin(skinId)
    return skinInfo
end

-- 从服务端下推的皮肤数据中判断当前皮肤（皮肤id）有没有激活 
function ElvesSystemModel:checkSkinById(skinId)
    local data = self.skinData[skinId]
    if data and data.achieve then
        if data.achieve == 1 then
            return true
        else
            return false
        end
    end
    return false
end

-- 计算精灵皮肤战力
function ElvesSystemModel:getElvesSkinPower(data)
    local power = 0
    local attr = {}
    for o,p in pairs(data.basicAttr) do
        if p.type <= 6 then
            attr[p.type] = p.value
        end
    end
    power = HeroConfiger.CaleAttrPower(attr)
    power = power + data.attrCombat
    return power
end

-- 通过精灵皮肤id获取皮肤信息
function ElvesSystemModel:getSkinInfoBySkinId(skinId)
    local data = DynamicConfigData.t_ElfSkinInfo
    if data and data[skinId] then
        return data[skinId]
    end
    return {}
end

-- 
function ElvesSystemModel:setAttackPos(view,skillId,beAttacker,skillObj)
    local initPos   = view:getPosition()
    local target    = initPos
	local skillInfo = SkillConfiger.getSkillById(skillId)
	local skillPos  = skillInfo.skillPos

	local  function addDistance(toPos) --计算好位置之后还要加上填表的偏移
		-- if self.heroPos==HeroPos.player then
			target={x=toPos.x+skillInfo.distance[1],y=toPos.y-skillInfo.distance[2]}
		-- else
		-- 	target={x=toPos.x-skillInfo.distance[1],y=toPos.y-skillInfo.distance[2]}
		-- end
    end
    
    local function getSelfScreenPos()
       return view:getParent():localToGlobal(view:getPosition())
    end
	local function beginMoveTo()
		if skillPos==2 then --近距离贴脸第一个目标施法
			local toPos= self:getSelfLocalPos(getSelfScreenPos(),view)
			addDistance(toPos)
		end
		if skillPos==1 then
			target= initPos--原地施法
			addDistance(target)
		end
		if skillPos==3 then
			local centerPoint=BattleModel:getMapPoint()["arrayCenter"]
			target= self:getSelfLocalPos(centerPoint:localToGlobal(Vector2.zero),view)--场地中间施法
			addDistance(target)
		end
		skillObj:setPosition(target.x,target.y)
	end
	-- if  skillInfo.liHui~=nil and skillInfo.liHui~=""then
	-- 	BattleManager:printTime("liHui","a")
	-- 	SkillManager.lihuiEffect(1,skillInfo,function ()
	-- 			BattleManager:printTime("liHui","b")
	-- 			beginMoveTo()--有例会先播放再进行攻击目标站位
	-- 		end)
	-- else 
		beginMoveTo()
	-- end
end

--屏幕坐标相对于该组件的局部坐标
function ElvesSystemModel:getSelfLocalPos(pos,parent,view)
	if parent==nil then
		parent = view:getParent()
	end
	return parent:globalToLocal(pos)
end

-- 通过战斗传的id判断是不是精灵
function ElvesSystemModel:checkIsElvesById(id)
    if (id >= 151 and id <=153) or (id >=251 and id <=253) then
        return true
    end
    return false
end

-- 通过精灵的位置id获取精灵的皮肤id
function ElvesSystemModel:getBattleElvesSkin(id)
    local arrayType     = FightManager.frontArrayType()--ModelManager.BattleModel:getRunArrayType() or false
    -- if not arrayType then 
    --     arrayType = self.arrayType 
    -- end
    -- if not arrayType then return 1 end
    local battleData    = FightManager.getBettleData(arrayType) or {}
    local battleObjSeq = battleData.battleObjSeq or {}     --#战斗角色数据
    for k,v in pairs(battleObjSeq) do
        if v.type == 4 and v.id ==id then
            return v.skinId
        end
    end
end

-- 通过精灵的位置id获取精灵的技能id
function ElvesSystemModel:getElvesSkillById(id,skill)
    local skinId = self:getBattleElvesSkin(id) or 0
    if skinId == 0 then
        return skill
    end

    local skillInfo = self:getSkinInfoBySkinId(skinId)
    if skillInfo and skillInfo.skillId then
        return skillInfo.skillId
    end
end

-- 通过精灵的技能id获取冷却回合
-- siteId   位置
-- data     单个精灵的数据
function ElvesSystemModel:getBattleElvesRoundCD(siteId,data,roundNum)
    local arrayType     = FightManager.frontArrayType()
    local battleData    = FightManager.getBettleData(arrayType) or {}
    local battleObjSeq  = battleData.battleObjSeq or {}     --#战斗角色数据
    local skinId        = false
    local skillId       = false

    -- 获取精灵的皮肤id
    for k,v in pairs(battleObjSeq) do
        if v.type == 4 and v.id == siteId then
            skinId =  v.skinId
            if skinId == 0 then 
                skinId = 1
            end
            break
        end
    end

    -- 通过皮肤id获取技能id
    local coolRound = 0
    if not skinId then
        return coolRound
    end
    if skinId == 1 then
        skillId = data.skillId
    end
    if DynamicConfigData.t_ElfSkinSkill and DynamicConfigData.t_ElfSkinSkill[data.elfId] and DynamicConfigData.t_ElfSkinSkill[data.elfId][skinId]  and DynamicConfigData.t_ElfSkinSkill[data.elfId][skinId][data.skillId] then
        skillId = DynamicConfigData.t_ElfSkinSkill[data.elfId][skinId][data.skillId].skinSkillId
    end

    -- 通过技能id获取技能冷却回合
    local skillInfo 	= false
    if DynamicConfigData.t_skill and DynamicConfigData.t_skill[skillId] then
        skillInfo = DynamicConfigData.t_skill[skillId]
        coolRound = skillInfo.coolRound
    end

     -- 获取所有精灵的出手回合数据
    local cdRound   = 0         -- 总的冷却回合数
    local allElvesFightRound = self:initFightData(arrayType) or {} 
    local elvesFightRound    = allElvesFightRound[siteId] or {}     -- 单个精灵的出手回合数据
    local minRound  = 0         -- 最小出手回合
    for roundFigth,v in pairs(elvesFightRound) do
        if minRound == 0 then
            minRound = roundFigth
        end
        if minRound > roundFigth then
            minRound = roundFigth 
        end
        if roundNum >= roundFigth then
            cdRound = cdRound + coolRound
        end
    end
    cdRound = cdRound + minRound
    return cdRound,coolRound,minRound
end

function ElvesSystemModel:getElvesInfoByCode(code,star,level)
    if not star or (star == 0) then
        star = 1
    end
    if not level or (level == 0) then
        level = 1
    end
    local elfMain = DynamicConfigData.t_ElfMain
    if elfMain and elfMain[code] and elfMain[code][level] then
        elfMain[code][level].star = star
    end
    return elfMain[code][level]
end

-- 获取召唤时精灵的颜色
function ElvesSystemModel:getElvesColor()
    local color = 3
    local ElfMain =  DynamicConfigData.t_ElfMain
    for k,v in pairs(self.summonElves) do
        local elfCfg = ElfMain[v][1]
        color = elfCfg.color > color and elfCfg.color or color
    end
    return color
end


function ElvesSystemModel:pack_elves_change()
    self:updategradeRed()
    self:updatestarRed()
    self:updatesummonRed()
    self:updateAttribRed()
    self:updateElvesBagRed()
end



return ElvesSystemModel