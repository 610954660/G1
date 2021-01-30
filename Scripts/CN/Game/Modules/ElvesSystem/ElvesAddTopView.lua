-- added by wyz
-- 精灵备战界面


local ElvesAddTopView = class("ElvesAddTopView",Window)

function ElvesAddTopView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesAddTopView"

    self.interfaceCtrl  = false     -- 判断在哪个界面  0 备战 1战斗
    self.haveElves      = false     -- 判断敌方阵容有没有精灵上阵
    self.mySkillEnergy  = false     -- 我的能量值
    self.otherSkillEnergy   = false -- 对方阵容的能量值
    self.list_myElves    = false    -- 我的阵容列表 
    self.list_otherElves = false    -- 对方阵容列表
    self.planId          = 1        -- 方案id
    self.elvsBattleData  = {}       -- 自己的精灵阵容信息
    self.planData        = {}       -- 精灵方案数据

    self.roundNum     = 1       -- 回合数
    self.dataSeq      = {}      -- 战斗每一回合的数据
    self.otherReqData = {}      -- 敌人阵容信息
    self.arrayType    = false
    self.elvesFightRound = {}   -- 精灵出手的回合
end


function ElvesAddTopView:_initUI()
    self.interfaceCtrl = self.view:getController("interfaceCtrl")
    self.haveElvesCtrl = self.view:getController("haveElvesCtrl")
    self.mySkillEnergy = self.view:getChildAutoType("mySkillEnergy")
    self.otherSkillEnergy = self.view:getChildAutoType("otherSkillEnergy")
    self.list_myElves    = self.view:getChildAutoType("list_myElves")
    self.list_otherElves = self.view:getChildAutoType("list_otherElves")
end

function ElvesAddTopView:initData()
    self.planId          = 1        -- 方案id
    self.elvsBattleData  = {}       -- 自己的精灵阵容信息
    self.otherReqData    = {}      -- 敌人阵容信息
    self.planData        = {}       -- 精灵方案数据
    self.roundNum        = 1       -- 回合数
    self.arrayType       = false   
    self.dataSeq         = {}      -- 战斗每一回合的数据（存）（已存）
end

function ElvesAddTopView:_initEvent()
    self.arrayType =  ModelManager.BattleModel:getRunArrayType() --or false
    if not self.arrayType then
        return
    end
    if self.arrayType and not ElvesSystemModel.battleElvesData[self.arrayType] then
        ElvesSystemModel.battleElvesData[self.arrayType] = {}
    end
end

-- #16694-【精灵】战斗界面增加一个说明
function ElvesAddTopView:skillEnergyClick()
    local viewInfo=ViewManager.getViewInfo("BattleBeginView")
    local BattleBeginView=viewInfo.window
    local shakeView = BattleBeginView.shakeView
    local leftGroup = self.view:getChildAutoType("leftGroup")
    local rightGroup = self.view:getChildAutoType("rightGroup")
    local viewInfo=ViewManager.getViewInfo("BattleBeginView")
    local BattleSecnesView=viewInfo.window.ctlView["BattleSecnesView"]
    local hierarchy = BattleSecnesView.view:getSortingOrder()
    self.view:setSortingOrder(hierarchy)

    local txt_tips1 = self.view:getChildAutoType("txt_tips1")
    txt_tips1:setText(Desc.ElvesSystem_str1)
    local txt_tips2 = self.view:getChildAutoType("txt_tips2")
    txt_tips2:setText(Desc.ElvesSystem_str1)

    self.mySkillEnergy:removeClickListener(456)
    self.mySkillEnergy:addClickListener(function()  
        leftGroup:setVisible(not leftGroup:isVisible())
    end,456)

    self.otherSkillEnergy:removeClickListener(456)
    self.otherSkillEnergy:addClickListener(function()  
        rightGroup:setVisible(not rightGroup:isVisible())
    end,456)

    shakeView:removeClickListener(456)
    shakeView:addClickListener(function() 
        rightGroup:setVisible(false)
        leftGroup:setVisible(false)
    end,456)
end

