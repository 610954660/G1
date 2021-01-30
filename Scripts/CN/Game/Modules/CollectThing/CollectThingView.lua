-- added by wyz
-- 集物活动
-- 2020.0721

local CollectThingView = class("CollectThingView",Window)

function CollectThingView:ctor()

	self._packName = "CollectThing"
	self._compName = "CollectThingView"

	self.list_task	 	 = false 	-- 任务列表
	self.txt_countTimer  = false 	-- 倒计时文本
	self.txt_countTitle  = false 	
	self.txt_bannerDec 	 = false 	-- 插图文字说明
	self.list_exchange 	 = false 	-- 珍惜兑换奖励列表
	self.btn_goExchange  = false 	-- 前往兑换按钮 （跳转到活动商店）
	self.btn_takeEarn 	 = false 	-- 领取收益按钮 （打开挂机奖励界面）
	self.showConfig 	 = {}
	self.timer 			 = false
	self.actId 			 = false
	self.showConfig 	 = false 	-- 显示的条目
	self.isEnd 			 = false 	-- 判断活动有没有结束


end

function CollectThingView:_initUI()
	self.list_task		= self.view:getChildAutoType("list_task")
	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.txt_bannerDec 	= self.view:getChildAutoType("txt_bannerDec")
	self.list_exchange 	= self.view:getChildAutoType("list_exchange")
	self.btn_goExchange = self.view:getChildAutoType("btn_goExchange")
	self.btn_takeEarn 	= self.view:getChildAutoType("btn_takeEarn")
	self.txt_countTitle = self.view:getChildAutoType("txt_countTitle")
end

function CollectThingView:_initEvent()
    self:upCanvas()
end


function CollectThingView:upCanvas()
	self.txt_bannerDec:setText(Desc.CollectThing_bannalDec)
	self.actId = ModelManager.CollectThingModel:getCollectThingId()
	self.btn_takeEarn:removeClickListener(888)
	self.btn_takeEarn:addClickListener(function()
		ViewManager.open("PushMapOnhookRewardView")
		-- ViewManager.close("ActivityFrameView")
	end,888)

	self.btn_goExchange:removeClickListener(888)
	self.btn_goExchange:addClickListener(function()
		ModuleUtil.openModule( ModuleId.Shop.id , true,{shopType = 401} )
		ViewManager.close("ActivityFrameView")
	end,888)

	-- do return end
	-- 展示列表
	local showRewad = DynamicConfigData.t_CollectThingsShow[1].reward
	self.list_exchange:setItemRenderer(function(idx,obj)
		local data = showRewad[idx+1]
		local item = BindManager.bindItemCell(obj)
		if data.amount == 1 then
			item:setAmountVisible(false)
		end
		item:setData(data.code, data.amount, data.type)
		
	end)

	self.list_exchange:setNumItems(#showRewad)

	-- 任务列表
	self.showConfig = CollectThingModel:getAllShowTask()
	-- printTable(999,"self.showConfig",self.showConfig)
	self.list_task:setItemRenderer(function(idx,obj)
		local txt_taskType 	= obj:getChildAutoType("txt_taskType") 	-- 任务类型 每日/持久
		local txt_taskDec 	= obj:getChildAutoType("txt_taskDec") 	-- 任务说明 
		
		local progressBar 	= obj:getChildAutoType("progressBar")	-- 进度条
		-- local proVal 		= progressBar:getChildAutoType("val")
		-- local proCount 		= progressBar:getChildAutoType("count")
		-- local proline 		= progressBar:getChildAutoType("n9")
		local protitle 		= progressBar:getChildAutoType("title")

		local btn_take 		= obj:getChildAutoType("btn_take") 		-- 领取按钮
		local btn_travel 	= obj:getChildAutoType("btn_travel") 	-- 前往按钮
		local ctrl 			= obj:getController("c1") 	-- 0 前往，1 可领取， 2已领取
		local index 		= idx + 1
		local taskData  	= self.showConfig[index]
		local accNum 		= taskData.acc and taskData.acc or 0
		local hasNum 		= taskData.count
		local status 		= taskData.got 	-- 领取状态


		progressBar:setMax(taskData.count)
		progressBar:setValue(accNum)
		-- proVal:setText(accNum)
		-- proVal:setColor({r=255,g=255,b=255})
        -- proCount:setText(taskData.count)
        -- proCount:setColor({r=255,g=255,b=255})
        -- proline:setColor({r=255,g=255,b=255})
		protitle:setText(accNum.."/" ..taskData.count)

        local isHook = false
		if accNum >= hasNum  then
			if (not status) then
				ctrl:setSelectedIndex(1)
			else
				isHook = true
				ctrl:setSelectedIndex(2)
			end
		else
			ctrl:setSelectedIndex(0)
		end

		txt_taskDec:setText(taskData.name)
		txt_taskType:setText(taskData.taskTitle)


		-- 奖励列表
		local list_taskReward = obj:getChildAutoType("list_taskReward") 
		list_taskReward:setItemRenderer(function(idx2,obj2)
			local data = taskData.reward[idx2+1]
			local item = BindManager.bindItemCell(obj2)
			item:setData(data.code,data.amount,data.type)
			item:setIsHook(isHook)
		end)
		list_taskReward:setData(taskData.reward)

		-- 领取按钮
		local btn_takeRed = btn_take:getChildAutoType("img_red")
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.CollectThings.."_".. index, btn_takeRed)
		btn_take:removeEventListener(222)
		btn_take:addClickListener(function()
			local info = {
				type = taskData.type,
				index = taskData.id,
			}
			RPCReq.Activity_CollectThings_RecieveReward(info,function(param)
				-- LuaLogE("********* 领取集星奖励 ************")
				-- printTable(999,"调用Activity_CollectThings_RecieveReward",param)
				Dispatcher.dispatchEvent(EventType.CollectThingView_upData)
			end)
		end,222)


		-- 前往按钮
		btn_travel:removeClickListener(333)
		btn_travel:addClickListener(function()
			if self.isEnd then
				RollTips.show(Desc.CollectThing_end)
				return
			end
			ModuleUtil.openModule(taskData.jump, true)
			ViewManager.close("CollectThingView")
		end,333)

	end)

	self.list_task:setData(self.showConfig)
	self:countTime()
end

function CollectThingView:CollectThingView_upData()
	printTable(999,"调用 CollectThingView:CollectThingView_upData ")
	self:upCanvas()
end


-- 倒计时
function CollectThingView:countTime()
	if self.isEnd then return end
	local status,lastTime = ModelManager.ActivityModel:getActStatusAndLastTime(self.actId)
    lastTime = lastTime/1000
	if lastTime ~= -1 then
		if lastTime >0 then
	    	self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime,2))
		    local function onCountDown( time )
		    	self.isEnd = false
		    	self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time,2))
		    end
		    local function onEnd( ... )
		    	self.isEnd = true
		    	self.txt_countTimer:setText(Desc.CollectThing_end)
		    	self:upCanvas()
		    end
		    if self.timer then
		    	TimeLib.clearCountDown(self.timer)
		    end
		    self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false,false)
	    else
	    	self.isEnd = true
	    	self.txt_countTimer:setText(Desc.CollectThing_end)
	    end
	end
end

function CollectThingView:_exit()
	TimeLib.clearCountDown(self.timer)
end

return CollectThingView