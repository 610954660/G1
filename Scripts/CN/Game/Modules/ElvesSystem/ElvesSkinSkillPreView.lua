-- added by wyz
-- 精灵皮肤技能预览

local ElvesSkinSkillPreView = class("ElvesSkinSkillPreView",Window)
local ElveSkillManage = require "Game.Modules.ElvesSystem.ElveSkillManage"

function ElvesSkinSkillPreView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesSkinSkillPreView"

    self.RHero  = {}
    self.LHero  = {}
    self.skillId   = false
    self.data   = {}
    self.btn_skip = false
    self.normalEffec = false
    self.btn_speed   = false
    self.centerPoint = false
    self.enemyCenter = false
    self.playerCenter = false
    self.arrayCenter = false
    self.skinId = false
    self.hierarchy = 0
end

function ElvesSkinSkillPreView:_initUI()
    for i = 1,6,1 do
        self.RHero[i] = self.view:getChildAutoType("R_" .. i)
        self.LHero[i] = self.view:getChildAutoType("L_" .. i)
    end
    self.btn_skip = self.view:getChildAutoType("btn_skip")
    self.btn_speed  = self.view:getChildAutoType("btn_speed")

    self.skillId = self._args.skillId
    self.data = self._args.data
    self.skinId = self._args.skinId
    local fullScreen = self.view:getChildAutoType("frame/fullScreen")
    fullScreen:setIcon("Map/100024.jpg")
    
    self.btn_skip:removeClickListener(11)
    self.btn_skip:addClickListener(function()
        ViewManager.close("ElvesSkinSkillPreView")
    end,11)

end

function ElvesSkinSkillPreView:_initEvent()
    self:refreshPanal()
end

function ElvesSkinSkillPreView:refreshPanal()
    self.hierarchy = ElveSkillManage.getHierarchy(self.data.elfId,self.skillId,self.skinId)
    self:setSpeed()
    self:setMySquad()
    self:setOtherSquad()
    for i = 1,6,1 do
        self.LHero[i]:displayObject():setLocalZOrder(self.hierarchy)
        self.RHero[i]:displayObject():setLocalZOrder(self.hierarchy)
    end
    self.btn_skip:displayObject():setLocalZOrder(self.hierarchy)
    self.btn_speed:displayObject():setLocalZOrder(self.hierarchy)
    self:playEffect()
end

-- 播放技能特效
function ElvesSkinSkillPreView:playEffect()
    -- ElvesSystemModel:setAttackPos(self.view,self.skillId,self.RHero[2],false,false)
    ElveSkillManage.normalEffect2(self.skillId,self.view,self.RHero,self.LHero,self.data.elfId,self.skinId)
end

-- 设置我方阵容
function ElvesSkinSkillPreView:setMySquad()
    local allyTroop = self.data.allyTroop
    for k,v in pairs(allyTroop) do
        if v ~= 0 then
            self:createHeroModel(v,k,false)
        end
    end
end

-- 设置敌方阵容
function ElvesSkinSkillPreView:setOtherSquad()
    local enemyTroop = self.data.enemyTroop
    for k,v in pairs(enemyTroop) do
        if v ~= 0 then
            self:createHeroModel(v,k,true)
        end
    end
end


-- 创建英雄模型
function ElvesSkinSkillPreView:createHeroModel(modelId,index,other)
    if other then
        if self.RHero[index] then
            self.RHero[index]:displayObject():removeAllChildren()
        end
        local skeletonNode = SpineUtil.createModel(self.RHero[index], {x = 0, y =0}, "stand", modelId,true)
    else
        if self.LHero[index] then
            self.LHero[index]:displayObject():removeAllChildren()
        end
        local skeletonNode = SpineUtil.createModel( self.LHero[index], {x = 0, y =0}, "stand", modelId,true)
    end
end

-- 设置倍数
function ElvesSkinSkillPreView:setSpeed()
    self.btn_speed:removeClickListener(11)
    self.btn_speed:getController("speed"):setSelectedIndex(1)
    self.btn_speed:addClickListener(function()
        BattleModel:saveOpenSpeed()
        local speedIndex=BattleModel:getGameSpeed()
        local changeIndex=false
        if speedIndex==1 then
            changeIndex=2
        elseif speedIndex==2 then
            changeIndex=3
        elseif speedIndex==3 then
            changeIndex=1
        end
        self.btn_speed:getController("speed"):setSelectedIndex(changeIndex)
        BattleModel:changeSpeedIndex(changeIndex)
        BattleModel:saveGameSpeed(changeIndex)
    end,11)
end


function ElvesSkinSkillPreView:_exit()
    ElveSkillManage.removeEffect2(self.skillId,self.data.elfId,self.skinId)
    BattleModel:changeSpeedIndex(1)
    BattleModel:changeGameSpeed(1)
    BattleModel:saveGameSpeed(1)
end

return ElvesSkinSkillPreView