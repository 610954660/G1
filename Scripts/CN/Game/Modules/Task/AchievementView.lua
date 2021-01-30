--added by xhd
--日常主线
local AchievementView,Super = class("AchievementView", Window)
--local ItemCell = require "Game.UI.Global.ItemCell"
local category = GameDef.TaskCategory.Achieve
local TaskConfiger = require "Game.ConfigReaders.TaskConfiger"
local lastInterTime = 0.1
local maxInterTime = 0.5
function AchievementView:ctor()
	self._packName = "Task"
	self._compName = "AchievementView"
	-- self._isFullScreen = false
	self.targetList = false
	self.taskData = false
	self.groupId=0
	self.unfiniedList={}
	self.scheduler = {}
	self.needEffect = true
end

function AchievementView:_refresh(  )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	self.targetList:setData(self.taskData)
end


function AchievementView:_initUI( )
	self.targetList = self.view:getChildAutoType("targetList")
	self.pageList=self.view:getChildAutoType("pageList")
	self.pageList:setSelectedIndex(0)
	self.pageList:regUnscrollItemClick(function (i)
			self.groupId=i	
			for k,v in pairs(self.scheduler) do
				if self.scheduler[k] then
					Scheduler.unschedule(self.scheduler[k])
					self.scheduler[k] = false
				end
			end
			--TaskModel:setAniFlagIndex( 4,false)	
			self:task_update()
	end)
	
	for i=1,4 do
		RedManager.register("V_TASK_Achievement_"..(i-1), self.pageList:getChildAt(i-1):getChildAutoType("img_red"));	
	end
end

function AchievementView:_initEvent( )
	self.taskData = ModelManager.TaskModel:getAllShowTask(category,self.groupId)
	self.targetList:addEventListener(FUIEventType.Scroll,function ( ... )
		--TaskModel:setAniFlagIndex(4,true)
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
			local yidacheng=obj:getChildAutoType("yidacheng")
			local time=obj:getChildAutoType("time")
			local taskTip=obj:getChildAutoType("taskTip")


			local rewardData = config.reward
			title:setText(config.name)
			taskTip:setText(config.icon)
			local acc = ModelManager.TaskModel:getACCValue(category,config.recordId,config.seq)
			local taskOdm= TaskModel:getTaksOdm(category,config.recordId,config.seq)
			
			
			local curMax = config.count
			progressBar:setMax(curMax)
			progressBar:setValue(acc)
			proVal:setText(acc)
			proCount:setText(curMax)
			local status = ModelManager.TaskModel:getRewardStatus(category,config.recordId,config.seq)
			if status==0 then --未完成
				if self.groupId==0 then
					local unCount=self.unfiniedList[config.taskGroup] or 0
					unCount=unCount+1
					self.unfiniedList[config.taskGroup]=unCount
				end
		
				targetBtn:setVisible(true)
				lingquBtn:setVisible(false)
				yidacheng:setVisible(false)
				time:setVisible(false)
			elseif status ==1 then--已完成未领取
				targetBtn:setVisible(false)
				lingquBtn:setVisible(true)
				yidacheng:setVisible(false)
				time:setVisible(false)
			elseif status ==2 then
				targetBtn:setVisible(false)
				lingquBtn:setVisible(false)
				--yidacheng:setGrayed(true)
				yidacheng:setVisible(true)
				time:setVisible(true)
				if taskOdm.finDt then
					time:setText(TimeLib.getNormalDay(taskOdm.finDt))	
				else
					time:setText("")
				end
			end
			if status == 1 then
				lingquBtn:getChildAutoType("img_red"):setVisible(true)
			else
				lingquBtn:getChildAutoType("img_red"):setVisible(false)
			end

			targetBtn:removeClickListener(11)
			targetBtn:addClickListener(function( ... )
					local windowId=config.windowId[1]
					local page=config.windowId[2]
					if page then
						ModuleUtil.openModule(windowId, true,{page=page})
					else
						ModuleUtil.openModule(windowId, true)
					end
					ViewManager.close("TaskWindow")
				end,11)
			lingquBtn:removeClickListener(12)
			lingquBtn:addClickListener(function( ... )
					print(1,"领取奖励",config.id)
					local params = {}
					params.id = config.id
					params.category = GameDef.TaskCategory.Achieve
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

			local interTime = 0.15
			if self.needEffect then
				obj:setVisible(false)
				local tempIndex = index+1-self.targetList:getFirstChildInView()
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
	self.needEffect = false
	

	local allTaskCount=0
	local allFireCount=0
	local taskconfig = TaskConfiger.getAllAchieveConfig()
	for group, unCount in pairs(self.unfiniedList) do
        local groupCount = table.getn(taskconfig[group])
		local fireCount=groupCount-unCount
		self.pageList:getChildAt(group):getChildAutoType("percent"):setText(math.floor(fireCount/groupCount*100).."%")
	    allTaskCount=allTaskCount+groupCount
		allFireCount=allFireCount+fireCount
	end
    self.pageList:getChildAt(0):getChildAutoType("percent"):setText(math.floor(allFireCount/allTaskCount*100).."%")
	printTable(5656,self.unfiniedList)
end

--任务记录更新
function AchievementView:task_update( _,gamePlayType, recordId, seq )
	self.taskData = ModelManager.TaskModel:getAllShowTask(category,self.groupId)
	self.targetList:setData(self.taskData)
end

function AchievementView:player_updateRoleInfo( ... )
	self:task_update()
end

--页面退出时执行
function AchievementView:_exit( ... )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	print(1,"AchievementView _exit")
end


return AchievementView