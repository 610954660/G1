--Name : ExpeditionView.lua
--Author : generated by FairyGUI
--Date : 2020-5-15
--Desc : 

local ExpeditionView,Super = class("ExpeditionView", Window)
local TimeUtil= require "Game.Utils.TimeUtil"



function ExpeditionView:ctor()
	--LuaLog("ExpeditionView ctor")
	self._packName = "Expedition"
	self._compName = "ExpeditionView"
	self._rootDepth = LayerDepth.Window
	self._isFullScreen = true
	
	self.data = false
	
	self.config = false
	self.levelConfig = false
	self.spineNode = false
	self.isSend = false
	self._countDownTimerId = false
	self.schedulerID = false
	self.haveBigReceive=false
	self.skipBattle=false
end

function ExpeditionView:_initEvent( )
	
end

function ExpeditionView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Expedition.ExpeditionView
		vmRoot.leftTime = viewNode:getChildAutoType("$leftTime")--text
		vmRoot.bugeiicon = viewNode:getChildAutoType("$bugeiicon")--image
		vmRoot.bugei = viewNode:getChildAutoType("$bugei")--text
		vmRoot.curTitle = viewNode:getChildAutoType("$curTitle")--text
		vmRoot.guankaList = viewNode:getChildAutoType("$guankaList")--list
		vmRoot.agentBtn = viewNode:getChildAutoType("$agentBtn")--Button
		vmRoot.jiantou = viewNode:getChildAutoType("$jiantou")--
		vmRoot.rankBtn = viewNode:getChildAutoType("$rankBtn")--Button
		vmRoot.shopBtn = viewNode:getChildAutoType("$shopBtn")--Button
		vmRoot.bg1 = viewNode:getChildAutoType("$bg1")--
		vmRoot.bg = viewNode:getChildAutoType("$bg")--
		vmRoot.btn_help = viewNode:getChildAutoType("$btn_help")--Button
		vmRoot.btn_goddess = viewNode:getChildAutoType("$btn_goddess")--Button
	--{vmFieldsEnd}:Expedition.ExpeditionView
	--Do not modify above code-------------
	self.skipToggle=viewNode:getChildAutoType("skipToggle")--Button
end

