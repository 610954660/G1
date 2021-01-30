
---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-13 19:30:46
---------------------------------------------------------------------
-- 战斗开始之后
--
---@class BattleModel
local BattleSecnesView,Super = class("BattleSecnesView", Window)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local HeroPos=ModelManager.BattleModel.HeroPos
local SeatType=ModelManager.BattleModel.SeatType

local HeroItem=require "Game.Modules.Battle.Cell.HeroItem"--每个英雄信息的item
local MainMsgBoard = require "Game.Modules.MainUI.MainMsgBoard"
local SubItem=require "Game.Modules.Battle.Cell.SubItem"

function BattleSecnesView:ctor()
	self._packName = "Battle"
	self._compName = "BattleSecnesView"

	self.battleData=false
	self.roundNum=false
	self.allNum=false

	self.hadEnd=false
	self._isFullScreen = true

	self._rootDepth = LayerDepth.Window


	self.openSpeedFx=false
	self.boosBar=false
	
	self.hpGroup=false
	self.topValue=false
	self.bossIcon=false
	self.playerSubList=false
	self.enemySubList=false
	self.resetBtn=false
	
	local path = cc.FileUtils:getInstance():getWritablePath()
	path = string.gsub (path, "/","\\")
	self.currentFolder = string.gsub (path, "Runtime\\Win\\whale","Resources\\Scripts\\CN")
	self.logFolder=string.gsub (path, "Runtime\\Win\\whale","Resources\\Scripts\\CN")
	self.luaFile = self.currentFolder .."/Game/Modules/Battle/Cell/battleData.lua"

end


function BattleSecnesView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Battle.BattleSecnesView
	vmRoot.chatBtn = viewNode:getChildAutoType("$chatBtn")--Button
	vmRoot.bagBtn = viewNode:getChildAutoType("$bagBtn")--Button
	vmRoot.selfCamp = viewNode:getChildAutoType("$selfCamp")--Button
	vmRoot.eneymyCamp = viewNode:getChildAutoType("$eneymyCamp")--Button
	vmRoot.detBtn = viewNode:getChildAutoType("$detBtn")--Button
	--{vmFieldsEnd}:Battle.BattleSecnesView
	--Do not modify above code----------
	--vmRoot.detBtn:setSortingOrder(13)
	--vmRoot.bagBtn:setSortingOrder(13)
	self.UIGroup=viewNode:getChildAutoType("UI")--Button

end




