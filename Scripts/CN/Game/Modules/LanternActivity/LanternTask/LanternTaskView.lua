-- added by wyz
-- 扭蛋活动 扭蛋任务

local LanternTaskView = class("LanternTaskView",Window)

function LanternTaskView:ctor()
    self._packName  = "TwistEggTask"
    self._compName  = "TwistEggTaskView"

    self.txt_countTitle = false     -- 倒计时标题
    self.txt_countTimer = false     -- 活动倒计时
    self.banner         = false     -- 宣传图
    self.txt_tips       = false     -- 提示文本
    self.AllRewardItem  = false     -- 所有任务完成情况汇总
    self.list_task      = false     -- 任务列表

    self.isEnd          = false     -- 判断活动结没结束
    self.timer          = false
end

function LanternTaskView:_initUI()
    self.txt_countTitle = self.view:getChildAutoType("txt_countTitle")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.banner         = self.view:getChildAutoType("banner")
    self.list_task      = self.view:getChildAutoType("list_task")
    self.AllRewardItem  = self.view:getChildAutoType("AllRewardItem")
    self.txt_tips       = self.view:getChildAutoType("txt_tips")
    self.banner:setURL("UI/TwistEgg/img_task_banner.png")
end

function LanternTaskView:_initEvent()
    self:LanternTask_refreshPanal()
end

function LanternTaskView:LanternTask_refreshPanal()
    self:refreshPanal()
end

function LanternTaskView:refreshPanal()
    self:setTotalTaskItem()
    self.txt_tips:setText(Desc.TwistEggTask_tips)
    self:setTaskList()
    self:updateCountTimer()
end

-- 设置总的任务进度
function LanternTaskView:setTotalTaskItem()
    local totalTaskData     = LanternTaskModel:getAllTaskData()   -- 总任务进度
    local totalProgressBar  = self.AllRewardItem:getChildAutoType("progressBar")
    local totalPVal         = totalProgressBar:getChildAutoType("val")
    local totalPCount       = totalProgressBar:getChildAutoType("count")
    local totalItemCell     = BindManager.bindItemCell(self.AllRewardItem:getChildAutoType("itemCell"))
    local totalBtn_take     = self.AllRewardItem:getChildAutoType("btn_take")    -- 领取按钮
    local totalTxt_title    = self.AllRewardItem:getChildAutoType("txt_title")
    local totalTakeCtrl          = self.AllRewardItem:getController("takeCtrl")       -- 0 可领取 1 不可领取
    local costIcon         = BindManager.bindCostIcon(self.AllRewardItem:getChildAutoType("costIcon"))
    local moduleId = LanternTaskModel:getModuleId()
	local cost_one = DynamicConfigData.t_CapsuleToysDraw[moduleId][1].costItem
    costIcon:setData(cost_one[1].type, cost_one[1].code, true)
    
    totalProgressBar:setMax(totalTaskData.count)
    totalProgressBar:setValue(totalTaskData.acc)
    totalPCount:setText(totalTaskData.count)
    totalPVal:setText(totalTaskData.acc)

    totalTxt_title:setText(totalTaskData.name)
    
    totalTakeCtrl:setSelectedIndex(totalTaskData.state)

    local totalReward = totalTaskData.reward[1]
    totalItemCell:setData(totalReward.code,totalReward.amount,totalReward.type)

    local img_red     = totalBtn_take:getChildAutoType("img_red")
    RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.LanternTask .. totalTaskData.id, img_red)
    totalBtn_take:removeClickListener(11)
    totalBtn_take:addClickListener(function()
        local reqInfo = {
            activityType = GameDef.ActivityType.LanternTask,
            id = totalTaskData.id,
        }
        RPCReq.Activity_GashaponTask_RecieveReward(reqInfo,function(params)

        end)
    end,11)
end

-- 设置任务列表
function LanternTaskView:setTaskList()
    local taskData = LanternTaskModel:getTaskData()
    self.list_task:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = taskData[index]
        local progressBar = obj:getChildAutoType("progressBar")
        local pVal        = progressBar:getChildAutoType("val")
        local pCount      = progressBar:getChildAutoType("count")
        local itemCell    = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
        local btn_take    = obj:getChildAutoType("btn_take")    -- 领取按钮
        local btn_travel  = obj:getChildAutoType("btn_travel")  -- 前往按钮
        local btn_haveReceive    = obj:getChildAutoType("btn_haveReceive") -- 已领取
        local txt_title   = obj:getChildAutoType("txt_title")   -- 任务标题
        local txt_desc    = obj:getChildAutoType("txt_desc")    -- 任务描述
        local takeCtrl    = obj:getController("takeCtrl")       -- 0 可领取 1 前往 2 已领取
        
        local img_red     = btn_take:getChildAutoType("img_red")
        RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.LanternTask .. data.id, img_red)

        local reward = data.reward[1]
        itemCell:setData(reward.code,reward.amount,reward.type)

        txt_title:setText(data.name)

        progressBar:setMax(data.count)
        progressBar:setValue(data.acc)
        pCount:setText(data.count)
        pVal:setText(data.acc)

        takeCtrl:setSelectedIndex(data.state)

        btn_travel:removeClickListener(11)
        btn_travel:addClickListener(function()
            if self.isEnd then
				RollTips.show(Desc.CollectThing_end)
				return
            end
            -- if data.windowId == ModuleId.EquipUpStar.id then
            --     ViewManager.close("ActivityFrame4View")
            -- end
            ModuleUtil.openModule(data.moduleOpen, true)
        end,11)

        btn_take:removeClickListener(11)
        btn_take:addClickListener(function()
            local reqInfo = {
                activityType = GameDef.ActivityType.LanternTask,
                id = data.id,
            }
            RPCReq.Activity_LanternTask_RecieveReward(reqInfo,function(params)

            end)
        end,11)
    end)
    self.list_task:setData(taskData)
end

-- 倒计时
function LanternTaskView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternTask)
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end

    if status == 2 and addtime == -1 then
        self.isEnd = false
        self.txt_countTimer:setText(Desc.activity_txt5)
    else
        local lastTime = math.floor(addtime / 1000)
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

function LanternTaskView:_exit()
    -- Scheduler.scheduleNextFrame(function() 
    --     ModelManager.EquipTargetModel.jump = false
    -- end)
	TimeLib.clearCountDown(self.timer)
end

return LanternTaskView