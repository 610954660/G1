
-- added by wyang
-- 扭蛋

local TwistEggView = class("TwistEggView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function TwistEggView:ctor(args)
    self._packName  = "TwistEgg"
    self._compName  = "TwistEggView"
	
	self.moduleId = TwistEggModel:getModuleId()
	if self.moduleId == 3 then
		self._packName  = "TwistEgg2"
		self._compName  = "TwistEggView2"
	end

    self.txt_CumulateTimesTitle  = false
    self.txt_CumulateTimes  = false     -- 累计召唤次数
    self.progressBar        = {}
    self.item               = {}
    self.txt_itmeNum        = {}
    self.btn_oneTime        = false     -- 抽一次
    self.btn_tenTime        = false     -- 抽十次
	self.txt_countTimer 	= false     -- 活动倒计时
    self.costItem_one       = false
    self.costItem_ten       = false 
    self.txt_haveTitle      = false
    self.itemIcon           = false
	self.costIcon 			= false
    self.txt_itemNum        = false
    self.effectLoader       = false
	self.btn_shop 			= false
	self.btn_rule 			= false
	self.btn_help1 			= false
    self.skipEffect        	= false
    self.drawRoll        	= false
    self.list_rewardShow   	= false
    self.btn_closeEffect   	= false
	
	self.costCode = 0
	self.cost_one = false
	self.cost_ten = false
	self.spineNode = false
	self.isSkip = false
	self.isDrawing = false --是否还在抽卡中
	self.canClickClose = false --要播放动画才能点关闭
	self.reward = false
	
	self.lastReward = false --关闭前如果还有奖励的话，直接弹奖励窗口
	self.isEnd = false --是否活动动已经结束 
	
	self._showParticle=true
end

function TwistEggView:_initUI()
	
	self.costCode = DynamicConfigData.t_CapsuleToysDraw[self.moduleId][1].costItem[1].code
	self.cost_one = DynamicConfigData.t_CapsuleToysDraw[self.moduleId][1].costItem
	self.cost_ten =  DynamicConfigData.t_CapsuleToysDraw[self.moduleId][2].costItem
	
	
    for i=1,3 do
        self.item[i]              = self.view:getChildAutoType("item"..i)
        self.progressBar[i]       = self.view:getChildAutoType("progressBar" ..i)     
        self.txt_itmeNum[i]       = self.view:getChildAutoType("txt_itmeNum" ..i)
    end
	
    self.txt_itemNum              = self.view:getChildAutoType("txt_itemNum")
    local itemIcon                 = self.view:getChildAutoType("itemIcon")
    local costIcon                 = self.view:getChildAutoType("costIcon")
	self.costIcon = BindManager.bindCostIcon(costIcon)
	self.itemIcon = BindManager.bindCostItem(itemIcon)
    self.txt_haveTitle            = self.view:getChildAutoType("txt_haveTitle")
    self.txt_CumulateTimesTitle   = self.view:getChildAutoType("txt_CumulateTimesTitle")
    self.txt_CumulateTimes        = self.view:getChildAutoType("txt_CumulateTimes")
    self.btn_oneTime              = self.view:getChildAutoType("btn_oneTime")
    self.btn_tenTime              = self.view:getChildAutoType("btn_tenTime")
    self.btn_shop              	  = self.view:getChildAutoType("btn_shop")
    self.effectLoader             = self.view:getChildAutoType("effectLoader")
    self.skipEffect               = self.view:getChildAutoType("skipEffect")
	self.txt_countTimer 		  = self.view:getChildAutoType("txt_countTimer")
    self.drawRoll              	  = self.view:getChildAutoType("drawRoll")
    self.btn_rule              	  = self.view:getChildAutoType("btn_rule")
    self.btn_help1             	  = self.view:getChildAutoType("btn_help1")
    self.list_rewardShow          = self.view:getChildAutoType("list_rewardShow")
    self.btn_closeEffect          = self.view:getChildAutoType("btn_closeEffect")
    local costItem_one             = self.view:getChildAutoType("costItem_one")
    local costItem_ten             = self.view:getChildAutoType("costItem_ten")
	
	self.costIcon:setData(self.cost_one[1].type, self.cost_one[1].code, false)
	self.itemIcon:setData(self.cost_one[1].type, self.cost_one[1].code, 0, false,true, true)
	self.costItem_one = BindManager.bindCostItem(costItem_one)
	self.costItem_ten = BindManager.bindCostItem(costItem_ten)
	self.costItem_one:setData(self.cost_one[1].type, self.cost_one[1].code, self.cost_one[1].amount)
	self.costItem_ten:setData(self.cost_ten[1].type, self.cost_ten[1].code, self.cost_ten[1].amount)
	
	if self.list_rewardShow then
		local showData = DynamicConfigData.t_CapsuleShow[self.moduleId].item
		self.list_rewardShow:setItemRenderer(
				function(index, obj) 
					local itemcell = BindManager.bindItemCell(obj)
					local data = showData[index + 1]
					itemcell:setData(data.code, data.amount, data.type)
				end
			)		
		self.list_rewardShow:setData(showData)
	end
	
	self.btn_closeEffect:setVisible(false)
	
	
	self:TwistEggView_refreshPanel()
end

function TwistEggView:_initEvent()
    self.txt_CumulateTimesTitle:setText(Desc.TwistEgg_cumulateTimesTitle)
    --self.txt_haveTitle:setText(Desc.ElvesSystem_summonProHaveTitle)
	
	local img_redOne = self.btn_oneTime:getChildAutoType("img_red")
    RedManager.register("V_TWIST_DRAW".."_ONE", img_redOne)
	
	local img_redTen = self.btn_tenTime:getChildAutoType("img_red")
    RedManager.register("V_TWIST_DRAW".."_TEN", img_redTen)
	
	local skip = FileCacheManager.getStringForKey(PlayerModel.userid.."TwistEggView_skip","0",nil,true)
	self.isSkip = skip == "1"
	self.skipEffect:setSelected(self.isSkip)
	--self.skipEffect:getController("button"):setSelectedIndex(self.isSkip and 1 or 0)
	self.skipEffect:removeClickListener(888)
    self.skipEffect:addClickListener(function()
		self.isSkip = self.skipEffect:getController("button"):getSelectedIndex() == 1
		FileCacheManager.setStringForKey(PlayerModel.userid.."TwistEggView_skip", self.isSkip and "1" or "0",nil,true)
	end)
	self.btn_shop:removeClickListener(888)
    self.btn_shop:addClickListener(function()
		ModuleUtil.openModule(ModuleId.TwistEggShop.id)
    end,888)
	
	--self.btn_help:removeClickListener(888)
    self.btn_rule:addClickListener(function()
		RollTips.showHelp(Desc.help_CapsuleToysTitle, Desc.help_CapsuleToys)
    end,888)

	self.btn_closeEffect:addClickListener(function()
		if not self.canClickClose then return end
		self.btn_closeEffect:setVisible(false)
		self.view:getTransition("t0"):stop()
		if self.effectLoader then self.effectLoader:displayObject():removeAllChildren() end		
		self.lastReward  = false
		self.isDrawing = false
		ViewManager.open("AwardShowView",{reward = self.reward})
    end,888)
	
	self.btn_help1:addClickListener(function()
		--RollTips.showHelp(Desc.help_CapsuleToysTitle, DynamicConfigData.t_CapsulePR[self.moduleId].desc)
		
		local config = DynamicConfigData.t_CapsulePR[self.moduleId]
		RollTips.showRateTips(config)
    end,888)

	self.btn_oneTime:removeClickListener(888)
    self.btn_oneTime:addClickListener(function()
		if PlayerModel:isCostEnough(self.cost_one,true) then
			local reqInfo = {
				activityId    = GameDef.ActivityType.Gashapon,
				drawType     = 1,
			}
			if self.isDrawing then return end
			if self.isEnd then RollTips.show(Desc.TwistEggTask_ended) end
			self.isDrawing = true
			RPCReq.Activity_Gashapon_Draw(reqInfo,function(data)
				printTable(8848,">>>>>召唤一次的数据>>>>",data)
				self.lastReward  = data.addRes or false
				self:playEffect(1,data.addRes)
				
			end, function(errorMsg)
					RollTips.showError(errorMsg)
					self.isDrawing = false
				end)
		end
    end,888)
	
	self.btn_tenTime:removeClickListener(888)
    self.btn_tenTime:addClickListener(function()
		if PlayerModel:isCostEnough(self.cost_ten,true) then
			local reqInfo = {
				activityId    = GameDef.ActivityType.Gashapon,
				drawType     = 2,
			}
			if self.isDrawing then return end
			if self.isEnd then RollTips.show(Desc.TwistEggTask_ended) end
			self.isDrawing = true
			RPCReq.Activity_Gashapon_Draw(reqInfo,function(data)
				printTable(8848,">>>>>召唤十次的数据>>>>",data)
				self.lastReward  = data.addRes or false
				self:playEffect(10, data.addRes)
			end, function(errorMsg)
					RollTips.showError(errorMsg)
					self.isDrawing = false
				end)
		end
    end,888)
end


function TwistEggView:playEffect(type, reward)
	self.reward = reward
	self.canClickClose = false
	if self.isSkip then
		ViewManager.open("AwardShowView",{reward = reward})
		self.lastReward  = false
		self.isDrawing = false
	else
		self.btn_closeEffect:setVisible(true)
		self.view:getTransition("t0"):play(function( ... )
				self.spineNode = SpineMnange.createSpineByName("Spine/ui/niudan/fx_niudan")
				self.effectLoader:displayObject():addChild(self.spineNode)
				self.spineNode:setAnimation(0, "fx_niudan_up", false);
				self.canClickClose = true
				self.spineNode:setCompleteListener(function(name)
					Scheduler.scheduleNextFrame(function()
							if not tolua.isnull(self.effectLoader) then
								self.btn_closeEffect:setVisible(false)
								self.effectLoader:displayObject():removeAllChildren()
							end
						end)
					
					ViewManager.open("AwardShowView",{reward = reward})
					self.lastReward = false
					self.isDrawing = false
				end)
		end);
	end
	
end

function TwistEggView:TwistEggView_refreshPanel(_,params)
    local maxHistoryTimes = ModelManager.TwistEggModel.drawCount

    local rewardData    = DynamicConfigData.t_CapsuleToysTime[self.moduleId]
	local totalMaxNum = rewardData[5].time
				
    for i = 1,5 do
        local data1 = rewardData[i]
        
		if data1 then
			local textlable = self.view:getChildAutoType("txt_itmeNum"..i)
			textlable:setText(data1.time)
			local progressBar = self.view:getChildAutoType("progressBar"..i)
			local item = self.view:getChildAutoType("item"..i)
			local box = self.view:getChildAutoType("box_"..i)
			local itemCellObj = item:getChildAutoType("itemCell")
			local txt_num = item:getChildAutoType("txt_num")
			local takeCtrl = item:getController("takeCtrl")
			local boxCtrl = box:getController("c1")
			local itemCell = BindManager.bindItemCell(itemCellObj)
			--itemCell:setNoFrame(true)
			local canGet = ModelManager.TwistEggModel.drawCount >= data1.time  
			local hasGet = ModelManager.TwistEggModel.recvRecords[i] ~= nil
			if canGet then
				boxCtrl:setSelectedIndex(1)
				if hasGet then
					takeCtrl:setSelectedIndex(2)
				else
					takeCtrl:setSelectedIndex(1)
				end
			else
				boxCtrl:setSelectedIndex(0)
				takeCtrl:setSelectedIndex(0)
			end
			
			txt_num:setText(data1.reward[1].amount)
			itemCell:setData(data1.reward[1].code,0,data1.reward[1].type)
			itemCell.txtNum:setVisible(false)
			
			
			if canGet then
				item:getChildAutoType("itemCell"):setTouchable(false)			
				item:removeClickListener(11)
				item:addClickListener(function(context)
					context:stopPropagation()
					if takeCtrl:getSelectedIndex() == 0 then
						RollTips.show(Desc.TwistEgg_summonNoRewardTips1)
						return
					elseif takeCtrl:getSelectedIndex() == 2 then
						RollTips.show(Desc.TwistEgg_summonNoRewardTips2)
						return
					end
					if self.isEnd then RollTips.show(Desc.TwistEggTask_ended) end
					local reqInfo = {
						activityId = GameDef.ActivityType.Gashapon,
						id = i,
					}
					RPCReq.Activity_Gashapon_RecieveReward(reqInfo,function(params)
						printTable(8848,">>.params>>",params)
						-- self:refreshCumulate()
						
					end)
				end,11)
			else
				item:getChildAutoType("itemCell"):setTouchable(true)
			end
			
			if i == 1 then
				progressBar:setMax(data1.time)
				progressBar:setValue(maxHistoryTimes >= data1.time and data1.time or maxHistoryTimes )
			else
				local data2 = rewardData[i-1]
				local maxNum = data1.time - data2.time
				progressBar:setMax(maxNum)
				progressBar:setValue(maxHistoryTimes >= data1.time and maxNum or (maxHistoryTimes - data2.time) )
			end
	
		end
		
    end
	
	if self.moduleId == 3 then
		self.txt_CumulateTimes:setText(maxHistoryTimes)
	else
		self.txt_CumulateTimes:setText(string.format(Desc.TwistEgg_cumulateTimes, maxHistoryTimes, totalMaxNum))
	end
    
	self:updateCountTimer()
end


-- 倒计时
function TwistEggView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.Gashapon)
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

function TwistEggView:_exit()
	self.isDrawing = false
	if self.timer then
		TimeLib.clearCountDown(self.timer)
	end
	
	if self.lastReward then
		Scheduler.scheduleNextFrame(function()
			ViewManager.open("AwardShowView",{reward = self.lastReward})
			self.lastReward = false
		end)
	end
end



return TwistEggView