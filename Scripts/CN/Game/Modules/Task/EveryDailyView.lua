--added by xhd 
--日常任务
local EveryDailyView,Super = class("EveryDailyView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local category = GameDef.TaskCategory.Daily
local gamePlayType = GameDef.GamePlayType.TaskDaily
local TaskConfiger = require "Game.ConfigReaders.TaskConfiger"

local lastInterTime = 0.1
local maxInterTime = 0.5

function EveryDailyView:ctor()
	self._packName = "Task"
	self._compName = "EveryDailyView"
	self._isFullScreen = false
	self.countLabel = false
	self.progressBar = false
	for i=1,5 do
    	self["getImage"..i] = false
    end
    for i=1,5 do
    	self["needactVal"..i] = false
    	self["actBtnitem"..i] = false
    	self["actBtnitemNum"..i] = false
    	self["spine"..i] = false
	end
	
    self.targetList = false
    self.taskData 	= false
    self.awardView 	= false
    self.awardCloseBtn 	= false
    self.awardShowCtrl 	= false
    self.awardCtrl 		= false
    self.awardShowFlag 	= false
	self.awardViewList 	= false
	self.scheduler 		= {}
	self.needEffect 	= true
end

function EveryDailyView:_refresh(  )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	self.targetList:setData(self.taskData)
end

function EveryDailyView:_initUI( )

	self.awardView = self.view:getChildAutoType("awardView")
    self.awardShowCtrl = self.view:getController("awardShowCtrl")
    self.awardCloseBtn = self.awardView:getChildAutoType("viewCloseBtn")
    self.awardCtrl = self.awardView:getController("c1")
    self.awardViewList = self.awardView:getChildAutoType("list")
    self.awardViewBg = self.awardView:getChildAutoType("n0")

    self.actiVal = self.view:getChildAutoType("actiVal")
    local scoreConfig = TaskConfiger.getActiveScoreConfig(gamePlayType)
    for i=1,5 do
    	self["needactVal"..i] =  self.view:getChildAutoType("needactVal"..i)
    	if self["needactVal"..i] then
    		self["needactVal"..i]:setText(scoreConfig[i].score)
    	end
    end

    self.progressBar = self.view:getChildAutoType("progressBar")
    for i=1,5 do
    	self["getImage"..i] = self.view:getChildAutoType("getImage"..i)
    	self["actBtn"..i] = self.view:getChildAutoType("n1"..i)
    	self["actBtnitem"..i] = self["actBtn"..i]:getChildAutoType("itemCell")
    	self["actBtnitemNum"..i] = self["actBtn"..i]:getChildAutoType("itemnum")
    	local spineNode =self["actBtn"..i]:getChildAutoType("spineNode") 
    	self["spine"..i] = SpineUtil.createSpineObj(spineNode, vertex2(0,0), "baoxiang_meizhou", "Effect/UI", "Ef_yuanzheng_baoxiang", "Ef_yuanzheng_baoxiang",true)
    end
    self.targetList = self.view:getChildAutoType("targetList")
end

function EveryDailyView:_initEvent( )
	self.taskData = ModelManager.TaskModel:getAllShowTask(category)
	local score,records = ModelManager.TaskModel:getActiValByType(gamePlayType)
	self.progressBar:setValue(score)

	self.targetList:addEventListener(FUIEventType.Scroll,function ( ... )
		--TaskModel:setAniFlagIndex(1,true)
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
			local targetBtn = obj:getChildAutoType("targetBtn") --前往
			local flagImg = obj:getChildAutoType("flagImg") --已完成
			local actiVal = obj:getChildAutoType("actiVal") --可以获取的活跃值
			local lingquBtn = obj:getChildAutoType("lingquBtn")
			local showCtrl = obj:getController("showCtrl")
			local title3 = obj:getChildAutoType("title3")
			local pLevel = ModelManager.PlayerModel.level
			local levelEnough = false
			if pLevel >=config.lv then
				showCtrl:setSelectedIndex(0)
				levelEnough = true
			else
				showCtrl:setSelectedIndex(1)
			end
			title3:setText(config.lv)
			title:setText(config.name)
--			actiVal:setText(config.activeScore)

			local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
			local itemData = ItemsUtil.createItemData({data = {type = 2,code = 10006001,amount = config.activeScore}})
			itemcell:setItemData(itemData)


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
				flagImg:setVisible(false)
			elseif status ==1 then--已完成未领取
				targetBtn:setVisible(false)
				lingquBtn:setVisible(true)
				flagImg:setVisible(false)
			elseif status ==2 then
				targetBtn:setVisible(false)
				lingquBtn:setVisible(false)
				flagImg:setVisible(true)
			end
			if status == 1 then
	            lingquBtn:getChildAutoType("img_red"):setVisible(true)
			else
				lingquBtn:getChildAutoType("img_red"):setVisible(false)
			end
			if not levelEnough then
				targetBtn:setVisible(false)
				lingquBtn:setVisible(false)
				flagImg:setVisible(false)
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
		 		params.category = category
		 		params.onSuccess = function (res )
					if tolua.isnull(obj) then return end
					 obj:getTransition("t1"):play(function( ... )
					 	 print(1,"动画完成")
					 	 obj:setScale(1,1)
					 	 self:dailyTask_update()
					  end);
		 		end
		 		RPCReq.Task_GetReward(params, params.onSuccess)
			end,12)

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
	self.needEffect = false
	self.actiVal:setText(score)

    --奖励控制器
	self.awardCloseBtn:addClickListener(function ( ... )
		if self.awardShowFlag then
			self.awardShowCtrl:setSelectedIndex(0)
			self.awardShowFlag = false
		else
			self.awardShowFlag = true
			self.awardShowCtrl:setSelectedIndex(1)
		end		
	end)

	self.awardViewList:setItemRenderer(function ( index,obj )
		local award = self.awardViewList._dataTemplate[index+1]
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = award})
		itemcell:setItemData(itemData)
	end)

	-- 日任务奖励插入特定活动的奖励
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.TaskAddRewards)
	local showContent = {}
	local extraRewards = {}
	if actData then
		showContent = actData.showContent or {}
		extraRewards = showContent.extraRewards or {}
	end

	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.TaskAddRewardsCopy)
	local showContent = {}
	local extraRewards2 = {}
	if actData then
		showContent = actData.showContent or {}
		extraRewards2 = showContent.extraRewards or {}
	end

	for i=1,5 do
		local actRewardCfg = extraRewards[i]
		local actRewardData = {}
		if actRewardCfg then
			actRewardData = actRewardCfg.reward
		end

		local actRewardCfg2 = extraRewards2[i]
		if actRewardCfg2 then
			for i = 1, #actRewardCfg2.reward do
				actRewardData[#actRewardData+i] = actRewardCfg2.reward[i]
			end
		end

		local config = TaskConfiger.getActiConfig( gamePlayType,i )
		local itemcell = BindManager.bindItemCell(self["actBtnitem"..i])
		local reward = config.rewardList[1]
		itemcell:setAmountVisible(false)
		itemcell:setClickable(false)
		itemcell:setData(reward.code,reward.amount,reward.type)
		self["actBtnitemNum"..i]:setText(MathUtil.toSectionStr(config.rewardList[1].amount))
		self["actBtn"..i]:removeClickListener(100)
    	self["actBtn"..i]:addClickListener(function( ... ) 
    		                print(1,"点击按钮",i)
    		                local score,records = ModelManager.TaskModel:getActiValByType(gamePlayType)
    		                local tempFlag = false
							for k,v in pairs(records) do
					        	if config.id == v.id then --存在
					        		tempFlag = true
					        		break
					        	end
					        end
					        if not  tempFlag and score>= config.score then --没灵活 并且分数到了
					        	self:reqGetActiAward(gamePlayType,config.id)
							else
								local OpenDay= ServerTimeModel:getOpenDay()+1
								printTable(150,"222222222222",OpenDay)
								local serverOpenDayList={}
								for openDay = 1, #config.rewardList, 1 do
									local openDayitem=config.rewardList[openDay]
									if OpenDay>=openDayitem.openServerDay then
										table.insert( serverOpenDayList,openDayitem )
									end 
								end
								for k,v in pairs(actRewardData) do
									table.insert( serverOpenDayList,v )
								end

					        	if self.awardShowFlag then
					        		self.awardShowFlag = false
									self.awardShowCtrl:setSelectedIndex(0)
								else
									self.awardShowFlag = true
									self.awardShowCtrl:setSelectedIndex(1)
									-- self.awardCtrl:setSelectedIndex(i-1)
									self.awardViewList:setData(serverOpenDayList)
									local posx = self["actBtn"..i]:getX()
									if i>=1 and i<=4 then
									   self.awardViewList:setPivot(0.5,0.5,true)
									   self.awardViewBg:setPivot(0.5,0.5,true)
                                       self.awardViewList:setX(posx+10)
									   self.awardViewBg:setX(posx+10)
									elseif i ==5 then
									   self.awardViewList:setPivot(1,0.5,true)
									   self.awardViewBg:setPivot(1,0.5,true)
									   self.awardViewList:setX(posx+80)
									   self.awardViewBg:setX(posx+80)
									end
									self.awardViewList:resizeToFit(#serverOpenDayList)
								end
					        end
						  end,100)
    end
   self:update_Score()
end

function EveryDailyView:update_Score( ... )
	local score,records = ModelManager.TaskModel:getActiValByType(gamePlayType)
	self.progressBar:setValue(score)
	if self.actiVal then
    	self.actiVal:setText(score)
    end
    for i=1,5 do
    	local flag = false
    	local config = TaskConfiger.getActiConfig( gamePlayType,i )
		self["actBtn"..i]:getController("curShow"):setSelectedIndex(0)
		self["actBtn"..i]:getController("hadGetCtrl"):setSelectedIndex(0)
        for k,v in pairs(records) do
        	if config.id == v.id then --存在
        		self["actBtn"..i]:getController("hadGetCtrl"):setSelectedIndex(1)
        		flag = true
        		break
        	else
        		self["actBtn"..i]:getController("hadGetCtrl"):setSelectedIndex(0)
        		
        	end
        end
        if not  flag and score>= config.score then
        	self["actBtn"..i]:getController("curShow"):setSelectedIndex(1)
        end
    end
end



function EveryDailyView:reqGetActiAward( type,id)
	print(1,type,id)
    local params = {}
	params.id = id
	params.type = type
	params.onSuccess = function (res )
	end
	RPCReq.ActiveScore_GetReward(params, params.onSuccess)
	
end

function EveryDailyView:task_update( _,gamePlayType, recordId, seq )
	-- print(1,"协议刷新了")
	self.taskData = ModelManager.TaskModel:getAllShowTask(category)
	self.targetList:setData(self.taskData)
end

--任务列表刷新
function EveryDailyView:dailyTask_update( ... )
	self:task_update()
end

--活跃值刷新
function EveryDailyView:dailyScore_update( ... )
	self:update_Score()

end

--页面退出时执行
function EveryDailyView:_exit( ... )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	print(1,"EveryDailyView _exit")
end


return EveryDailyView