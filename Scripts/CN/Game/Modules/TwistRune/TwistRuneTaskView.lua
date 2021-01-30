-- This is an automatically generated class by FairyGUI.

-- This is an automatically generated class by FairyGUI.

-- This is an automatically generated class by FairyGUI.

-- This is an automatically generated class by FairyGUI.

-- This is an automatically generated class by FairyGUI.

-- This is an automatically generated class by FairyGUI.

local TwistRuneTaskView,Super = class("TwistRuneTaskView", View)

function TwistRuneTaskView:ctor()
	--LuaLog("TwistRuneTaskView ctor")
	self._packName = "TwistRune"
	self._compName = "TwistRuneTaskView"
	--self._rootDepth = LayerDepth.Window
	self.pageIndex =  false
	
end

function TwistRuneTaskView:_initEvent( )
	
end

function TwistRuneTaskView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:TwistRune.TwistRuneTaskView
	self.banner = viewNode:getChildAutoType('banner')--GLoader
	self.list_page = viewNode:getChildAutoType('list_page')--GList
	self.list_reward = viewNode:getChildAutoType('list_reward')--GList
	self.txt_countTimer = viewNode:getChildAutoType('txt_countTimer')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	--{autoFieldsEnd}:TwistRune.TwistRuneTaskView
	--Do not modify above code-------------
end

function TwistRuneTaskView:_initUI( )
	self:_initVM()
	
	--printTable(5656,TwistRuneModel:getRuneActiveData())
	self.banner:setURL("UI/EquipTarget/runeBox.png")
	self:TwistRuneView_refresh()

end

function TwistRuneTaskView:TwistRuneView_refresh()
    
	if  not self.pageIndex then
		self.pageIndex=1
	end
	
	local equipTargeData,keys =  TwistRuneModel:getRuneActiveDataCfg()
	self.list_page:setItemRenderer(function(idx,obj)
			local index = idx + 1
			local data  = equipTargeData[keys[index]][1]
			local title = obj:getChildAutoType("title")
			local img_red = obj:getChildAutoType("img_red")
			RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.RuneMission.. keys[index], img_red)
			title:setText(data.setName)
		end)
	self.list_page:setNumItems(#keys)
	self.list_page:removeClickListener(11)
	self.list_page:addClickListener(function()
			local index = self.list_page:getSelectedIndex() + 1
			self.pageIndex = index
			self:refreshList(keys[self.pageIndex])
	end,11)
	self:refreshList(keys[self.pageIndex])
	self.list_page:setSelectedIndex(self.pageIndex-1)
end





function TwistRuneTaskView:refreshList(pageIndex)

	
	local equipTargeData=TwistRuneModel:getRuneActiveData(pageIndex)
	
	


	
	self.list_reward:setItemRenderer(function(idx,obj)
			local index = idx + 1
			local data  = equipTargeData[index]
			local takeCtrl    = obj:getController("takeCtrl")   -- 0 可领取 1 不可领取 2 已领取
			local txt_passNum = obj:getChildAutoType("txt_passNum")
			local txt_title   = obj:getChildAutoType("txt_title")
			local btn_take    = obj:getChildAutoType("btn_take")
			local btn_travel  = obj:getChildAutoType("btn_travel")
			local list_reward = obj:getChildAutoType("list_reward")

			local img_red     = btn_take:getChildAutoType("img_red")
			
			
			RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.RuneMission.. pageIndex .. data.id, img_red)
			
			img_red:setVisible(data.state==0)
			
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
						activityType=GameDef.ActivityType.RuneMission
					}
					RPCReq.Activity_EquipMission_GetReward(reqInfo,function()
							print(8848,">>>>>装备目标，奖励领取成功！>>>>>")
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
	self.list_reward:setData(equipTargeData)
	self:updateCountTimer()
end



-- 倒计时
function TwistRuneTaskView:updateCountTimer()
	if self.isEnd then return end
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.RuneMission)
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



return TwistRuneTaskView