function ElvesAddTopView:ElvesAddTopView_refresh(_,params)
    self.elvsBattleData = ElvesSystemModel:getMyElvesBattleReqInfo()
    self.planId = ElvesSystemModel:getPlanId(self.elvsBattleData.arrayType)

    if not ElvesSystemModel.battlePrepareIsShow then
        self.elvesFightRound = ElvesSystemModel:initFightData(self.arrayType) or {}
        self.dataSeq =  ElvesSystemModel:getElvesBattleDataSeq(self.arrayType,self.roundNum)
        self.planData  = ElvesSystemModel:getBattleElvesData(self.arrayType)
        self.otherReqData = ElvesSystemModel:getBattleOtherElvesData(self.arrayType)
        self:skillEnergyClick()
    else
        self.planData   = ElvesSystemModel:getElvesEnterData(self.planId)  -- 自己的阵容
        self.otherReqData = ElvesSystemModel.elvesOtherPrepareInfo or {}
    end

    if self.elvsBattleData.arrayType and ElvesSystemModel.battlePrepareIsShow and (not ElvesSystemModel.arrays[self.elvsBattleData.arrayType]) then
        -- 在备战界面请求自己的阵容信息
        local reqInfo = {
            arrayType = self.elvsBattleData.arrayType, -- 阵容类型
            planId    = self.planId, -- 方案id
        }
        if #self.planData ~= 0 then
            RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
                -- 刷新界面
                local data = {
                    arrayType = self.elvsBattleData.arrayType,
                    planId    = self.planIndex,
                }
                ElvesSystemModel:setMyElvesBattleReqInfo(self.elvsBattleData.arrayType,self.planId)
            end)
        end
    end
    
    -- 判断在哪个界面
    self.interfaceCtrl:setSelectedIndex(ElvesSystemModel.battlePrepareIsShow and 0 or 1)
    -- 自己的精灵
    self:showMyElvesItem(self.elvsBattleData.arrayType,self.roundNum)
    -- 敌人的精灵
    self.otherSkillEnergy:setVisible(false)
    self:showOtherElvesItem()

    self:initEnergy(self.roundNum)
end

-- 我的精灵
function ElvesAddTopView:showMyElvesItem(arrayType,roundNum)
    for i =  1,3 do 
        local childId = 150 + i
        local index = i
        local obj =  self.list_myElves:getChild(""..childId)
        if not tolua.isnull(obj) then
            self:setItemObj(index,obj,childId,roundNum)
        end
    end
    self.list_myElves:removeClickListener(888)
    self.list_myElves:addClickListener(function()
          ViewManager.open("ElvesPlanView",{arrayType = arrayType})
    end,888)
    self.list_myElves:setTouchable(ElvesSystemModel.battlePrepareIsShow)
end

-- 敌人的精灵
function ElvesAddTopView:showOtherElvesItem()
    local roundNum      = ModelManager.BattleModel.roundNum
	roundNum = (roundNum == 0) and 1 or roundNum
    if TableUtil.GetTableLen(self.otherReqData)>0 then
        self.list_otherElves:setVisible(true)
        if not ElvesSystemModel.battlePrepareIsShow then self.otherSkillEnergy:setVisible(true) end
        -- 敌人的阵容
        for i =  1,3 do 
            local childId = 250 + i
            local index = i
            local obj =  self.list_otherElves:getChild(""..childId)
            if not tolua.isnull(obj) then
                self:setItemObj(index,obj,childId,roundNum)
            end
        end
    else
        self.otherSkillEnergy:setVisible(false)
        self.list_otherElves:setVisible(false)
    end
end


function ElvesAddTopView:initEnergy(roundNum)
    -- 能量值刷新
    local myEnergyNum = ElvesSystemModel:getEnergyByRound(roundNum,self.planData,true)
    local otherEnergyNum = ElvesSystemModel:getEnergyByRound(roundNum,self.otherReqData,false)
    local myEnergy  = self.mySkillEnergy:getChildAutoType("txt_energy")
    local otherEnergy  = self.otherSkillEnergy:getChildAutoType("txt_energy")
    otherEnergy:setText(otherEnergyNum)
    myEnergy:setText(myEnergyNum)
