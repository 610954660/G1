local V, Super = class("DelegateActivityView", Window)
local DelegateActivityConfiger = require "Game.ConfigReaders.DelegateActivityConfiger"
local ActivityType = GameDef.ActivityType

local function setClickListenerFor(view, listener)
    view:removeClickListener(0)
    view:addClickListener(listener, 0)
end

function V:ctor()
    self._packName = "DelegateActivity"
    self._compName = "DelegateActivityView"
    self.txt_countDown = false;
    self.list_item = false;
    self.timer = false;
end

function V:_initUI()
	self.btn_rankReward = self.view:getChildAutoType("btn_rankReward")
	self.btn_rank = self.view:getChildAutoType("btn_rank")
	
	self.btn_rankReward:removeEventListeners()
    self.btn_rankReward:addClickListener(function( )
		local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.DelegateContend)
		if not actData then return {} end
        ViewManager.open("PublicRankRewardView", {activityType = GameDef.ActivityType.DelegateContend, moduleId = actData.showContent.moduleId, rankType = GameDef.RankType.DelegateContend})
    end)
	
	self.btn_rank:removeEventListeners()
    self.btn_rank:addClickListener(function( )
        ViewManager.open("PublicRankView", {type = GameDef.RankType.DelegateContend})
    end)
	
	
    local activityBaseInfo = ActivityModel:getActityByType(ActivityType.DelegateContend)
    local endTimeMs = 0
    if activityBaseInfo then
        --local img_banner = self.view:getChildAutoType("img_banner")
        --img_banner:setURL(string.format("UI/activity/%s", activityBaseInfo.showContent.titleBanner)) -- TODO
        endTimeMs = activityBaseInfo.realEndMs or 0
    end

    --
    self.taskListView = self.view:getChildAutoType("taskList")
    self.taskListView:setVirtual()
    self.taskListView:setItemRenderer(function(index, view)
        self:__renderTaskItem(index+1, view)
    end)

    -- 倒计时
    local countdownView = self.view:getChildAutoType("txt_countDown")
    local now = ServerTimeModel:getServerTimeMS()
    local remainingSeconds = math.floor((endTimeMs-now)/1000)
    local function updateCountdownView(time)
		if tolua.isnull(countdownView) then return end
        if time > 0 then
            local timeStr = TimeLib.GetTimeFormatDay(time,2)
            countdownView:setText(timeStr)
        else
            countdownView:setText(Desc.CollectThing_end) -- TODO
        end
    end
    updateCountdownView(remainingSeconds)
    self.__timerId = TimeLib.newCountDown(remainingSeconds, function(time)
        updateCountdownView(time)
    end, function()
        countdownView:setText(Desc.CollectThing_end) -- TODO
        self:closeView()
    end, false, false, false)

    -- 广告语
    self.view:getChildAutoType("tvSlogan"):setText(DelegateActivityConfiger:getSloganText())

    --
    self:__update()

    --
    DelegateActivityModel:todayHaveOpenedOnce(true)
    DelegateActivityModel:checkReddot()
end

function V:__renderTaskItem(index, view)
    local task = self.__taskList[index]

    --
    local c1 = view:getController("c1")
    local status = DelegateActivityModel:getTaskStatus(task.id)
    c1:setSelectedIndex(status)
    if status == 0 then -- 已完成但未领取奖励
        -- 领取按钮
        local btnGet = view:getChildAutoType("btn_get")
        btnGet:getChildAutoType("img_red"):setVisible(true)
        setClickListenerFor(btnGet, function()
            DelegateActivityModel:getTaskReward(task.id)
        end)
    elseif status == 1 then -- 未完成
        -- 前往按钮
        setClickListenerFor(view:getChildAutoType("btn_enter"), function()
            ModuleUtil.openModule(ModuleId.Delegate.id, true)
        end)
    end

    --
    printTable(8848,">>task>>",task)
    -- view:getChildAutoType("txt_desc"):setText(string.format("累计派遣探员[color=#0ea41d]%d[/color]次", task.times)) -- TODO
    view:getChildAutoType("txt_desc"):setText(task.desc)
    view:getChildAutoType("txt_num"):setText(string.format("[color=#0ea41d]%d[/color]/%d[/color]", DelegateActivityModel:getCompletedTimes(), task.times)) -- TODO

    -- 奖励展示
    local rewardListView = view:getChildAutoType("list_prop")
    rewardListView:setItemRenderer(function(index, itemCell)
        index = index +1
        local reward = task.reward[index]
        local itemCell = BindManager.bindItemCell(itemCell)
        itemCell:setData(reward.code, reward.amount, reward.type)
    end)
    rewardListView:setNumItems(#task.reward)
end

function V:__update()
	if tolua.isnull(self.view) then return end
    self.__taskList = DelegateActivityModel:getTaskList()
    self.taskListView:setNumItems(#self.__taskList)
end

function V:_initEvent( )
    -- TODO
end

function V:delegate_contend_activity_update()
    self:__update()
end


function V:_exit()
    if self.__timerId then
        TimeLib.clearCountDown(self.__timerId)
    end
end

return V