function ExpeditionView:_initUI( )
	self:_initVM()
	self:initBigreward()
	self.btn_help:addClickListener(function(  )
			local info={}
			info['title']=Desc.help_StrTitle12
			info['desc']=Desc.help_StrDesc12
			ViewManager.open("GetPublicHelpView",info)
		end);
	
		self.bigRewardFrame:addClickListener(function()
			if self.haveBigReceive then		
				  local function success(data)
					printTable(31,"领取奖励返回",data)
					  if data and data.data then
						for key, value in pairs(data.data) do
							ExpeditionModel.data.rewardMap[key]=value
						end
						ExpeditionModel:setBigReward()
					  end
					  if tolua.isnull(self.view) then return end
					  self:updateBigReward()
				  end
				  local bigreward= ExpeditionModel:getBigReward()
				  printTable(31,"领取奖励",bigreward)
				  local params = {
					theNthId = bigreward.theNthId
				  }
				  RPCReq.EndlessRoad_RecvReward(params,success)
			end
	  end)

	  self.btn_goddess:addClickListener(function()
		ViewManager.open("ExpeditionTearsView")
	end)

		self.rankBtn:addClickListener(function()
			if self.data then
				ViewManager.open("PublicRankView", {type = self.data.index})
			else
				RollTips.show(Desc.expedition_randtips)
			end
			--self:play_nextAni( function()
				--self:showGuankaUI( )
			--end,function ()
				--self.isSend = false
			--end) 
			--self.bg:setVisible(true)
			--self.bg:getTransition("t1"):play(function()self.bg:setVisible(false)end)
			--self.view:getTransition("enter"):play(function()

					--self.isSend = false
				--end);
		end)

	self.shopBtn:addClickListener(function()
		ModuleUtil.openModule( ModuleId.Shop.id , true, {shopType = 6})
	end)
	
	self.agentBtn:addClickListener(function()
		ExpeditionModel:reqAgentList(function()
			ViewManager.open("EDAgentListView")
		end)
	end)
	
	self.guankaList:setItemRenderer(function(index,obj)
			self:initGuankaList(obj,index)
		end)
	
	self.eventConfig = DynamicConfigData.t_endlessRoadEvent
	self.levelConfig = DynamicConfigData.t_endlessRoadOrder
	self.nodeConfig = DynamicConfigData.t_endlessRoadNode
	
	self.jiantou:setVisible(false)
	--self.bg:getChildAutoType("zhezhao"):setVisible(false)
	self.bg:setVisible(false)
	
	self.bg1:getChildAutoType("bg"):setURL(PathConfiger.getBg("bg_Expedition.jpg"))
	self.bg1:getChildAutoType("bg2"):setURL(PathConfiger.getBg("bg_Expedition.jpg"))
	
	ExpeditionModel:reqData(function() 
			if tolua.isnull(self.view) then return end
			self:showGuankaUI() 
			if ExpeditionModel.data.nodeId == 1  then
				self.view:getTransition("jiantou"):play(function()
					
				end);
				self.jiantou:setVisible(true)
			end
			
			local times =  TimeLib.getOffsetTime(ExpeditionModel.data.startTime/1000+24*60*60*2)
			
			self._countDownTimerId = TimeUtil.upText(self.leftTime , times ,"%s","",  true )
		end)

	self.view:getChildAutoType("closeButton"):addClickListener(function ()
			print(33,"sssssssssss")
			self:closeView()
		end)
	
	self.skipToggle=self.view:getChildAutoType("skipToggle")
	self.skipToggle:addClickListener(function ()
			--arenaInfo=ArenaModel:getRankInfo()
			--if arenaInfo.myInfo.fightNum<canskipFightNum then
				--RollTips.show(desc)
				--self.skipToggle:setSelected(false)
				--return
			--end
			self.skipBattle = self.skipToggle:isSelected()
			PataModel:saveSkipArray(GameDef.BattleArrayType.EndlessRoad, self.skipBattle)
		end)

	local open,tips = ModuleUtil.skipOpen(9999)
	if tips then self.skipToggle:setVisible(false) end
	if not tips and PataModel:checkSkipArray(GameDef.BattleArrayType.EndlessRoad) then
		self.skipToggle:setSelected(true)
		self.skipBattle =true
	end
	
	
	
	
end

function ExpeditionView:lockView( value )
	self.bg:setVisible(value)
	self.bg:setTouchable(value)
end

function ExpeditionView:EndlessRoad_Notify(_,data )
	ExpeditionModel.data = data.data
	if tolua.isnull(self.view) then return end
	self:showGuankaUI( )
	
	local times =  TimeLib.getOffsetTime(ExpeditionModel.data.startTime/1000+24*60*60*2)
	if self._countDownTimerId then
		TimeUtil.clearTime(self._countDownTimerId)
	end
	self._countDownTimerId = TimeUtil.upText(self.leftTime , times ,"%s","",  true )
end

function ExpeditionView:showGuankaUI( )
	if ExpeditionModel.data and not tolua.isnull(self.view) then
		self.data = clone(ExpeditionModel.data)
		local levelConf = self.levelConfig[self.data.index]
		self.curTitle:setText(Desc.expedition_title:format(levelConf.minLv,levelConf.maxLv,self.data.nodeId))
		self.bugei:setText(self.data.point)
		
		self.jiantou:setVisible(false)
		self.guankaList:setVisible(true)
		self.guankaList:setNumItems(3)
	end
	self:lockView( false )
end