function BattleSecnesView:_initUI()


	self:_initVM()

	self.centerPoint=self.view:getChildAutoType("centerPoint")
	self.enemyCenter=self.view:getChildAutoType("enemyCenter")
	self.playerCenter=self.view:getChildAutoType("playerCenter")
	self.arrayCenter=self.view:getChildAutoType("arrayCenter")
	self.gameLabel=self.view:getChildAutoType("gameLabel")--替补进场飘字
	self.quickEnd=self.view:getChildAutoType("quickEnd")
	self.quickEnd2=self.view:getChildAutoType("quickEnd2")
	self.speedBt=self.view:getChildAutoType("speedBt")
	self.roundNum=self.view:getChildAutoType("roundNum")
	
	local viewInfo = ViewManager.getViewInfo("BattleBeginView")
	self.bossBar = viewInfo.window.ctlView["GuildBossBarView"].bossBar
	-- self.bossBar=self.view:getChildAutoType("bossBar")
	self.lihuiMask=self.view:getChildAutoType("lihuiMask")
	self.playerSubList=self.view:getChildAutoType("playerSubList")
	self.enemySubList=self.view:getChildAutoType("enemySubList")
	self.backBtn=self.view:getChildAutoType("&mainUIBtn")
	self.resetBtn=self.view:getChildAutoType("$resetBtn")
	self.btn_saveData=self.view:getChildAutoType("btn_saveData")
	
	if __IS_RELEASE__ then --无条件结束游戏测试用的按钮
		self.quickEnd2:setVisible(false)
	end

	
	
	self.battleData= self._args.playData
	
	self.speedBt:addClickListener(function (...)--游戏加速
			self:setSpeedType()
	end)
	self.quickEnd:addClickListener(function (...)--立即结束游戏
			local battleType = self._args.arrayType
			if self.hadEnd and (VoidlandModel:isVoidlandMode(battleType) and VoidlandModel.waitBattle) then
				return
			end
			local isOpen,tips=self:checkSkip()

						if tips==nil or self._args.isRecord==true then
				self.hadEnd=true
				Dispatcher.dispatchEvent(EventType.battle_Next,{onClickSkip=true,arrayType=self._args.arrayType,result=self.battleData.result})
			else
				RollTips.show(tips)
			end
		end)
	self.view:addClickListener(function ()
			ViewManager.close("BattleBuffView")
		end)

	self.selfCamp:addClickListener(function ()
			ViewManager.open("BattleCampView",{heroPos=BattleModel.HeroPos.player,inBattle=true})
		end)
	self.eneymyCamp:addClickListener(function ()
			ViewManager.open("BattleCampView",{heroPos=BattleModel.HeroPos.enemy,inBattle=true})
		end)
	BattleModel:changeCampeItem(self.selfCamp,BattleModel.HeroPos.player,true)
	BattleModel:changeCampeItem(self.eneymyCamp,BattleModel.HeroPos.enemy,true)
	
	--self.view:displayObject():onUpdate(function (dt)
			--BattleManager:getInstance():onUpdate(dt)
			--SkillManager.onUpdate(dt)
	--end,0)
	self.detBtn:addClickListener(function ()
			ViewManager.open("CardBagView")--打开卡牌库
		end)

	self.bagBtn:addClickListener(function ()
			ViewManager.open("BagWindow")
		end)
	self.chatBtn:addClickListener(function ( ... )
			ViewManager.open("ChatView",{isBattleView=1})
		end)
	self.backBtn:addClickListener(function (...)
		if StrideServerModel:isCrossPVPType(self._args.arrayType) then
			Dispatcher.dispatchEvent("battle_end", {arrayType = GameDef.BattleArrayType.TopArenaAckOne});
			ViewManager.showMainView()
		else
			--ViewManager.showMainView()
			Dispatcher.dispatchEvent(EventType.battle_close,{arrayType=self._args.arrayType})
			ViewManager.showMainView()
			--ViewManager.open("MainUIView")
		end
	end)
	

	if not __IS_RELEASE__ then --无条件结束游戏测试用的按钮
		self.quickEnd2:addEventListener(FUIEventType.TouchEnd,function ()
				if self.hadEnd then
					return
				end
				self.hadEnd=true
				Dispatcher.dispatchEvent(EventType.battle_Next,{onClickSkip=true,arrayType=self._args.arrayType,result=self.battleData.result})
		end)
		self.btn_saveData:setVisible(true)
		self.btn_saveData:addClickListener(function (...)
				--print(086,self.luaFile)
				--print(086,FightManager.haveFight(self._args.arrayType))
				RollTips.show("测试战报保持成功")
				GMModel:saveTableToFile(FightManager.getBettleData(self._args.arrayType),self.luaFile)
		end)
	else
		if self.btn_saveData then
			self.btn_saveData:setVisible(false)
		end
	end

	self:showArrayTypeUI()
	--local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	--if viewInfo then
		--self.secretView=viewInfo.window.ctlView["SecretWeaponBattleView"].view
	--end
end