end


function ElvesAddTopView:setItemObj(index,obj,childId,roundNum)
    local data           = {}
    if self:checkRange(childId) then
        data = self.planData[index]
    else
        data = self.otherReqData[index]
    end
    local haveBattleCtrl = obj:getController("haveBattleCtrl") -- 有没有上阵 0 有 1 没有
    local interfaceCtrl  = obj:getController("interfaceCtrl")  -- 判断在哪个界面  0 备战 1 战斗
    local cdCtrl         = obj:getController("cdCtrl")  -- 判断技能有没有冷却  0 冷却中 1 冷却完成
    local iconLoader     = obj:getChildAutoType("iconLoader/iconLoader")
    local txt_energy     = obj:getChildAutoType("txt_energy")
    local txt_CD         = obj:getChildAutoType("txt_CD")
    local cdNum          = 0
    cdCtrl:setSelectedIndex(1)

    if not ElvesSystemModel.battlePrepareIsShow then
        if  data then
            local cdRound,coolRound,minRound = ElvesSystemModel:getBattleElvesRoundCD(childId,data,roundNum)
            cdNum   = cdRound - roundNum
            local condition1 = (minRound and (roundNum <= minRound))
            local condition2 = ((cdNum <= 0 or cdNum == coolRound) and self.elvesFightRound and self.elvesFightRound[childId] and self.elvesFightRound[childId][roundNum])
            if  condition1 or condition2 or cdNum < 0 then
                cdCtrl:setSelectedIndex(1)  -- 冷却完成
            else
                cdCtrl:setSelectedIndex(0)      -- 冷却中
            end
            txt_CD:setText(cdNum)
        end
    end
    
    interfaceCtrl:setSelectedIndex(ElvesSystemModel.battlePrepareIsShow and 0 or 1)
    if not data then
        haveBattleCtrl:setSelectedIndex(1)
        iconLoader:setURL("")
    else
        haveBattleCtrl:setSelectedIndex(0)
        local elfId = data.elfId

        local url = ItemConfiger.getItemIconByCode(elfId)
        iconLoader:setURL(url)
        txt_energy:setText(data.costEnergy)
    end
end

-- 检测精灵位置的范围
function ElvesAddTopView:checkRange(childId)
    if childId >= 151 and childId <= 153 then   -- 自己的
        return true
    end
    return false    -- 敌人的
end

function ElvesAddTopView:battle_roundStar(_,params)
    if not params.arrayType then 
        return
    end
    local roundNum      =  ModelManager.BattleModel.roundNum         -- 回合数
    roundNum = (roundNum == 0) and 1 or roundNum
    self.arrayType = params.arrayType or false
    if not ElvesSystemModel.battleElvesData[params.arrayType] then
        ElvesSystemModel.battleElvesData[params.arrayType] = {}
    end
    self.roundNum = roundNum
    if roundNum == 1 then
        self.elvesFightRound = ElvesSystemModel:initFightData(params.arrayType) or {}
        if not ElvesSystemModel.battleElvesData[params.arrayType] then
            self:initData()
        end
    end
    self:ElvesAddTopView_refresh()
end


function ElvesAddTopView:battle_roundEnd(_,params)
    if not params.arrayType then 
        return
    end
    self.arrayType = params.arrayType or false
    local roundNum      =  ModelManager.BattleModel.roundNum         -- 回合数
    roundNum = (roundNum == 0) and 1 or roundNum
    roundNum = roundNum + 1
    self.dataSeq =  ElvesSystemModel:getElvesBattleDataSeq(self.arrayType,roundNum)
    local lastRound = ElvesSystemModel:getLastRoundNum(params.arrayType)
    -- 我的精灵
    if roundNum <= lastRound then
        self:initEnergy(roundNum,true)
        self:showMyElvesItem(self.arrayType,roundNum)
        -- 敌人的精灵
        self:showOtherElvesItem()
    end
end


-- 精灵出手
function ElvesAddTopView:ElvesAddTopView_fightFresh(_,params)
    self:initEnergy(self.roundNum,true)
end


function ElvesAddTopView:_exit()

end

return ElvesAddTopView