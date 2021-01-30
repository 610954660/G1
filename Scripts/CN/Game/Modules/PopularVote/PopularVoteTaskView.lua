--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 

local PopularVoteTaskView,Super = class("PopularVoteTaskView", Window)

function PopularVoteTaskView:ctor()
	--LuaLog("PopularVoteTaskView ctor")
	self._packName = "PopularVote"
	self._compName = "PopularVoteTaskView"
	self.taskListData = {}
	self.timer          = false     -- 活动定时器
    self.isEnd          = false 
	--self._rootDepth = LayerDepth.Window
	
end

function PopularVoteTaskView:_initEvent( )
	
end

function PopularVoteTaskView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:PopularVote.PopularVoteTaskView
	self.lihuiDisplay = viewNode:getChildAutoType('lihuiDisplay')--GButton
	self.taskList = viewNode:getChildAutoType('taskList')--GList
	self.txt_leftTime = viewNode:getChildAutoType('txt_leftTime')--GTextField
	--{autoFieldsEnd}:PopularVote.PopularVoteTaskView
	--Do not modify above code-------------
end

function PopularVoteTaskView:_initUI( )
	self:_initVM()
	self.lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
	self.lihuiDisplay:setData(15003)
	self.lihuiDisplay:setScale(0.5,0.5)
	self:initTaskListData()
	self:setTaskList()
	self:updateCountTimer()
end

function PopularVoteTaskView:initTaskListData()
	self.taskListData = {}
	local info = DynamicConfigData.t_HeroVoteTask[ModelManager.PopularVoteModel.moduleId] 
	for _,v in pairs(info) do
		local taskState = ModelManager.PopularVoteModel.taskState[v.id] or {}
		local index = 2
		if taskState.got then 
			index = 3
		elseif taskState.finish then 
			index = 1
		end
		table.insert(self.taskListData,{data = v, state = index, id = v.id})
	end
	table.sort( self.taskListData, function (a,b)
		if a.state == b.state then 
			return a.id < b.id
		end
		return a.state < b.state
	end )
end

function PopularVoteTaskView:setTaskList( )
	self.taskList:setItemRenderer(function (idx,obj)
		local index = idx + 1
        local data = self.taskListData[index].data	
        local btnStateCtr = obj:getController("btnStateCtr")
        local itemCell = obj:getChildAutoType("itemCell")
        itemCell = BindManager.bindItemCell(itemCell)
        local reward = data.reward[1]
        itemCell:setData(reward.code, reward.amount, reward.type)
        local txt_title = obj:getChildAutoType("txt_title")
        txt_title:setText(data.name)
		local progressBar = obj:getChildAutoType("progressBar")
		local progressBar = obj:getChildAutoType("progressBar")
		local proVal = progressBar:getChildAutoType("val")
		local proCount = progressBar:getChildAutoType("count")
    	local taskState = ModelManager.PopularVoteModel.taskState[data.id] or {}
    	local num = taskState.acc or 0
    	if data.recordType == 101 then --每日登录进度写死1，因为服务器没有acc
    		num = 1
    	end
		progressBar:setMax(data.count)
		progressBar:setValue(num)
		proVal:setText(num)
        proCount:setText(data.count)
        local btn_go = obj:getChildAutoType("btn_go")
        btn_go:removeClickListener(6)
        btn_go:addClickListener(
        	function()
        		ModuleUtil.openModule( data.moduleOpen , true )
				ViewManager.close("PopularVoteTaskView")
    	end,6)
        local btn_get = obj:getChildAutoType("btn_get")
        btn_get:removeClickListener(6)
        btn_get:addClickListener(
        	function()
        		local params = {
		            activityType = GameDef.ActivityType.HeroVoteTask,
		            id = data.id,
		        }
		        printTable(6,"params",params)
        		RPCReq.Activity_GashaponTask_RecieveReward(params)
    	end,6)
    	--按钮状态
    	if taskState.got then 
      	 	btnStateCtr:setSelectedIndex(2)
    	elseif not taskState.got and taskState.finish then 
      	 	btnStateCtr:setSelectedIndex(1)
    	else
      	 	btnStateCtr:setSelectedIndex(0)
    	end
	end)
	self.taskList:setData(self.taskListData)
end

function PopularVoteTaskView:PopularVoteTask_updateData()
	self:initTaskListData()
	self.taskList:setNumItems(#self.taskListData)
end

-- 倒计时
function PopularVoteTaskView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroVoteTask)
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end

    if status == 2 and addtime == -1 then
        self.isEnd = false
        self.txt_leftTime:setText(Desc.activity_txt5)
    else
        local lastTime = addtime / 1000
        if lastTime == -1 then
            self.txt_leftTime:setText(Desc.activity_txt5)
        else
            if not tolua.isnull(self.txt_leftTime) then
                self.txt_leftTime:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            end
            local function onCountDown(time)
                if not tolua.isnull(self.txt_leftTime) then
                    self.isEnd = false
                    self.txt_leftTime:setText(TimeLib.GetTimeFormatDay(time, 2))
                end
            end
            local function onEnd(...)
                self.isEnd = true
                if not tolua.isnull(self.txt_leftTime) then
                --  self.activityEnable = true
                self.txt_leftTime:setText(Desc.activity_txt18)
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function PopularVoteTaskView:_exit()
    TimeLib.clearCountDown(self.timer)
end


return PopularVoteTaskView