function ExpeditionView:initGuankaList( obj,index )
	local eventData = self.data.eventList[index+1]
	if not eventData then return end
	local eventConfig = self.eventConfig[eventData.eventType]
	local title = obj:getChildAutoType("title")
	local headIcon = obj:getChildAutoType("headIcon")
	local value = obj:getChildAutoType("value")
	local xzlist = obj:getChildAutoType("xzlist")
	local play = obj:getChildAutoType("play")
	local desc = obj:getChildAutoType("desc")
	local heroCell = obj:getChildAutoType("heroCell")
	
	local objCtrl = obj:getController("state")
	objCtrl:setSelectedIndex(eventData.eventType-1)
	headIcon:getController("state"):setSelectedIndex(eventData.eventType-1)
	local costCtrl = play:getController("cost")
	if eventConfig.costPoint > 0 then
		costCtrl:setSelectedIndex(1)
		play:getChildAutoType("cost"):setText(eventConfig.costPoint)
		if ExpeditionModel.data.point < eventConfig.costPoint then
			play:getChildAutoType("cost"):setColor({r=255,g=0,b=0})
		else
			play:getChildAutoType("cost"):setColor({r=0x65,g=0x48,b=0x00})
		end
	else
		costCtrl:setSelectedIndex(0)
	end
	
	if eventData.combat and eventData.combat ~= "" then
		value:setText(StringUtil.transValue(eventData.combat))
	end
	
	if eventData.eventType == 4 or eventData.eventType == 5 then
		local hero = BindManager.bindPlayerCell(heroCell)
		heroCell:getChildAutoType("playerName"):setColor({r=255,g=255,b=255})
		hero:setHead(eventData.head, eventData.level,eventData.id,eventData.name,eventData.headBorder)
		
	end
	
	desc:setText(eventConfig.desc)
	title:setText(eventConfig.name)
	headIcon:getChild("headIcon"):setIcon(PathConfiger.getHeroOfMonsterDex(eventData.head))
	
	local xzcion = {}
	
	for k,v in pairs(eventData.heroCategory) do
		local icons = PathConfiger.getCardCategory(v.index)
		table.insert(xzcion,icons)
	end
	
	for k,v in pairs(eventData.heroCareer) do
		local icons = PathConfiger.getCardProfessionalWhite(v.index)
		table.insert(xzcion,icons)
	end
	
	xzlist:setItemRenderer(function(index,obj)
			obj:setIcon(xzcion[index+1])
			obj:getChildAutoType("n2"):setVisible(false)
		end)
	
	xzlist:setNumItems(#xzcion)
	
	headIcon:addClickListener(function()
			if eventData.eventType < 3 then
				
				local reward = self.nodeConfig[ExpeditionModel.data.index][ExpeditionModel.data.nodeId]
				if not reward then 
					reward = self.nodeConfig[ExpeditionModel.data.index][#self.nodeConfig[ExpeditionModel.data.index]]
				end
				local parm = {xzcion = xzcion,eventData = eventData,index = index+1,reward = reward}
				if not self.skipBattle then
					ExpeditionModel:reqBattleData(index+1,function ()
						ViewManager.open("EDEnemyView",parm)
					end)
				else
					Dispatcher.dispatchEvent(EventType.expedition_fightEvent,parm.eventData,parm.index)
				end
				
				
			end
		end,33)
	
	play:addClickListener(function()
			if ExpeditionModel.data.point >= self.eventConfig[eventData.eventType].costPoint then
				
				if self.bg:isVisible() then return end
				self["playEvent"..eventData.eventType](self,eventData,index+1,xzcion)
			else
				RollTips.show(Desc.expedition_buji)
			end
		end,33)
	
end

function ExpeditionView:playEvent1( eventData,index ,xzcion)
	local reward = self.nodeConfig[ExpeditionModel.data.index][ExpeditionModel.data.nodeId]
	if not reward then 
		reward = self.nodeConfig[ExpeditionModel.data.index][#self.nodeConfig[ExpeditionModel.data.index]]
	end
	local parm = {xzcion = xzcion,eventData = eventData,index = index,reward = reward}
	if not self.skipBattle then
		ExpeditionModel:reqBattleData(index,function ()
			ViewManager.open("EDEnemyView",parm)
		end)
		
	else
		Dispatcher.dispatchEvent(EventType.expedition_fightEvent,parm.eventData,parm.index)
	end
	
	
end

function ExpeditionView:playEvent2( eventData,index,xzcion )
	self:playEvent1( eventData,index,xzcion )
end

function ExpeditionView:playEvent3( eventData,index )
	if self.isSend then RollTips.show(Desc.common_networktips) return  end
	self.isSend = true
	RPCReq.EndlessRoad_TriggerEvent({index	= index},function(data)
		printTable(33,"playEvent3",data)
		ExpeditionModel.data = data.data
		ExpeditionModel:setBigReward()
		self.isSend = false
		if tolua.isnull(self.view) then return end
		local params = {}
		params.reward = data.reward
		params.type = GameDef.BattleArrayType.Normal
		params.closefuc = function()
			self:play_nextAni(function()
				self:showGuankaUI( )
			end,function ()
				self.isSend = false
			end)
		end
		ModelManager.PlayerModel:set_awardData(params)
		if tolua.isnull(self.view) then return end
		local listItem = self.guankaList:getChildAt(index-1)
		local item = listItem:getChildAutoType("play")
		local pos = item:localToGlobal(Vector2.zero)
		printTable(33,"set_awardData",params)
		self:lockView( true )
		self:play_spine("Effect/UI/Ef_yuanzheng_baoxiang","baoxiang_chuxian",self.view:getWidth()/2, function()
				Dispatcher.dispatchEvent(EventType.show_gameReward, {gamePlayType = params.type})

			end )
		
	end,function (errorData)
				RollTips.showError(errorData)
				self.isSend = false
			end)
end

function ExpeditionView:playEvent4( eventData,index)
	if self.isSend then RollTips.show(Desc.common_networktips) return  end
	self.isSend = true
	RPCReq.EndlessRoad_TriggerEvent({index	= index},function(data)
			printTable(33,"playEvent4",data)
			ExpeditionModel.data = data.data
			ExpeditionModel:setBigReward()
			self.isSend = false
			RollTips.show(Desc.expedition_friend:format(data.parems))
			if tolua.isnull(self.view) then return end
			self:lockView( true )
			self:play_nextAni(function()
					self:showGuankaUI( )
				end,function ()
					self.isSend = false
				end)
			
			self:play_addBuji( index,data.parems,function ()
					--self:showGuankaUI( )
					--self.isSend = false
				end )
			
		end,function (errorData)
				RollTips.showError(errorData)
				self.isSend = false
			end)

end

function ExpeditionView:playEvent5( eventData,index )
	if self.isSend then RollTips.show(Desc.common_networktips) return  end
	self.isSend = true
	RPCReq.EndlessRoad_TriggerEvent({index	= index},function(data)
		printTable(33,"playEvent5",data)
			ExpeditionModel.data = data.data
			ExpeditionModel:setBigReward()
			if tolua.isnull(self.view) then return end
			RollTips.show(Desc.expedition_huiy:format(data.parems))
			if tolua.isnull(self.view) then return end
			--self:showGuankaUI( )
			self:lockView( true )
			self:play_spine("Effect/UI/Ef_yuanzheng_jiaxue", "animation",display.width/2,function()
					--Dispatcher.dispatchEvent(EventType.show_gameReward)

				end )
			
			self:play_nextAni(function()
					self:showGuankaUI( )
				end,function ()
					self.isSend = false
				end)
			self.isSend = false
		end,function (errorData)
				RollTips.showError(errorData)
				self.isSend = false
			end)
end

function ExpeditionView:playEvent6( eventData,index )
	if self.isSend then RollTips.show(Desc.common_networktips) return  end
	local info = {}
	info.title = Desc.expedition_cd
	info.text = Desc.expedition_chongd
	info.type = "yes_no"
	info.onYes = function()
		self.isSend = true
		RPCReq.EndlessRoad_TriggerEvent({index	= index},function(data)
				printTable(33,"playEvent6",data)
				ExpeditionModel.data = data.data
				ExpeditionModel:setBigReward()
				self.isSend = false
				if tolua.isnull(self.view) then return end
				self:lockView( true )
				self.view:displayObject():runAction(cc.Sequence:create(
					cc.DelayTime:create(0.45),
					cc.CallFunc:create(function ()
						--self:showGuankaUI( )
				end),
				cc.DelayTime:create(0.4),
				cc.CallFunc:create(function ()
					 RollTips.show(Desc.expedition_jump:format(data.parems))end),
				cc.DelayTime:create(0.15),cc.CallFunc:create(function ()
								self:showGuankaUI( )
						end)))
				self.bg:setVisible(true)
				self.bg:getTransition("t1"):play(function()self.bg:setVisible(false)end)
				self.view:getTransition("enter"):play(function()
						self.isSend = false
						
					end);
			end,function (errorData)
					RollTips.showError(errorData)
					self.isSend = false
				end)
	end
	Alert.show(info)
end

function ExpeditionView:playEvent7( eventData,index )
	if self.isSend then RollTips.show(Desc.common_networktips) return  end
	
	local info = {}
	info.title = Desc.expedition_nt
	info.text = Desc.expedition_next
	info.type = "yes_no"
	info.onYes = function()
		self.isSend = true
		RPCReq.EndlessRoad_TriggerEvent({index	= index},function(data)
				printTable(33,"playEvent7",data)
				ExpeditionModel.data = data.data
				ExpeditionModel:setBigReward()
				if tolua.isnull(self.view) then return end
				--RollTips.show(Desc.expedition_jump:format(data.parems))
				self:lockView( true )
				self.view:displayObject():runAction(cc.Sequence:create(cc.DelayTime:create(1),
						cc.CallFunc:create(function ()
								self:showGuankaUI( )
							end)))
				self.bg:setVisible(true)
				self.bg:getTransition("t1"):play(function()self.bg:setVisible(false)end)
				self.view:getTransition("enter"):play(function()
						
						self.isSend = false
					end);
				
			end,function (errorData)
					RollTips.showError(errorData)
					self.isSend = false
				end)
	end
	Alert.show(info)
end

function ExpeditionView:expedition_fightEvent( _,eventData,index )
	local function battleHandler(eventName)
		if eventName == "begin" then
			if self.isSend then RollTips.show(Desc.common_networktips) return  end
			self.isSend = true
			RPCReq.EndlessRoad_TriggerEvent({isSkip = self.skipBattle,index	= index},function(data)
					printTable(33,"playEvent1",data)
					ExpeditionModel.data = data.data
					ExpeditionModel:setBigReward()
					if tolua.isnull(self.view) then return end
					if data.eventType < 3 then
						local params = {}
						params.isWin = data.parems ~= 0 and true or false
						params.reward = data.reward
						params.type = GameDef.GamePlayType.EndlessRoad
						if params.isWin then
							params.closefuc = function()
								if tolua.isnull(self.view) then return end
								self:play_nextAni(function()
										self:showGuankaUI( )
									end,function ()
										self.isSend = false
									end)
							end
						else
							params.closefuc = function()
								if tolua.isnull(self.view) then return end
								self:showGuankaUI( )
							end
						end
						ModelManager.PlayerModel:set_awardData(params)
						if self.skipBattle then
							Dispatcher.dispatchEvent(EventType.show_gameReward,{gamePlayType = GameDef.GamePlayType.EndlessRoad})
						end
					end
					self.isSend = false
				end,function (errorData)
					RollTips.showError(errorData)
					self.isSend = false
				end)
		elseif eventName == "end" then
			--  ViewManager.open("PushMapEndLayerView",{film=0})
			print(33,"eventName ==  then")
			if ModelManager.PlayerModel:get_awardData() and ModelManager.PlayerModel:get_awardData().isWin == false then
				self:showGuankaUI( ) 
			end
		end
	end

	local zy = 1
	local zz = 1

	for k,v in pairs(eventData.heroCategory) do
		zz = v.index
	end

	for k,v in pairs(eventData.heroCareer) do
		zy = v.index
	end
	
	print(33,"ExpeditionView dispatchEvent.battle_requestFunc")
	Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,{skipBattle =self.skipBattle,zhiye=zy,zhongzu=zz,heroNum = 3,category=0
			,index = index,fightID=DynamicConfigData.t_endlessRoadConst[1].fightId,configType=GameDef.BattleArrayType.EndlessRoad})
	
end

function ExpeditionView:play_addBuji( index,num,fun )
	local listItem = self.guankaList:getChildAt(index-1)
	local item = listItem:getChildAutoType("play")
	local pos = item:localToGlobal(Vector2.zero)
	local pos_to = self.bugeiicon:localToGlobal(Vector2.zero)

	for i = 1, num do
		
		local aImage = fgui.UIPackage:createObject("Expedition","bugei");
		aImage:setPosition(pos.x - self.view:getPosition().x,pos.y)
		
		local function complete()
			if i==num and fun then
				fun()
				print(33,"end")
			end
			if not tolua.isnull(aImage) then
				aImage:removeFromParent()
			end
		end
		aImage:displayObject():runAction(cc.ScaleTo:create(0.5+i*0.2,0.8))
		TweenUtil.to(aImage, {onComplete = complete,x = pos_to.x- self.view:getPosition().x, y = pos_to.y, time = 0.5+i*0.2, ease = EaseType.SineInOut})
		self.view:addChild(aImage)
	end
end

function ExpeditionView:play_spine( spine,ani,x,fun )
	if self.spineNode then
		self.spineNode:removeFromParent()
	end
	self.spineNode = SpineMnange.createSpineByName(spine)
	self.view:displayObject():addChild(self.spineNode)
	self.spineNode:setAnimation(0, ani, false);
	self.spineNode:setPosition(x-self.view:getPosition().x,display.height/2)
	self.spineNode:setCompleteListener(function(name)
			if fun then
				fun()
			end
			self.schedulerID = Scheduler.scheduleNextFrame(function()
					if not tolua.isnull(self.spineNode) then
						self.spineNode:removeFromParent()
						self.spineNode = false
					end
					self.schedulerID = false
				end)
			
		end)
end

function ExpeditionView:play_nextAni( fun,fun2 )
	self.view:displayObject():runAction(cc.Sequence:create(cc.DelayTime:create(3),
			cc.CallFunc:create(function ()
					
				end)))
	
	self.view:getTransition("next"):play(function()
			if fun then
				fun()
			end
			self.view:getTransition("nextin"):play(function()
					if fun2 then
						fun2()
					end
				end);
		end);
	self.bg1:getChildAutoType("bg"):setVisible(true)
	self.bg1:getTransition("t0"):play(function()
			self.bg1:getChildAutoType("bg"):setVisible(false)
		end);
end

function ExpeditionView:initBigreward()
		local vmRoot = self
		local viewNode = self.view
		local bigRewardFrame = viewNode:getChildAutoType("$bigRewardFrame")--
		vmRoot.bigRewardFrame = bigRewardFrame
		bigRewardFrame.bigRewardTitle = viewNode:getChildAutoType("$bigRewardFrame/$bigRewardTitle")--text
		bigRewardFrame.bigRewardFrame = viewNode:getChildAutoType("$bigRewardFrame/$bigRewardFrame")--loader
		bigRewardFrame.receiveCondition = viewNode:getChildAutoType("$bigRewardFrame/$receiveCondition")--richtext
		bigRewardFrame.bigRewards = viewNode:getChildAutoType("$bigRewardFrame/$bigRewards")--list
		self:updateBigReward()
end

function ExpeditionView:set_ExpeditionBigRewardEvent()
	self:updateBigReward()
end

function ExpeditionView:updateBigReward()
	local bigreward= ExpeditionModel:getBigReward()
	if next(bigreward)==nil then
		self.bigRewardFrame:setVisible(false)
		return
	end
	local tempData=DynamicConfigData.t_endlessRoadBigReward[bigreward.id]
	self.bigRewardFrame:setVisible(true)
	self.haveBigReceive=false
	self.bigRewardFrame.bigRewards:setItemRenderer(function (index,obj)
			if tempData then
				local itemcell = BindManager.bindItemCell(obj)
				local itemData = ItemsUtil.createItemData({data = tempData.reward[1]})
				itemcell:setItemData(itemData)
				if bigreward.recvState==2 then
					self.bigRewardFrame.bigRewardTitle:setText(Desc.expedition_klq)
					self.bigRewardFrame.bigRewardTitle:setColor(ColorUtil.textColor_Light.green)
					self.haveBigReceive=true
					itemcell:setReceiveFrame(true)
					itemcell:setClickable(false)
				else
					self.bigRewardFrame.bigRewardTitle:setText(Desc.expedition_nd)
					self.bigRewardFrame.bigRewardTitle:setColor(ColorUtil.textColor_Light.red)
					self.haveBigReceive=false
					itemcell:setReceiveFrame(false)
					itemcell:setClickable(true)
				end
				self.bigRewardFrame.receiveCondition:setText(Desc.expedition_el..ColorUtil.formatColorString1(10,ColorUtil.textColorStr_Light.green)..Desc.expedition_gkl)
			end
		end)
	self.bigRewardFrame.bigRewards:setNumItems(1)
end



function ExpeditionView:_exit( ... )
	Scheduler.unschedule(self.schedulerID)
	if self._countDownTimerId then
		--TimeLib.clearCountDown(self._countDownTimerId)
		TimeUtil.clearTime(self._countDownTimerId)
	end
end


return ExpeditionView


