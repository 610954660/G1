
-- added by wyz
-- 装备目标

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local EquipTargetView = class("EquipTargetView",Window)

function EquipTargetView:ctor()
    self._packName  = "EquipTarget"
    self._compName  = "EquipTargetView"

    self.banner     = false
    self.list_reward  = false
    self.list_page    = false
    self.pageIndex    = 1
    self.pageIndexFlag = false
    
	self.timer 		    = false
    self.txt_countTitle = false
    self.txt_countTimer = false
    self.isEnd 			= false 	-- 判断活动有没有结束
    self.actId 			= false
end


function EquipTargetView:_initUI()
    self.banner         = self.view:getChildAutoType("banner")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.list_page      = self.view:getChildAutoType("list_page")
    self.txt_countTitle = self.view:getChildAutoType("txt_countTitle")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.txt_countTitle:setText(Desc.EquipTargetAct_timeTitle)
    self.banner:setURL("UI/EquipTarget/banner.png")
end


function EquipTargetView:_initEvent()
    self:EquipTargetView_refreshPanal()
end


function EquipTargetView:EquipTargetView_refreshPanal()
    printTable(8848,">>>ModelManager.EquipTargetModel.jump 222>>>",ModelManager.EquipTargetModel.jump)
    
    if not self.pageIndexFlag then
        self.pageIndex = (ModelManager.EquipTargetModel.jump) and 3 or 1
    end
    local equipTargeData =  EquipTargetModel:getEquipTargetDataCfg()
    self.list_page:setSelectedIndex(self.pageIndex-1)
    self.list_page:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = equipTargeData[index][1]
        local title = obj:getChildAutoType("title")
        local img_red = obj:getChildAutoType("img_red")
        RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.EquipMission.. index, img_red)
        title:setText(data.setName)
    end)
    self.list_page:setData(equipTargeData)
    self.list_page:removeClickListener(11)
    self.list_page:addClickListener(function()
        local index = self.list_page:getSelectedIndex() + 1
        self.pageIndex = index
        self.pageIndexFlag = true
       self:refreshList(self.pageIndex)
    end,11)
    self:refreshList(self.pageIndex)
end

function EquipTargetView:refreshList(pageIndex)
    local equipTargeData    =  EquipTargetModel:getEquipTargetDataCfg()
    local equipTargeReqInfo =  ModelManager.EquipTargetModel:getEquipTargetData()
    self.list_reward:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = equipTargeData[pageIndex][index]
        local takeCtrl    = obj:getController("takeCtrl")   -- 0 不可领取 1 可领取 2 已领取
        local txt_passNum = obj:getChildAutoType("txt_passNum")
        local txt_title   = obj:getChildAutoType("txt_title")
        local btn_take    = obj:getChildAutoType("btn_take")
        local btn_travel  = obj:getChildAutoType("btn_travel")
        local list_reward = obj:getChildAutoType("list_reward")
        
        local img_red     = btn_take:getChildAutoType("img_red")
        RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.EquipMission.. pageIndex .. data.id, img_red)
        txt_passNum:setText(string.format("[color=#24A41C]%s[/color]/%s",data.acc,data.count))
        if data.state == 0 then
            takeCtrl:setSelectedIndex(1)
        elseif data.state == 1 then
            takeCtrl:setSelectedIndex(0)
        elseif data.state == 2 then
            takeCtrl:setSelectedIndex(2)
        end
        
        txt_title:setText(data.desc)
        local rewardData = data.reward
        list_reward:setItemRenderer(function(idx2,obj2)
            local itemCell = BindManager.bindItemCell(obj2)
            local reward = rewardData[idx2+1]
            itemCell:setData(reward.code,reward.amount,reward.type)
            -- 如果奖励已领取
            -- itemCell:setIsHook(true)
        end)
        list_reward:setData(rewardData)

        btn_take:removeClickListener(11)
        btn_take:addClickListener(function()
            local reqInfo = {
                taskId = data.id,
            }
            RPCReq.Activity_EquipMission_GetReward(reqInfo,function()
                print(8848,">>>>>装备目标，奖励领取成功！>>>>>")  
                self.pageIndexFlag = true
            end)
        end,11)

        btn_travel:removeClickListener(11)
        btn_travel:addClickListener(function()
            if self.isEnd then
				RollTips.show(Desc.CollectThing_end)
				return
            end
            if data.windowId == ModuleId.EquipUpStar.id then
                ViewManager.close("ActivityFrame4View")
            end
            ModuleUtil.openModule(data.windowId, true)
        end,11)
    end)
    self.list_reward:setData(equipTargeData[pageIndex])
    self:updateCountTimer()
end

-- 倒计时
function EquipTargetView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.EquipMission)
    -- printTable(8848,"actData>>>>>>>",actData)
    -- do return end
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end

    if status == 2 and addtime == -1 then
        self.isEnd = false
        self.txt_countTimer:setText(Desc.activity_txt5)
    else
        local lastTime = addtime / 1000
        if lastTime == -1 then
            self.txt_countTimer:setText(Desc.activity_txt5)
        else
            if not tolua.isnull(self.txt_countTimer) then
                self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            end
            local function onCountDown(time)
                if not tolua.isnull(self.txt_countTimer) then
                    self.isEnd = false
                    self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
                end
            end
            local function onEnd(...)
                self.isEnd = true
                if not tolua.isnull(self.txt_countTimer) then
                --  self.activityEnable = true
                 self.txt_countTimer:setText(Desc.activity_txt18)
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function EquipTargetView:_exit()
    Scheduler.scheduleNextFrame(function() 
        ModelManager.EquipTargetModel.jump = false
    end)
	TimeLib.clearCountDown(self.timer)
end

return EquipTargetView