--根据战斗玩法类型显示不同的备战场景
function BattleSecnesView:showArrayTypeUI()

	local allHurtTip=self.view:getChildAutoType("allHurHp")--总伤害特效
	local zshSkeleton=SpineUtil.createSpineObj(allHurtTip,Vector2(130,5),nil,PathConfiger.getSettlementRoot(),"Ef_zongshanghai")
	allHurtTip:setVisible(false)
	allHurtTip.Skeleton=zshSkeleton
	
	BattleModel.__mapPoints.allHurtTip=allHurtTip
	--BattleModel:setMapPoint({
			--center=self.centerPoint,
			--enemyCenter=self.enemyCenter,
			--playerCenter=self.playerCenter,
			--arrayCenter=self.arrayCenter,
			--allHurtTip=allHurtTip
	--})	
	local arrayType=self._args.arrayType
	if  self._args.isRecord then            -----战斗回放
		self.view:getController("showType"):setSelectedPage("record")
	else
		local isOpen,tips=self:checkSkip()
		self.quickEnd:setVisible(isOpen)
	end
	self.bossBar:setVisible(false)
	--是次元裂缝玩法
	if arrayType == GameDef.BattleArrayType.GuildWorldBossNumOne
		or arrayType == GameDef.BattleArrayType.GuildWorldBossNumTwo
		or arrayType == GameDef.BattleArrayType.GuildWorldBossNumThree 
		or arrayType == GameDef.GamePlayType.GuildWorldBoss then
		if self._args.isRecord then
			local mapConfig=BattleModel:getMapInfo()
			local fightId=mapConfig.fightID
			for k, bossData in pairs(DynamicConfigData.t_GuildWorldBossConfig) do
				if bossData.fightId==fightId then
					self:initBossBar(false,99999,PathConfiger.getBossHead(bossData.bossHead))
				end
			end
		else		
			local hpGroup,topValue,bossIcon=GuildModel:getFightSceenNeed( )
			self:initBossBar(hpGroup,topValue,bossIcon)
		end
	elseif arrayType == GameDef.BattleArrayType.HolidayBoss then --节日活动boss
		local config = DynamicConfigData.t_HolidayBOSS[1]
		if self._args.isRecord then
			local mapConfig=BattleModel:getMapInfo()
			local fightId=mapConfig.fightID
			if fightId == config.fightID then
				local url = ItemConfiger.getItemIconByCode(config.item[1].code)
				local hpGroup,hpMax = ActCommonBossModel:getFightSceenNeed( self._args )
				self:initBossBar(false,hpMax,url)
			end
		else
			local url = ItemConfiger.getItemIconByCode(config.item[1].code)
			local hpGroup,hpMax = ActCommonBossModel:getFightSceenNeed( self._args )
			self:initBossBar(hpGroup,hpMax,url)
		end
	elseif arrayType == GameDef.BattleArrayType.BloodAbyss then 	-- 血荆之渊玩法
		if self._args.isRecord then
			local mapConfig=BattleModel:getMapInfo()
			local fightId=mapConfig.fightID
			for _, v in pairs(DynamicConfigData.t_BloodAbyssMonster) do
				local find = false
				for k, bossData in pairs(v) do
					if bossData.fightId==fightId then
						self:initBossBar(false,99999,PathConfiger.getHeroCard(bossData.heroId))
						find = true
						break
					end
				end
				if find then break end
			end
		else		
			local head = PathConfiger.getHeroCard(BloodAbyssModel.rankBossInfo.heroId)
			self:initBossBar(false,9999999,head)
		end
	else
		 local boosRewards= DynamicConfigData.t_bossReward[500]
		 self.bossBar:getChildAutoType("icon"):setURL(PathConfiger.getItemIcon(boosRewards[1].rewardIcon))
	end
	
	if arrayType == GameDef.BattleArrayType.DevilRoad then
		self.view:getController("resetCtr"):setSelectedPage("reset")
		self.resetBtn:addClickListener(function ()
				
				
				local function f()
					SealDevilModel:devilRoad_ChooseResult(1,function ()end)
					Dispatcher.dispatchEvent(EventType.battle_reset,{arrayType=arrayType})
				end
				if SealDevilModel:getCheckTips() then
					f()
					return 
				end
				
				
				local info = {}
				info.text = Desc.DevilRoad_str1
				info.mask = true
				info.type = "yes_no"
				info.check=true
				info.onYes = function(isCheck)
					SealDevilModel:setCheckTips(isCheck)
					f()
				end
				info.onNo = function(isCheck)
					SealDevilModel:setCheckTips(isCheck)
				end
				Alert.show(info)

		end)
	end
	
	
	
	

	if  self._args.isTest then        ---剧情编辑测试战斗
		self.view:getController("showType"):setSelectedPage("editor")
		if self._args.skip==false then
			self.quickEnd:setVisible(false)
		end
		return 
	else
	
		self._mainMsgBoard = MainMsgBoard.new(self.chatBtn,false)
		for k, data in pairs(ChatModel.battleChatList) do
			self._mainMsgBoard:onNewMsg1(data)
		end
	end
	

		
	
	
	if GuideModel:IsGuiding() or self._args.isTest or self._args.isRecord or arrayType==GameDef.BattleArrayType.FriendPK then
		self.backBtn:setVisible(false)
		self.detBtn:setVisible(false)
		self.bagBtn:setVisible(false)
	end
	
	
	
	local speedIndex=BattleModel:getGameSpeed()
	self.speedBt:getController("speed"):setSelectedPage(tostring(speedIndex))
	ModelManager.BattleModel:changeGameSpeed(BattleModel.battleSpeed[speedIndex],true)
	if BattleModel:checkOpenSpeedFx() then
		self.openSpeedFx=SpineUtil.createSpineObj(self.speedBt,Vector2(0,0),"anniu",PathConfiger.getSettlementRoot(),"zhandoujiasu_texiao",nil,true,true)
	end
