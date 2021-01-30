--added by xhd 
--日常主线
local DailyTaskView,Super = class("DailyTaskView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local category = GameDef.TaskCategory.Main
local lastInterTime = 0.1
local maxInterTime = 0.5

function DailyTaskView:ctor()
	self._packName = "Task"
	self._compName = "DailyTaskView"
	-- self._isFullScreen = false
	self.targetList = false
	self.taskData = false
	self.scheduler = {}
	self.needEffect = true
end

function DailyTaskView:_initUI( )
    self.targetList = self.view:getChildAutoType("targetList")
    for i=1,5 do
    	self["getImage"..i] = self.view:getChildAutoType("getImage"..i)
    end
end

function DailyTaskView:_refresh(  )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	self.targetList:setData(self.taskData)
end

function DailyTaskView:_initEvent( )
	self.taskData = ModelManager.TaskModel:getAllShowTask(category)
	self.targetList:addEventListener(FUIEventType.Scroll,function ( ... )
		--TaskModel:setAniFlagIndex( 3,true)
		self.needEffect = false
	end)
	self.targetList:setItemRenderer(function(index,obj)
			local icon = obj:getChildAutoType("icon")
			-- self.icon:setURL()
			local config = self.taskData[index+1]

			local title = obj:getChildAutoType("title")
			local progressBar = obj:getChildAutoType("progressBar")
			local proVal = progressBar:getChildAutoType("val")
			local proCount = progressBar:getChildAutoType("count")
			local rewardList = obj:getChildAutoType("rewardList")
			local targetBtn = obj:getChildAutoType("targetBtn") --前往
			local lingquBtn = obj:getChildAutoType("lingquBtn")
			
			local rewardData = config.reward
			title:setText(config.name)
			local acc = ModelManager.TaskModel:getACCValue(category,config.recordId,config.seq)
			local curMax = config.count
			progressBar:setMax(curMax)
			progressBar:setValue(acc)
			proVal:setText(acc)
            proCount:setText(curMax)
			local status = ModelManager.TaskModel:getRewardStatus(category,config.recordId,config.seq)
			if status==0 then --未完成
				targetBtn:setVisible(true)
				lingquBtn:setVisible(false)
			elseif status ==1 then--已完成未领取
				targetBtn:setVisible(false)
				lingquBtn:setVisible(true)
			elseif status ==2 then
				targetBtn:setVisible(false)
				lingquBtn:setVisible(false)
			end
			if status == 1 then
	            lingquBtn:getChildAutoType("img_red"):setVisible(true)
			else
				lingquBtn:getChildAutoType("img_red"):setVisible(false)
			end
		
            targetBtn:removeClickListener(11)
			targetBtn:addClickListener(function( ... )
				 ModuleUtil.openModule( config.windowId , true )
				 ViewManager.close("TaskWindow")
			end,11)
			lingquBtn:removeClickListener(12)
			lingquBtn:addClickListener(function( ... )
				print(1,"领取奖励",config.id)
				local params = {}
		 		params.id = config.id
		 		params.category = GameDef.TaskCategory.Main
		 		params.onSuccess = function (res )
		 		  --  printTable(1,config)
		 		  --  if config.nextFlag and acc>=config.nextNeed then --存在下一个 并且条件满足
		 		  --  	  obj:getTransition("t0"):play(function( ... )
					 	--  print(1,"动画完成")
					 	--  self:task_update()
					  -- end);
		 		  --  else
		 		  --  	  obj:getTransition("t1"):play(function( ... )
					 	--  print(1,"动画完成")
					 	--  obj:setScale(1,1)
					 	--  self:task_update()
					  -- end);
		 		  --  end
		 		end
		 		RPCReq.Task_GetReward(params, params.onSuccess)
			end,12)
			
			--奖励显示
			rewardList:setItemRenderer(function(index,obj)
                local itemcell = BindManager.bindItemCell(obj)
                local itemData = ItemsUtil.createItemData({data = rewardData[index+1]})
				itemcell:setItemData(itemData)
				obj:addClickListener(function( ... )
					itemcell:onClickCell(index)
				end)
			end)
			rewardList:setData(rewardData)
			
			--动画
			-- local maxNum = #self.taskData<6 and #self.taskData or 6
			-- local interTime = maxInterTime/maxNum
			-- if interTime >= lastInterTime then
			-- 	interTime = lastInterTime
			-- end
			local interTime = 0.1
			if self.needEffect then
				obj:setVisible(false)
				local tempIndex = index-self.targetList:getFirstChildInView()
				self.scheduler[tempIndex] = Scheduler.scheduleOnce(tempIndex*interTime, function( ... )
					if obj and  (not tolua.isnull(obj)) then
						obj:setVisible(true)
						obj:getTransition("t0"):play(function( ... )
						end);
					end
				end)
			end

		end
	)

	self.targetList:setData(self.taskData)
	--TaskModel:setAniFlagIndex( 3,true)
	self.needEffect = false
	
end

--任务记录更新
function DailyTaskView:task_update( _,gamePlayType, recordId, seq )
	self.taskData = ModelManager.TaskModel:getAllShowTask(category)
	self.targetList:setData(self.taskData)
end

function DailyTaskView:player_updateRoleInfo( ... )
	self:task_update()
end

--页面退出时执行
function DailyTaskView:_exit( ... )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	print(1,"EmailView _exit")
end


return DailyTaskView