end



--直接下一场战斗直接刷数据
function BattleSecnesView:battle_setData()
	self.hadEnd=false
	local speedIndex=BattleModel:getGameSpeed()
	self.speedBt:getController("speed"):setSelectedPage(tostring(speedIndex))
	if not BattleManager:getInstance().isBackFight then
		ModelManager.BattleModel:changeSpeedIndex(speedIndex)
	end
	-- 连续战斗的要刷新阵容加成信息
	BattleModel:changeCampeItem(self.selfCamp,BattleModel.HeroPos.player,true)
	BattleModel:changeCampeItem(self.eneymyCamp,BattleModel.HeroPos.enemy,true)
end

--每回合开始消息
function BattleSecnesView:battle_roundStar()
	self:checkSkip()
end


--检查跳过开启条件
function BattleSecnesView:checkSkip()
	local arrayType=self._args.arrayType
	local isOpen,tips=true,nil
	if arrayType then
		isOpen,tips=ModuleUtil.skipOpen(arrayType)
	end
	if tips==nil then
		self.quickEnd:getController("State"):setSelectedPage("normal")
	else
		if not self._args.isRecord then
			self.quickEnd:getController("State"):setSelectedPage("lock")
		end
	end

	return isOpen,tips
end


--设置游戏加速状态
function BattleSecnesView:setSpeedType()
	if not ModuleUtil.moduleOpen(ModuleId.BattleSpeed.id,true) then
		return
	end
	if self.openSpeedFx then
		self.openSpeedFx:removeFromParent()
		self.openSpeedFx=false
	end
	BattleModel:saveOpenSpeed()
	local speedIndex=BattleModel:getGameSpeed()
	local changeIndex=false
	if speedIndex==1 then
		changeIndex=2
	elseif speedIndex==2 then
		if not ModuleUtil.moduleOpen(ModuleId.BattleSpeed3.id,true) then
			changeIndex=1
		else
			changeIndex=3
		end
	elseif speedIndex==3 then
		changeIndex=1
	end

	self.speedBt:getController("speed"):setSelectedPage(tostring(changeIndex))
	ModelManager.BattleModel:changeSpeedIndex(changeIndex)
	BattleModel:saveGameSpeed(changeIndex)
end
 

--改变boss血条样式
function BattleSecnesView:initBossBar(hpGroup,topValue,bossIcon)
	--local hpGroup={3000,5000,9000}
	--local topValue=999999999  --伤害大于这个值将不会变化
	--local boosIcon=""         --boss 头像
	--local viewInfo = ViewManager.getViewInfo("BattleBeginView")
	--self.bossBar = viewInfo.window.ctlView["GuildBossBarView"].bossBar
	self.hpGroup=hpGroup
	self.topValue=topValue
	self.bossBar:getChildAutoType("valueText"):setText("0")
	self.bossBar:getChildAutoType("icon"):setURL(bossIcon)
	if self._args.arrayType == GameDef.BattleArrayType.BloodAbyss then
		self.bossBar:getChildAutoType("icon"):setScale(0.8,0.8)
	elseif self._args.arrayType == GameDef.BattleArrayType.HolidayBoss then
		self.bossBar:getChildAutoType("icon"):setScale(1.5,1.5)
		self.bossBar:getChildAutoType("hpBarRTL"):setMax(1)
		self.bossBar:getChildAutoType("hpBarYellowRTL"):setMax(1)
		self.bossBar:getChildAutoType("hpBarRTL"):setValue(1)
		self.bossBar:getChildAutoType("hpBarYellowRTL"):setValue(1)
		self.bossBar:getChildAutoType("valueText"):setText(topValue)
	else
		self.bossBar:getChildAutoType("icon"):setFill(0)
		self.bossBar:getChildAutoType("icon"):setAutoSize(true)
	end
end

-- 初始化魔灵山boss血条
function BattleSecnesView:GuildMLS_battleInitBossHp(_,params)
	local maxValue = params.hpMax
	local barValue = false
	if self._args.isRecord then
		barValue = params.hp
	else
		barValue = 	ModelManager.GuildMLSModel.curBossHp
	end
	ModelManager.GuildMLSModel.bossMaxHp = maxValue
	self:initBossBarMLS(maxValue,barValue)
end

function BattleSecnesView:initBossBarMLS(maxValue,barValue)
	--local viewInfo = ViewManager.getViewInfo("BattleBeginView")
	--self.bossBar = viewInfo.window.ctlView["GuildBossBarView"].bossBar
	self.bossBar:getController("sliderFlipCtrl"):setSelectedIndex(1)
	self.bossBar:getController("playTypeCtrl"):setSelectedIndex(1)
	self.bossBar:getChildAutoType("icon"):setURL("Icon/guild/gulidMLSBoss.png")
	self.bossBar:getChildAutoType("icon"):setScale(3,3)
	self.bossBar:getChildAutoType("valueText"):setText(barValue or maxValue)

	-- self.bossBar:getChildAutoType("hpBarYellowRTL"):setMax(maxValue)
	self.bossBar:getChildAutoType("hpBarYellowRTL"):setMax(maxValue)
	self.bossBar:getChildAutoType("hpBarRTL"):setMax(maxValue)

	self.bossBar:getChildAutoType("hpBarYellowRTL"):setValue(barValue or maxValue)
	self.bossBar:getChildAutoType("hpBarRTL"):setValue(barValue or maxValue)
end

--聊天频道接受的消息
function BattleSecnesView:chat_newMsg(evt, data)
	if(self._mainMsgBoard) then
		self._mainMsgBoard:onNewMsg1(data)
	end
end

function BattleSecnesView:chat_jingyan_updataInfo(_,id)--禁言后删除
	if self._mainMsgBoard then
		for i = # self._mainMsgBoard._ChatmsgList,1, -1 do
			local chatItem =  self._mainMsgBoard._ChatmsgList[i]
			if chatItem and chatItem.fromPlayer and chatItem.fromPlayer.playerId == id then
				table.remove(self._mainMsgBoard._ChatmsgList, i)
				table.remove(self._mainMsgBoard._msgList, i)	
			end
		end
		self._mainMsgBoard.list_msg:setNumItems(#self._mainMsgBoard._msgList)
	end
end


--浮标滑动改变战斗速度
function BattleSecnesView:buoyWindow_SpeedChange()
	 BattleModel:updateGameSpeed()
end





function BattleSecnesView:_enter()

	
	
end

function BattleSecnesView:_exit()
	--退出战斗时检查一下是否有新模块开放提示
	Scheduler.scheduleNextFrame(function()
		Dispatcher.dispatchEvent(EventType.module_open_hint)
	end)
end

return  BattleSecnesView