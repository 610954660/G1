---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-08 20:19:34
---------------------------------------------------------------------

-- 战前准备的操作界面
--
---@class BattlePrepareView

local ArrayBaseView=require "Game.Modules.Battle.ArrayBaseView"

local BattlePrepareView,Super = class("BattlePrepareView", ArrayBaseView)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local HeroPos=ModelManager.BattleModel.HeroPos


local BattleConfiger=require "Game.ConfigReaders.BattleConfiger"
function BattlePrepareView:ctor()
	self._packName = "Battle"
	self._compName = "BattlePrepareView"
	self._rootDepth = LayerDepth.Window
	self._requestInfo={}
	
	self.uiTypeCtr=false
	
	-- 高阶竞技场
	self.HigherPvpOnClick=false
	self.HigherPvpOutTable = false;
	self.HigherPvpSetMask = false;
	-- 虚空幻境
	self.voidlandOnClick = false;
	self.voidlandOutTable = false;
	self.voidlandSetMask = false;
	self.voidlandScenes = false;
	
	self.ExtraordinarylevelOutTable = false
	self.ExtraordinarylevelOnClick = false
	self.ExtraordinarylevelMask = false	
	
	self.voidlandBattleBegin = false; -- 开始前需要一些判断

	self.CrossPVPOnClick = false
	self.CrossPVPOutTable = false
	self.CrossPVPSetMask = false

	self.CrossTeamPVPOnClick = false
	self.GuildLegendsOnClick = false
	self.GuildLegendsOutTable = false
	self.GuildLegendsSetMask = false
	self.TrialOutTable = false
	self.TrialOnClick = false
	self.TrialSetMask = false
	
	self.autoStartTimer = false
	self.path=false
end

function BattlePrepareView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Battle.BattlePrepareView
		vmRoot.btn_help = viewNode:getChildAutoType("$btn_help")--Button
		vmRoot.campDetail = viewNode:getChildAutoType("$campDetail")--Button
		vmRoot.eneymyCamp = viewNode:getChildAutoType("$eneymyCamp")--Button
		vmRoot.selfCamp = viewNode:getChildAutoType("$selfCamp")--Button
		vmRoot.tatical_red = viewNode:getChildAutoType("$tatical_red")--Button
	--{vmFieldsEnd}:Battle.BattlePrepareView
	--Do not modify above code----------
	vmRoot.campCloseBt=viewNode:getChildAutoType("$campRestraint/frame/closeButton")--
	Super._initVM(self)
end



function BattlePrepareView:_initUI()
	PHPUtil.reportStep(ReportStepType.FIRST_FIGHT_PREPARE)
	local viewRoot = self.view
	self:_initVM()
	Super._initUI(self)
	
	
	--如果有传了自动开始时间，则自动帮他点开始战斗
	if self._args.mapConfig and self._args.mapConfig.autoStartTime then
		if self.autoStartTimer then
			Scheduler.unschedule(self.autoStartTimer)
		end
			
		self.autoStartTimer=Scheduler.scheduleOnce(self._args.mapConfig.autoStartTime, function(time)
			local seatInfos = BattleModel:getSeatInfos()
			local hasPlayer = false
				--local seatInfos = BattleModel:getSeatInfos()
			for k, seat in pairs(seatInfos) do
				if not seat.isEmpty then
					hasPlayer = true
					break
				end
			end
			if self._args.mapConfig.configType == GameDef.BattleArrayType.FairyLand and not hasPlayer then
				FairyLandModel.autoNext = false
				Dispatcher.dispatchEvent(EventType.fairyLand_cancelAuto)
			else
				self.beginBtn:dispatchEvent(FUIEventType.Click)
			end
		end)
	end
	
	self.beginBtn:addClickListener(function (context)
			self:beginBattle()--开始战斗和保存防守阵容走一个消息
	end)

	self.saveBt:addClickListener(function (context)
			self:beginBattle()--开始战斗和保存防守阵容走一个消息
			local configType = self._args.mapConfig.configType
			if (HigherPvPModel:isHigherPvpType(configType) or 
				WorldHighPvpModel:isWoroldHighPvpArrayType(configType) or 
				self._args.mapConfig.isSetting) or 
				CrossPVPModel:isCrossPVPType(configType) or 
				CrossArenaPVPModel:isCrossPVPType(configType) or
				ExtraordinarylevelPvPModel:isCrossPVPType(configType) or 
				GuildLeagueOfLegendsModel:isGuildLegendsArrayType(configType) or
				ExtraordinarylevelPvPModel:isCrossPVPType(configType) or
				StrideServerModel:isCrossPVPType(configType) then
				return;
			end
			ViewManager.close("BattlePrepareView")
	end)
	
	if self._closeBtn then
		self._closeBtn:removeClickListener()
		self._closeBtn:addClickListener(function ()
			self:exitHandle()
			self:_returnView()
			self:closeView()
		end)
	end
	
	
	self:checkShowTactical()
	self.troopBtn:getChild("effectLoader"):displayObject():removeAllChildren()
	SpineUtil.createSpineObj(self.troopBtn:getChild("effectLoader"), vertex2(0,0), "animation", "Spine/ui/button", "zhenfatishi_texiao", "zhenfatishi_texiao",true)
	
	self.troopBtn:addClickListener(function ()
		ModuleUtil.openModule(ModuleId.Tactical.id,true,{arrayType = self._args.mapConfig.configType,path = self.path})
	end)
	self.campDetail:addClickListener(function ()
			ViewManager.open("BattleRaceView")
	end)
	self.selfCamp:addClickListener(function ()
			ViewManager.open("BattleCampView",{heroPos=BattleModel.HeroPos.player})
	end)
	self.eneymyCamp:addClickListener(function ()
			ViewManager.open("BattleCampView",{heroPos=BattleModel.HeroPos.enemy})
	end)
	
	if self._args.mapConfig.activeType ~= nil  then --爬塔的时候走一个替补新手引导
		GuideModel:checkGuideActivate({{name="tibu1",id=ModuleId.Alternate_Front.id}})
		GuideModel:checkGuideActivate({{name="tibu2",id=ModuleId.Alternate_Back.id}})
	end
	
	self:showArrayTypeUI()
end



function BattlePrepareView:exitHandle()
	local arrayType = self._args.mapConfig.configType
	if CrossPVPModel:isCrossPVPType(arrayType) then
		if CrossPVPModel:isCrossPVPDefType(arrayType) then
			local temp = CrossPVPModel:getTypeHeroTempInfo()
			for key,value in pairs(temp) do
				if value.array and table.nums(value.array) < 1 then
					RollTips.show(Desc["CrossPVPDesc6"])
					CrossPVPModel:getCurTempForSever()
					return
				end
			end
		end
	end

	if StrideServerModel:isCrossPVPType(arrayType) then
		-- local temp = StrideServerModel:getTypeHeroTempInfo()
		-- for key,value in pairs(temp) do
		-- 	if value.array and table.nums(value.array) < 1 then
		-- 		RollTips.show(Desc["CrossPVPDesc6"])
				StrideServerModel:getCurTempForSever()
		-- 		return
		-- 	end
		-- end
	end

	if ExtraordinarylevelPvPModel:isCrossPVPType(arrayType) then
			local temp = ExtraordinarylevelPvPModel:getTypeHeroTempInfo()
			for key,value in pairs(temp) do
				if value.array and table.nums(value.array) < 1 then
					--RollTips.show(Desc["CrossPVPDesc6"])
					ExtraordinarylevelPvPModel:getCurTempForSever()
					return
				end
			end
	end

end

function BattlePrepareView:onViewControllerChanged()

end


function BattlePrepareView:tactical_changeUseStatus()
	self:checkShowTactical()
end

function BattlePrepareView:checkShowTactical()
	if ModelManager.TacticalModel:getCurTactical(self._args.mapConfig.configType) == 0 and ModelManager.TacticalModel:hasActivedTactical() then
		RedManager.register("", self.troopBtn:getChild("effectLoader"))
		RedManager.register("", self.tatical_red)
		self.troopBtn:getChild("effectLoader"):setVisible(true)
		self.tatical_red:setVisible(true)
	else
		RedManager.register("M_TACTICAL", self.troopBtn:getChild("effectLoader"))
		RedManager.register("M_TACTICAL", self.tatical_red)
	end
end


--确认阵容或者开始战斗都会保存阵容配置
function BattlePrepareView:beginBattle()
	if not self._hadInit then
		RollTips.show("没有阵容信息")
	end
	if (self.voidlandBattleBegin) then
		self:voidlandBattleBegin();
	else
		Super.beginBattle(self)
	end
end



--根据战斗玩法类型显示不同的备战场景
function BattlePrepareView:showArrayTypeUI()
	
	local mapConfig= self._args.mapConfig
	local mapData=BattleConfiger.getMapByID(mapConfig.fightID)
	BattleModel:setMapInfo(mapData)
	BattleModel:setBattleConfig(mapConfig)
	self.bgIcon:setIcon(PathConfiger.getMapBg(mapData.map))
	self.path = PathConfiger.getMapBg(mapData.map)
	if mapConfig.title then
		self.prepareTitle:setText(mapConfig.title)
	else
		self.prepareTitle:setText("")
	end
	if mapConfig.configType==GameDef.BattleArrayType.ArenaDef then--判断是进攻阵容还是防守阵容
		self:toDefandConfig(true,mapConfig.configType)--普通防守阵容设置
	end
	if mapConfig.isSetting then
		self:toDefandConfig(true,mapConfig.configType)--普通防守阵容设置
	end
	if mapConfig.configType==GameDef.BattleArrayType.WorldArena then
        self:toWorldArena()  --世界擂台赛
	end
	if mapConfig.configType == GameDef.BattleArrayType.GuildPvpDef then
		self:toNormalDef() -- 公会联赛
	end

	if mapConfig.configType==GameDef.BattleArrayType.DreamPvp then
        self:toWorldArena()  --梦主争夺
	end

	if mapConfig.configType==GameDef.BattleArrayType.WorldTeamArena then
        self:toCrossTeamPVP()  --组队竞技
	end

	if mapConfig.configType==GameDef.BattleArrayType.SkyLadderDef then
        self:toLadderDef()  --跨服天梯赛
	end

	if mapConfig.configType == GameDef.BattleArrayType.SkyLadChampion then
		self:toLadderChampDef()  --跨服天梯冠军赛
	end

	if mapConfig.configType==GameDef.BattleArrayType.HigherPvpDefOne or mapConfig.configType==GameDef.BattleArrayType.HigherPvpAckOne or WorldHighPvpModel:isWoroldHighPvpArrayType(mapConfig.configType)then
		self:toHigherPvp()   --高阶竞技场
	end
	if mapConfig.configType==GameDef.BattleArrayType.DreamLandSingle or mapConfig.configType==GameDef.BattleArrayType.DreamLandMultiple then
		self:toVoidland() --虚空幻境
	end

	if mapConfig.configType==GameDef.BattleArrayType.Trail then
		self:toTrailView()
	end

	if ExtraordinarylevelPvPModel:isExtraordinarylevelType(mapConfig.configType) then
		self:toExtraordinaryPvp() --超凡段位赛
	end
	if CrossPVPModel:isCrossPVPType(mapConfig.configType) then
		self:toCrossPVPView()
	end
	if CrossArenaPVPModel:isCrossPVPType(mapConfig.configType) then
		self:toCrossArenaPVPView()
	end
	
	if ExtraordinarylevelPvPModel:isExtraordinaryAckType(mapConfig.configType) then--超凡段位赛隐藏返回按钮
			self.view:getChildAutoType("title"):setVisible(false)
			self.view:getChildAutoType("closeButton"):setVisible(false)
			self.view:getChildAutoType("close"):setVisible(false)
		else
			self.view:getChildAutoType("title"):setVisible(true)
			self.view:getChildAutoType("closeButton"):setVisible(true)
			self.view:getChildAutoType("close"):setVisible(true)
	end 

	if GuildLeagueOfLegendsModel:isGuildLegendsArrayType(mapConfig.configType) then
		self:toGuildLegends() -- 公会联赛传奇赛
	end
	self:toSecretWeaponBattleView()--秘武
	local elvesHasOpen = ModuleUtil.moduleOpen( ModuleId.Elves_Attribute.id, false)
	if ModelManager.ElvesSystemModel.elvesOpenState and elvesHasOpen and mapConfig.configType ~= GameDef.BattleArrayType.PveStarTemple then
		self:toElvesView() 	-- 精灵
	end 
	if StrideServerModel:isStridePVPType(mapConfig.configType) then --巅峰竞技
		self:toStridePVPView()
	end

	
end


--拉取阵容数据的这里可以做特殊上阵处理
function BattlePrepareView:requestHeroFinished()
	local type = self._args.mapConfig.configType
	if (HigherPvPModel:isHigherPvpType(type)) or 
	WorldHighPvpModel:isWoroldHighPvpArrayType(type) or 
	CrossPVPModel:isCrossPVPType(type) or
	CrossArenaPVPModel:isCrossPVPType(type) or
	CrossTeamPVPModel:isCrossTeamPvpType(type) or
	ExtraordinarylevelPvPModel:isCrossPVPType(type) or
	StrideServerModel:isCrossPVPType(type) or
	GuildLeagueOfLegendsModel:isGuildLegendsArrayType(type) then
		self:updateDefaultCamp()--高阶竞技场只初始化一次手牌
	end
	
	self:setBattleScenes(self._args.mapConfig)
end



--放入阵前
function BattlePrepareView:checkTable(heroInfo,seatId)
	--上阵英雄个数限制
	if self.HigherPvpOnClick then
		self.HigherPvpOnClick(heroInfo,seatId)
	elseif self.CrossPVPOnClick then
		self.CrossPVPOnClick(heroInfo,seatId)
	elseif self.ExtraordinarylevelOnClick then
		self.ExtraordinarylevelOnClick(heroInfo,seatId)
	elseif self.voidlandOnClick then
		self.voidlandOnClick(heroInfo, seatId)
	elseif self.CrossTeamPVPOnClick then
		self.CrossTeamPVPOnClick(heroInfo, seatId)
	elseif self.GuildLegendsOnClick then
		self.GuildLegendsOnClick(heroInfo, seatId)
	elseif self.TrialOnClick then
		self.TrialOnClick(heroInfo, seatId)
	else
		Super.checkTable(self,heroInfo,seatId)
	end
end

-- 下阵
function BattlePrepareView:outToTable(uuid,seatId,carInfo)
	if (self.HigherPvpOutTable) then
		self.HigherPvpOutTable(uuid, seatId);
	elseif self.CrossPVPOutTable then
		self.CrossPVPOutTable(uuid, seatId)
	elseif self.ExtraordinarylevelOutTable then
		self.ExtraordinarylevelOutTable(uuid, seatId)
	elseif self.TrialOutTable then
		self.TrialOutTable(uuid, seatId,carInfo)
	elseif (self.voidlandOutTable) then
		self.voidlandOutTable(uuid, seatId);
	elseif self.GuildLegendsOutTable then
		self.GuildLegendsOutTable(uuid, seatId)
	else
		if seatId then
			Super.outToTable(self, uuid, seatId);
		end
	end
	BattleModel:changeCampeItem(self.selfCamp,BattleModel.HeroPos.player)
end

-- 下方英雄选择框
function BattlePrepareView:setMaskOnLock()
	if (self.HigherPvpSetMask) then
		self.HigherPvpSetMask();
	elseif self.CrossPVPSetMask then
		self.CrossPVPSetMask()
	elseif self.ExtraordinarylevelMask then--段位赛
		self.ExtraordinarylevelMask()
	elseif (self.voidlandSetMask) then
		self.voidlandSetMask();
	elseif self.GuildLegendsSetMask then
		self.GuildLegendsSetMask()
	elseif self.TrialSetMask then
		self.TrialSetMask()
	else
		Super.setMaskOnLock(self);
	end
end

--备战防守可切换阵容面板
function BattlePrepareView:toDefandConfig(CanSwich,configType)
	self.uiTypeCtr:setSelectedPage("defandConfig")
	if CanSwich then
		self.playerSeatLatout:getController("configType"):setSelectedPage("defandConfig")
		local swichList=self.playerSeatLatout:getChildAutoType("swichList")	
		if configType==GameDef.BattleArrayType.ArenaDef then
			swichList:setSelectedIndex(1)
		else
			swichList:setSelectedIndex(0)
		end
		for i=0,swichList:getNumItems()-1 do
			local typeItem=swichList:getChildAt(i)
			local chooseType=false
			local fightID=false
			if i==0 then
				typeItem:getChildAutoType("MarkDown"):setVisible(false)
				chooseType=GameDef.BattleArrayType.Chapters
				fightID = DynamicConfigData.t_chaptersPoint[1][1][1].fightfd
			else
				typeItem:getChildAutoType("MarkUp"):setVisible(false)
				typeItem:getChildAutoType("selectIcon"):setIcon(UIPackageManager.getUIURL(self._packName,"arenaTitle_c"))
				chooseType=GameDef.BattleArrayType.ArenaDef
				fightID= DynamicConfigData.t_arena[1].fightId
			end
			typeItem:addEventListener(FUIEventType.Click,function()
					self:changeScenes(chooseType,fightID)
			end,1)
		end
		
	end
end

-- 组队竞技
function BattlePrepareView:toCrossTeamPVP()
	local mapConfig  = self._args.mapConfig
	if not mapConfig then return end
	local playerId	 = mapConfig.playerId
	local configType = mapConfig.configType
	local serverId 		= mapConfig.serverId or LoginModel:getUnitServerId()
	local interfaceType = mapConfig.interfaceType
	CrossTeamPVPModel.interfaceType = interfaceType
	CrossTeamPVPModel.isFirstPrep 	= mapConfig.isFirstPrep or false
	
	self.uiTypeCtr:setSelectedPage("defandConfig")
	self.playerSeatLatout:getController("configType"):setSelectedPage("defandConfig")
	self.playerSeatLatout:getChildAutoType("swichMenu"):setVisible(false);
	self.playerSubList:setVisible(false)
	self.enemySubList:setVisible(false)

	-- --高阶竞技场需要重写上阵方法
	self.CrossTeamPVPOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem=ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0;
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1;
				end
			end
			-- 空位查找
			
			if (seatCount < 6 )then
				for i = 1, 6 do
					local seat = ModelManager.BattleModel.__seatInfos[i];
					if (not seat.uuid) then
						seatItem = seat;
						break;
					end
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax);
				return;
			end
			local hasPut=ModelManager.BattleModel:checkPut(heroInfo.code)
			if hasPut then
				RollTips.show(Desc.battle_DetailsStr1)
				return
			end
			self:putoTable(seatItem,heroInfo,true)
		end
	end


	self:createComponentByPageName("CrossTeamPVPAddTopView")
end


function BattlePrepareView:toNormalDef()
	self.uiTypeCtr:setSelectedPage("defandConfig")
	self.playerSeatLatout:getController("configType"):setSelectedPage("defandConfig")
	self.playerSeatLatout:getChildAutoType("swichMenu"):setVisible(false);
end

-- 跨服天梯冠军赛
function BattlePrepareView:toLadderChampDef()
	local mapConfig = self._args.mapConfig
	local enterType = mapConfig.enterType
	if enterType == 1 then
		self.uiTypeCtr:setSelectedPage("defandConfig")
	else
		self.uiTypeCtr:setSelectedPage("WorldArena")
	end
	self.playerSeatLatout:getController("configType"):setSelectedPage("defandConfig")
	self.playerSeatLatout:getChildAutoType("swichMenu"):setVisible(false);
end

-- 跨服天梯赛
function BattlePrepareView:toLadderDef()
	local mapConfig= self._args.mapConfig
	if mapConfig.configType==GameDef.BattleArrayType.SkyLadderDef then
		-- self:toDefandConfig(false)
		self.uiTypeCtr:setSelectedPage("defandConfig")
	else
		self.uiTypeCtr:setSelectedPage("attackConfig")
	end
	-- self.playerSeatLatout:getController("configType"):setSelectedPage("defandConfig")
	self.playerSeatLatout:getChildAutoType("swichMenu"):setVisible(false);
end




--跨服竞技场
function BattlePrepareView:toWorldArena()
	self.uiTypeCtr:setSelectedPage("WorldArena")
end

--秘武
function BattlePrepareView:toSecretWeaponBattleView()
	local mapConfig= self._args.mapConfig
	printTable(31,"qqqqqqqqqqqqqqqqqqq",mapConfig)
	if not mapConfig then
		return
	end
	local fightId= mapConfig.fightID
	local playerId= mapConfig.playerId
	local gamePlay= mapConfig.configType
	local index= mapConfig.index
	SecretWeaponsModel:GodArmsGetBattleGodArms(fightId,playerId,gamePlay,index)
	--ViewManager.open("SecretWeaponAddTopView")
	self:createComponentByPageName("SecretWeaponAddTopView")
end


-- 精灵
function BattlePrepareView:toElvesView()
	local mapConfig  = self._args.mapConfig
	if not mapConfig then return end
	local playerId	 = mapConfig.playerId
	local configType = mapConfig.configType
	local serverId 	= mapConfig.serverId or LoginModel:getUnitServerId()

	ModelManager.ElvesSystemModel:getMyElvesBattleInfo(configType)
	ModelManager.ElvesSystemModel:getOtherElvesBattleInfo(playerId,configType)
	ModelManager.ElvesSystemModel:setOtherElvesPrepareInfo(playerId,configType,serverId)
	ModelManager.ElvesSystemModel.battlePrepareIsShow = true
	self:createComponentByPageName("ElvesAddTopView")
end


--跨服真人PK
function BattlePrepareView:toCrossArenaPVPView()
	local mapConfig= self._args.mapConfig
	self:createComponentByPageName("CrossArenaPVPBattleView")

	if mapConfig.configType==GameDef.BattleArrayType.CrossArenaDefOne then
		self:toDefandConfig(false)
		self.uiTypeCtr:setSelectedPage("defandConfig2")
	else
		self.uiTypeCtr:setSelectedPage("attackConfig")
	end
	
	self.playerSubList:setVisible(false)
	self.enemySubList:setVisible(false)

	self.CrossPVPOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem = ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1
				end
			end
			for i = 1, 6 do
				local seat = ModelManager.BattleModel.__seatInfos[i]
				if (not seat.uuid) then
					seatItem = seat
					break
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax)
				return
			end
		end

		local hasPut = CrossArenaPVPModel:checkHeroTypeInTeam(heroInfo.code)
		if hasPut then
			RollTips.show(Desc["CrossPVPBattleDesc"..hasPut])
			return
		end
		CrossArenaPVPModel:setHeroToTeam(seatItem.seatId,heroInfo)
		self:putoTable(seatItem,heroInfo,true)
	end

	-- 英雄下阵
	self.CrossPVPOutTable = function (uuid, seatId)
		if (not seatId) then return end
		local seatItem = ModelManager.BattleModel:getSeatById(seatId)
		seatItem:resetItem()
		CrossArenaPVPModel:setHeroToTeam(seatItem.seatId,nil,uuid)
		self:setMaskOnLock()
	end

	-- 英雄选择遮罩
	self.CrossPVPSetMask = function ()
		for k, heroCell in pairs(self.HeroCells) do
			local stateCtrl = heroCell.view:getController("state")
			local teamCtrl = heroCell.view:getController("crossTem")
			heroCell.view:setGrayed(false)
			stateCtrl:setSelectedPage("out")
			teamCtrl:setSelectedIndex(1)
			heroCell.view:getChildAutoType("n72"):setVisible(false)
			heroCell.view:getChildAutoType("n72"):setScale(1.2,1.2)
			local teamIdx = CrossArenaPVPModel:checkHeroInTeam(heroCell.uuid)
			if teamIdx then
				heroCell.view:getChildAutoType("n72"):setVisible(true)
				--teamCtrl:setSelectedIndex(teamIdx)
				stateCtrl:setSelectedPage("on")
				heroCell.view:getChildAutoType("n72"):setURL("UI/crossArean/"..teamIdx..".png")
			elseif CrossArenaPVPModel:checkHeroTypeInTeam(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			elseif ModelManager.BattleModel:checkPut(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			end
		end
	end
end

--阵营试炼
function BattlePrepareView:toTrailView()
	self:createComponentByPageName("TrialActivityBattleView")

	local taaa = ModelManager.TacticalModel:getSelfHeroList()

	self.playerSubList:setVisible(false)
	self.enemySubList:setVisible(false)

	-- 英雄上阵
	self.TrialOnClick = function(heroInfo,seatId)

		Super.checkTable(self,heroInfo,seatId)
		Dispatcher.dispatchEvent("trialActivity_updateArry")
	end

	-- 英雄下阵
	self.TrialOutTable = function (uuid, seatId,carInfo)

		if seatId then
			Super.outToTable(self, uuid, seatId);
		end
		Dispatcher.dispatchEvent("trialActivity_updateArry")
	end

	-- -- 英雄初始阵容
	-- self.TrialSetMask = function (carInfo)
	-- 	Super.setMaskOnLock(self);
	-- 	--if 
	-- 	print(33,"TrialSetMask")
	-- end
end

--天域试炼
function BattlePrepareView:toCrossPVPView()
	local mapConfig= self._args.mapConfig
	self:createComponentByPageName("CrossPVPBattleView")

	if mapConfig.configType==GameDef.BattleArrayType.HorizonPvpDefOne then
		self:toDefandConfig(false)
	end

	self.playerSubList:setVisible(false)
	self.enemySubList:setVisible(false)

	self.CrossPVPOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem = ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1
				end
			end
			for i = 1, 6 do
				local seat = ModelManager.BattleModel.__seatInfos[i]
				if (not seat.uuid) then
					seatItem = seat
					break
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax)
				return
			end
		end

		local hasPut = CrossPVPModel:checkHeroTypeInTeam(heroInfo.code)
		if hasPut then
			RollTips.show(Desc["CrossPVPBattleDesc"..hasPut])
			return
		end
		CrossPVPModel:setHeroToTeam(seatItem.seatId,heroInfo)
		self:putoTable(seatItem,heroInfo,true)
	end

	-- 英雄下阵
	self.CrossPVPOutTable = function (uuid, seatId)
		if (not seatId) then return end
		local seatItem = ModelManager.BattleModel:getSeatById(seatId)
		seatItem:resetItem()
		CrossPVPModel:setHeroToTeam(seatItem.seatId,nil,uuid)
		self:setMaskOnLock()
	end

	-- 英雄选择遮罩
	self.CrossPVPSetMask = function ()
		for k, heroCell in pairs(self.HeroCells) do
			local stateCtrl = heroCell.view:getController("state")
			local teamCtrl = heroCell.view:getController("crossTem")
			heroCell.view:setGrayed(false)
			stateCtrl:setSelectedPage("out")
			teamCtrl:setSelectedIndex(0)
			local teamIdx = CrossPVPModel:checkHeroInTeam(heroCell.uuid)
			if teamIdx then
				teamCtrl:setSelectedIndex(teamIdx)
				stateCtrl:setSelectedPage("on")
			elseif CrossPVPModel:checkHeroTypeInTeam(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			end
		end
	end
end


--巅峰竞技
function BattlePrepareView:toStridePVPView()
	local mapConfig= self._args.mapConfig
	self:createComponentByPageName("StrideBattleView")

	if mapConfig.configType==GameDef.BattleArrayType.TopArenaAckOne then
		self:toDefandConfig(false)
	end

	self.playerSubList:setVisible(false)
	self.enemySubList:setVisible(false)
    
    
	self.CrossPVPOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem = ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1
				end
			end
			for i = 1, 6 do
				local seat = ModelManager.BattleModel.__seatInfos[i]
				if (not seat.uuid) then
					seatItem = seat
					break
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax)
				return
			end
		end

		local hasPut = StrideServerModel:checkHeroTypeInTeam(heroInfo.code)
		if hasPut then
			RollTips.show(Desc["CrossPVPBattleDesc"..hasPut])
			return
		end
		StrideServerModel:setHeroToTeam(seatItem.seatId,heroInfo)
		self:putoTable(seatItem,heroInfo,true)
	end

	-- 英雄下阵
	self.CrossPVPOutTable = function (uuid, seatId)
		if (not seatId) then return end
		local seatItem = ModelManager.BattleModel:getSeatById(seatId)
		seatItem:resetItem()
		StrideServerModel:setHeroToTeam(seatItem.seatId,nil,uuid)
		self:setMaskOnLock()
	end



	-- 英雄选择遮罩
	self.CrossPVPSetMask = function ()
		for k, heroCell in pairs(self.HeroCells) do
			local stateCtrl = heroCell.view:getController("state")
			local teamCtrl = heroCell.view:getController("crossTem")
			heroCell.view:setGrayed(false)
			stateCtrl:setSelectedPage("out")
			teamCtrl:setSelectedIndex(0)
			local teamIdx = StrideServerModel:checkHeroInTeam(heroCell.uuid)
			if teamIdx then
				teamCtrl:setSelectedIndex(teamIdx)
				stateCtrl:setSelectedPage("on")
			elseif StrideServerModel:checkHeroTypeInTeam(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			end
		end
	end
end


--超凡段位赛
function BattlePrepareView:toExtraordinaryPvp()
	local mapConfig= self._args.mapConfig
	self:createComponentByPageName("ExtraordinaryPVPBattleView")
	if mapConfig.configType==GameDef.BattleArrayType.CrossSuperMundaneDefFirst then
		self:toDefandConfig(false)
		self.uiTypeCtr:setSelectedPage("defandConfig2")
	else
		self.uiTypeCtr:setSelectedPage("attackConfig")
	end
	
	self.playerSubList:setVisible(false)
	self.enemySubList:setVisible(false)

	self.ExtraordinarylevelOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem = ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1
				end
			end
			for i = 1, 6 do
				local seat = ModelManager.BattleModel.__seatInfos[i]
				if (not seat.uuid) then
					seatItem = seat
					break
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax)
				return
			end
		end

		local hasPut = ExtraordinarylevelPvPModel:checkHeroTypeInTeam(heroInfo.code)
		if hasPut then
			RollTips.show(Desc["CrossPVPBattleDesc"..hasPut])
			return
		end
		ExtraordinarylevelPvPModel:setHeroToTeam(seatItem.seatId,heroInfo)
		self:putoTable(seatItem,heroInfo,true)
	end

	-- 英雄下阵
	self.ExtraordinarylevelOutTable = function (uuid, seatId)
		if (not seatId) then return end
		local seatItem = ModelManager.BattleModel:getSeatById(seatId)
		seatItem:resetItem()
		ExtraordinarylevelPvPModel:setHeroToTeam(seatItem.seatId,nil,uuid)
		self:setMaskOnLock()
	end

	-- 英雄选择遮罩
	self.ExtraordinarylevelMask = function ()
		for k, heroCell in pairs(self.HeroCells) do
			local stateCtrl = heroCell.view:getController("state")
			local teamCtrl = heroCell.view:getController("crossTem")
			heroCell.view:setGrayed(false)
			stateCtrl:setSelectedPage("out")
			teamCtrl:setSelectedIndex(1)
			heroCell.view:getChildAutoType("n72"):setVisible(false)
			heroCell.view:getChildAutoType("n72"):setScale(1.2,1.2)
			local teamIdx = ExtraordinarylevelPvPModel:checkHeroInTeam(heroCell.uuid)
			if teamIdx then
				heroCell.view:getChildAutoType("n72"):setVisible(true)
				--teamCtrl:setSelectedIndex(teamIdx)
				stateCtrl:setSelectedPage("on")
				heroCell.view:getChildAutoType("n72"):setURL("UI/crossArean/"..teamIdx..".png")
			elseif ExtraordinarylevelPvPModel:checkHeroTypeInTeam(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			elseif ModelManager.BattleModel:checkPut(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			end
		end
	end

end


--高阶竞技场
function BattlePrepareView:toHigherPvp()
	local mapConfig= self._args.mapConfig
	self:createComponentByPageName("AddHPvPPrebattleView")
	
	if mapConfig.configType==GameDef.BattleArrayType.HigherPvpDefOne or WorldHighPvpModel:isWoroldHighPvpArrayType(mapConfig.configType)  then--or WorldHighPvpModel:isWoroldHighPvpArrayType(mapConfig.configType)
		self:toDefandConfig(false)--高阶晋级场防守
	end
	
	self.playerSubList:setVisible(false);
	self.enemySubList:setVisible(false);
	local showTop = HigherPvPModel:judgType(mapConfig.configType) or WorldHighPvpModel:isWoroldHighPvpArrayType(mapConfig.configType)
	self.view:getChildAutoType("top"):setVisible(showTop);

	--高阶竞技场需要重写上阵方法
	self.HigherPvpOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem=ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0;
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1;
				end
			end
			-- 空位查找
			if (seatCount < 1 and (mapConfig.configType==GameDef.BattleArrayType.HigherPvpDefOne 
					or mapConfig.configType==GameDef.BattleArrayType.HigherPvpAckOne
					or mapConfig.configType == GameDef.BattleArrayType.WorldSkyPvpDefOne)) then
				seatItem=ModelManager.BattleModel:getSeatById(12);
			elseif (seatCount < 3 and (mapConfig.configType==GameDef.BattleArrayType.HigherPvpAckThree 
					or mapConfig.configType==GameDef.BattleArrayType.HigherPvpDefThree
					or mapConfig.configType == GameDef.BattleArrayType.WorldSkyPvpDefThree)) then
				for i = 1, 6 do
					local seat = ModelManager.BattleModel.__seatInfos[i];
					if (not seat.uuid) then
						seatItem = seat;
						break;
					end
				end
			elseif (seatCount < 6 and (mapConfig.configType==GameDef.BattleArrayType.HigherPvpDefSix 
					or mapConfig.configType==GameDef.BattleArrayType.HigherPvpAckSix
					or mapConfig.configType == GameDef.BattleArrayType.WorldSkyPvpDefSix)) then
				for i = 1, 6 do
					local seat = ModelManager.BattleModel.__seatInfos[i];
					if (not seat.uuid) then
						seatItem = seat;
						break;
					end
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax);
				return;
			end
		end

		-- 是否已在其他队伍上阵
		local hasPut=ModelManager.HigherPvPModel:checkHeroInTeam(heroInfo.code)
		if hasPut then
			RollTips.show(Desc["HigherPvP_HeroInTeam"..hasPut]);
			return
		end
		HigherPvPModel: setHeroToTeam(seatItem.seatId, heroInfo);
		self:putoTable(seatItem,heroInfo,true)
	end

	-- 英雄下阵
	self.HigherPvpOutTable = function (uuid, seatId)
		if (not seatId) then return end;
		local seatItem=ModelManager.BattleModel:getSeatById(seatId)
		seatItem:resetItem()
		HigherPvPModel: setHeroToTeam(seatItem.seatId, nil, CardLibModel:getHeroByUid(uuid));
		self:setMaskOnLock()
	end

	-- 英雄选择遮罩
	self.HigherPvpSetMask = function ()
		for k, heroCell in pairs(self.HeroCells) do
			local  stateCtrl=heroCell.view:getController("state")
			local teamCtrl = heroCell.view:getController("team");
			heroCell.view:setGrayed(false)
			stateCtrl:setSelectedPage("out")
			teamCtrl:setSelectedIndex(0);
			local teamIdx = HigherPvPModel:checkHeroInTeamByUid(heroCell.uuid)
			if teamIdx then
				teamCtrl:setSelectedIndex(teamIdx);
				stateCtrl:setSelectedPage("on")
			elseif HigherPvPModel:checkHeroInTeam(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			end
		end
	end
end


--高阶竞技场的阵营切换
function BattlePrepareView:battle_highPvpChangeTeamType(_,configType)
	--print(0866,"队伍切换",configType)
	-- Dispatcher.dispatchEvent(EventType.battle_array,self._args.mapConfig.configType)--切换阵容前保存阵容信息
	self:changeScenes(configType)
end
--跨服竞技场切换
function BattlePrepareView:battle_CrossChangeTeamType(_,configType)
	self:changeScenes(configType)
end

--超凡段位赛切换
function BattlePrepareView:extraordinarylevelPvP_zhenrongUp(_,configType)
	self:changeScenes(configType)
end

--巅峰竞技赛
function BattlePrepareView:battle_StrideChangeTeamType(_,configType)
	self:changeScenes(configType)
end

--跨服竞技场刷新
function BattlePrepareView:battle_CrossPVPrefrush(_,configType)
	local arrayData = CrossPVPModel:getArrayByType(configType)
	self:setPlayerInfos(arrayData)
	self:setMaskOnLock()
end

function BattlePrepareView:battle_GuildLegendsChangeTeamType(_,configType)
	self:changeScenes(configType)
end 

--巅峰竞技赛刷新
function BattlePrepareView:battle_StridePVPrefrush(_,configType)
	local arrayData = StrideServerModel:getArrayByType(configType)
	self:setPlayerInfos(arrayData)
	self:setMaskOnLock()
end

-- 公会联赛传奇赛
function BattlePrepareView:toGuildLegends()
	local mapConfig= self._args.mapConfig
	self:createComponentByPageName("GLOLBattlePreTopView")
	self:toDefandConfig(false)--防守

	-- self.playerSubList:setVisible(false);
	-- self.enemySubList:setVisible(false);
	-- local showTop = HigherPvPModel:judgType(mapConfig.configType) or WorldHighPvpModel:isWoroldHighPvpArrayType(mapConfig.configType)
	-- self.view:getChildAutoType("top"):setVisible(showTop);

	--高阶竞技场需要重写上阵方法
	self.GuildLegendsOnClick = function(heroInfo,seatId)
		local seatItem=false
		if seatId then
			seatItem=ModelManager.BattleModel:getSeatInfos()[seatId]
		else
			local seatCount = 0;
			for _, seat in ipairs(BattleModel.__seatInfos) do
				if (not seat.isEmpty) then
					seatCount = seatCount + 1;
				end
			end
			-- 空位查找
			if (seatCount < 8) then
				for i = 1, 8 do
					local seat = ModelManager.BattleModel.__seatInfos[i];
					if (not seat.uuid) then
						seatItem = seat;
						break;
					end
				end
			end
			if (not seatItem or not seatItem.isEmpty) then
				RollTips.show(Desc.HigherPvP_teamMax);
				return;
			end
		end

		-- 是否已在其他队伍上阵
		local hasPut=ModelManager.GuildLeagueOfLegendsModel:checkHeroInTeam(heroInfo.code)
		if hasPut then
			RollTips.show(Desc["GLOL_HeroInTeam"..hasPut]);
			return
		end
		GuildLeagueOfLegendsModel:setHeroToTeam(seatItem.seatId, heroInfo);
		self:putoTable(seatItem,heroInfo,true)
	end

	-- 英雄下阵
	self.GuildLegendsOutTable = function (uuid, seatId)
		if (not seatId) then return end;
		local seatItem=ModelManager.BattleModel:getSeatById(seatId)
		seatItem:resetItem()
		GuildLeagueOfLegendsModel:setHeroToTeam(seatItem.seatId, nil, CardLibModel:getHeroByUid(uuid));
		self:setMaskOnLock()
	end

	-- 英雄选择遮罩
	self.GuildLegendsSetMask = function ()
		for k, heroCell in pairs(self.HeroCells) do
			local  stateCtrl=heroCell.view:getController("state")
			local teamCtrl = heroCell.view:getController("guildLeague");
			heroCell.view:setGrayed(false)
			stateCtrl:setSelectedPage("out")
			teamCtrl:setSelectedIndex(0);
			local teamIdx = GuildLeagueOfLegendsModel:checkHeroInTeamByUid(heroCell.uuid)
			if teamIdx then
				teamCtrl:setSelectedIndex(teamIdx);
				stateCtrl:setSelectedPage("on")
			elseif GuildLeagueOfLegendsModel:checkHeroInTeam(heroCell.code) then
				stateCtrl:setSelectedPage("lock")
				heroCell.view:setGrayed(true)
			end
		end
	end
end

-- 虚空幻境
function BattlePrepareView:toVoidland()
	local mapConfig= self._args.mapConfig
	
	if (mapConfig.configType == GameDef.BattleArrayType.DreamLandMultiple) then
		self.voidlandOnClick = false;
		self.voidlandOutTable = false;
		self.voidlandScenes = false;
		self.voidlandSetMask = false;
		-- self.voidlandSeatChange = false;
	else -- 单人模式
		self:createComponentByPageName("AddVoidlandSingleView")
		self.playerSubList:setVisible(false);
		self.enemySubList:setVisible(false);
		-- 多余位置屏蔽
		for _, seat in ipairs(BattleModel.__seatInfos) do
			seat.view:setVisible(seat.seatId == 12);
		end
		-- 上阵
		self.voidlandOnClick = function(heroInfo,seatId)
			local seatItem=false
			if seatId then
				seatItem=ModelManager.BattleModel:getSeatInfos()[seatId]
			else
				local seatCount = 0;
				for _, seat in ipairs(BattleModel.__seatInfos) do
					if (not seat.isEmpty) then
						seatCount = seatCount + 1;
					end
				end
				-- 空位查找
				if (seatCount < 1 and mapConfig.configType==GameDef.BattleArrayType.DreamLandSingle) then
					seatItem=ModelManager.BattleModel:getSeatById(12);
				end
			end
	
			-- 是否已在其他队伍上阵
			local hasPut= VoidlandModel:hasSameHeroInSingleList(heroInfo)
			if hasPut then
				RollTips.show(Desc.battle_DetailsStr1);
				return
			end
			local battleFlag = VoidlandModel:addSingleListArray(heroInfo)
			if (battleFlag and seatItem and seatItem.isEmpty) then
				self:putoTable(seatItem,heroInfo,true)
			elseif (not battleFlag) then
				RollTips.show("已达上阵上限");
			end
		end

		-- 英雄下阵
		self.voidlandOutTable = function (uuid, seatId)
			if (seatId) then
				local seatItem=ModelManager.BattleModel:getSeatById(seatId)
				seatItem:resetItem()
			end
			VoidlandModel:removeSingleListArray(uuid);
		end

		self.voidlandScenes = function()
			local seat = BattleModel:getSeatById(12);
			for _, data in pairs(VoidlandModel.singleList) do
				local uuid = data and data.uuid or "";
				local heroInfo = BattleModel:getHeroByUid(uuid);
				if (not heroInfo or heroInfo.hp and heroInfo.hp <= 0) then
					VoidlandModel:removeSingleListArray(uuid);
				end
			end
			if (VoidlandModel.singleList and VoidlandModel.singleList[1]) then
				local heroInfo = BattleModel:getHeroByUid(VoidlandModel.singleList[1].uuid);
				seat:resetItem();
				seat:setHeroInfo(heroInfo);
			else
				seat:resetItem();
			end
		end

		-- 英雄选择遮罩
		self.voidlandSetMask = function ()
			for k, heroCell in pairs(self.HeroCells) do
				local stateCtrl = heroCell.view:getController("state")
				local grayCtrl = heroCell.view:getController("grayCtrl");
				local voidlandCtrl = heroCell.view:getController("voidland");
				local data = BattleModel:getHeroByUid(heroCell.uuid);
				local checkMark = heroCell.view:getChildAutoType("checkMark");
				if (data.hp and data.hp <= 0) then
					grayCtrl:setSelectedIndex(1);
					stateCtrl:setSelectedPage("out")
					voidlandCtrl:setSelectedIndex(0);
				else
					grayCtrl:setSelectedIndex(0);
					local teamIdx = VoidlandModel:isInSingleList(heroCell.uuid)
					if teamIdx then
						teamIdx = teamIdx > 1 and 2 or 1;
						stateCtrl:setSelectedPage("on")
						checkMark:setVisible(false);
						voidlandCtrl:setSelectedIndex(teamIdx);
					elseif VoidlandModel:hasSameHeroInSingleList(heroCell) then
						stateCtrl:setSelectedPage("lock")
						voidlandCtrl:setSelectedIndex(0);
					else
						stateCtrl:setSelectedPage("out")
						voidlandCtrl:setSelectedIndex(0);
					end
				end
			end
		end
	end

	self.voidlandBattleBegin = function()
		local battleCount = 0;
		local maxCount = 0;
		if (mapConfig.configType == GameDef.BattleArrayType.DreamLandSingle) then
			if (not VoidlandModel.singleList[1]) then
				RollTips.show(Desc.Voidland_noFirst);
				return;
			end
			battleCount = VoidlandModel:getSingleListCount();
			maxCount = 3;
		else
			battleCount = BattleModel:getBattleHeroNum();
			maxCount = 6;
			maxCount = ModuleUtil.getModuleOpenTips(ModuleId.Alternate_Front.id) and maxCount or maxCount+1;
			maxCount = ModuleUtil.getModuleOpenTips(ModuleId.Alternate_Back.id) and maxCount or maxCount+1;
		end

		if (battleCount < maxCount) then
			local info = {
				text=string.format(Desc.Voidland_notMax, battleCount, maxCount),
				type="yes_no",
				noText="调整阵容",
				yesText="开始挑战",
			}
			info.onYes = function()
				Super.beginBattle(self);
			end
			Alert.show(info);
		else
			Super.beginBattle(self);
		end
	end
end

--远征玩法
function BattlePrepareView:toEndlessRoad()
   local putCount=0
   for i, hero in ipairs(self.handCardInfos) do		
		if putCount>2 then
			return 
		end
		local hasPut=BattleModel:checkPut(hero.code)
		if not hasPut and hero.hp>0 then
			local seat=BattleModel:getLateSeat()
			self:putoTable(seat,hero)
			putCount=putCount+1
		end
   end
end

function BattlePrepareView:Voidland_upSingleList()
	self:setMaskOnLock();
end

function BattlePrepareView:changeScenes(configType,fightID)
	local mapConfig = self._args.mapConfig
	mapConfig.configType=configType
	BattleModel:setCureOpenType(mapConfig.configType)
	if fightID then
		mapConfig.fightID=fightID
		local mapData=BattleConfiger.getMapByID(mapConfig.fightID)
		self.bgIcon:setIcon(PathConfiger.getMapBg(mapData.map))
	end
	BattleModel:setBattleConfig(mapConfig)
	self:setBattleScenes(mapConfig)
	self._args.mapConfig=mapConfig
end

--设置地方上阵信息
function BattlePrepareView:setBattleScenes(mapConfig)
	local type = mapConfig.configType
	local function finished(data)
		if (HigherPvPModel:isHigherPvpType(type)) then
			local arrayData = HigherPvPModel:getArrayByType(type);
			self:setPlayerInfos(arrayData)
			local allData=ModelManager.BattleModel:getEnemyArrayInfo()
			if self.uiTypeCtr:getSelectedPage()~="defandConfig"  then
				self:setEnemyInfos(allData)--设置敌方数据
			end
			self._hadInit=true
		elseif (CrossLaddersModel:isCrossLaddersPvpType(type)) then
				self:updateDefaultCamp()---设置手牌
				local allData=ModelManager.BattleModel:getEnemyArrayInfo()
				self:setPlayerInfos(allData)
				local arrayData=CrossLaddersModel:getArrayByType(type);
				if self.uiTypeCtr:getSelectedPage()~="defandConfig"  then
					self:setEnemyInfos(arrayData)--设置敌方数据
				end
				self._hadInit=true
		elseif CrossLaddersChampModel:isCrossLaddersChampType(type)  then 	-- 跨服天梯冠军赛
				local enterType = mapConfig.enterType
				self:updateDefaultCamp()---设置手牌
				local allData=ModelManager.BattleModel:getEnemyArrayInfo()
				self:setPlayerInfos(allData)
				if enterType == 2 then
					local arrayData = CrossLaddersChampModel:getArrayByType(type)
					if self.uiTypeCtr:getSelectedPage()~="defandConfig"  then
						self:setEnemyInfos(arrayData)--设置敌方数据
					end
				end
				self._hadInit=true
		elseif GuildLeagueOfLegendsModel:isGuildLegendsArrayType(type) then
			local arrayData = GuildLeagueOfLegendsModel:getArrayByType(type);
			self:setPlayerInfos(arrayData)
			self._hadInit=true
		elseif WorldHighPvpModel:isWoroldHighPvpArrayType(type) then -- 世界擂台赛-天境赛
			local allData=HigherPvPModel:getArrayByType(type);
			self:setPlayerInfos(allData)
			-- 敌人数据
			local enemyArr = WorldHighPvpModel:getGuessEnemyInfoToBattle(type)
			if enemyArr then
				self:setEnemyInfos(enemyArr)--设置敌方数据
			end
			self._hadInit=true
		elseif type== GameDef.BattleArrayType.WorldArena then -- 世界擂台赛
			self:updateDefaultCamp()
			local arryData=ModelManager.BattleModel:getEnemyArrayInfo()
			self:setPlayerInfos(arryData)--设置我方数据
			local rightArr = WorldChallengeModel:getOpponentInfo()
			if rightArr then
				local enemyArr=	WorldChallengeModel:getGuessEnemyInfoToBattle(rightArr,type)--后端不发需要自己构造很逗
				self:setEnemyInfos(enemyArr)--设置敌方数据
			end
			self._hadInit=true
		elseif CrossPVPModel:isCrossPVPType(type) then
--			CrossPVPModel:setSeverHeroTemp(data,type)
			local arrayData = CrossPVPModel:getArrayByType(type)
			self:setPlayerInfos(arrayData)
			local allData = ModelManager.BattleModel:getEnemyArrayInfo()
			if mapConfig.playerId and mapConfig.playerId <= 0 then
				allData = CrossPVPModel:getAIEnemyInfos(mapConfig.playerId,type - 3010)
			end
--			local combat = 0
--			for key,value in pairs(allData.heroInfos) do--覆盖服务器战力
--				local config = DynamicConfigData.t_HorizonPvpTotems[value.code]
--				if config then
--					data.heroInfos[key].combat = config.combat or 0
--					combat = combat + config.combat
--				end
--			end
--			allData.combat = combat
			if self.uiTypeCtr:getSelectedPage() ~= "defandConfig" then
				self:setEnemyInfos(allData)--设置敌方数据
			end
			self._hadInit = true
		elseif type== GameDef.BattleArrayType.Trail then -- 阵营试炼
				self:updateDefaultCamp()
				local arryData=ModelManager.BattleModel:getEnemyArrayInfo()
				self:setPlayerInfos(arryData)--设置我方数据
				if mapConfig.playerId and mapConfig.playerId <= 0 then
					arryData = TrialActivityModel:getAIEnemyInfos(mapConfig.playerId,type - 4017)
				end
				self:setEnemyInfos(arryData)--设置敌方数据
				self._hadInit = true
				Dispatcher.dispatchEvent("trialActivity_updateArry")
		elseif CrossArenaPVPModel:isCrossPVPType(type) then
			local arrayData = CrossArenaPVPModel:getArrayByType(type)
			self:setPlayerInfos(arrayData)
			local allData = ModelManager.BattleModel:getEnemyArrayInfo()
			if mapConfig.playerId and mapConfig.playerId <= 0 then
				allData = CrossArenaPVPModel:getAIEnemyInfos(mapConfig.playerId,type - 3030)
			end
			local isHide = false
			if allData and allData.heroInfos and #allData.heroInfos > 0 then
				for key,value in pairs(allData.heroInfos) do
					if value.isHide then
						isHide = true
						break
					end
				end
			end
			if self.uiTypeCtr:getSelectedPage() ~= "defandConfig2" then
				if isHide then
					--RollTips.show(Desc.CrossArenaPVPDesc2)
					allData.heroInfos = {}
					self:setEnemyInfos(allData)--设置敌方数据
					self.enemyFightCamp:setText("???")
					Dispatcher.dispatchEvent("crossArena_hideTeam",true)
				else
					Dispatcher.dispatchEvent("crossArena_hideTeam",false)
					self:setEnemyInfos(allData)--设置敌方数据
				end
			end
			self._hadInit = true
		elseif ExtraordinarylevelPvPModel:isExtraordinaryPVPType(type) then--超凡段位赛
			-- self:updateDefaultCamp()
			local arrayData = ExtraordinarylevelPvPModel:getArrayByType(type)
			self:setPlayerInfos(arrayData)
			local allData = ModelManager.BattleModel:getEnemyArrayInfo()
			if mapConfig.playerId and mapConfig.playerId <= 0 then
				allData = ExtraordinarylevelPvPModel:getAIEnemyInfos(mapConfig.playerId,type - 3040)
			end
			local isHide = false
			if allData and allData.heroInfos and #allData.heroInfos > 0 then
				for key,value in pairs(allData.heroInfos) do
					if value.isHide then
						isHide = true
						break
					end
				end
			end
			if self.uiTypeCtr:getSelectedPage() ~= "defandConfig2" then
				-- if isHide then
				-- 	--RollTips.show(Desc.CrossArenaPVPDesc2)
				-- 	allData.heroInfos = {}
				-- 	self:setEnemyInfos(allData)--设置敌方数据
				-- 	self.enemyFightCamp:setText("???")
				-- else
					self:setEnemyInfos(allData or {})--设置敌方数据
				--end
			end
			self._hadInit = true
		elseif StrideServerModel:isCrossPVPType(type) then --巅峰竞技赛
			local arrayData = StrideServerModel:getArrayByType(type)
			self:setPlayerInfos(arrayData)
			local allData = ModelManager.BattleModel:getEnemyArrayInfo()
			if mapConfig.playerId and mapConfig.playerId <= 0 then
				allData = StrideServerModel:getAIEnemyInfos(mapConfig.playerId,type - 3030)
			end
			local isHide = false
			if allData and allData.heroInfos and #allData.heroInfos > 0 then
				for key,value in pairs(allData.heroInfos) do
					if value.isHide then
						isHide = true
						break
					end
				end
			end
			if self.uiTypeCtr:getSelectedPage() ~= "defandConfig" then
				if isHide then
					--RollTips.show(Desc.CrossArenaPVPDesc2)
					allData.heroInfos = {}
					self:setEnemyInfos(allData)--设置敌方数据
					self.enemyFightCamp:setText("???")
					Dispatcher.dispatchEvent("crossArena_hideTeam",true)
				else
					Dispatcher.dispatchEvent("crossArena_hideTeam",false)
					self:setEnemyInfos(allData)--设置敌方数据
				end
			end
			self._hadInit = true
		else
			self:updateDefaultCamp()---设置手牌
			self:updateScenes()--通用方法显示自己和对手阵容
			if self.voidlandScenes then
				self:voidlandScenes();
			end
			if type==GameDef.BattleArrayType.EndlessRoad then
				self:toEndlessRoad();--远征玩法自动上阵最强的前三英雄
			elseif type== GameDef.BattleArrayType.Trail then -- 阵营试炼
				Dispatcher.dispatchEvent("trialActivity_updateArry")
			end
		end
		--增加地方阵法显示
		TacticalModel:setPreOtherTacData(data.tactical)
	end
	
	BattleModel:requestMapInfo(mapConfig,finished)
	
end

function BattlePrepareView:updateDefaultCamp()
	local idx = 0
	if self._args.mapConfig.activeType ~= nil  then
		local towerTypeData =  DynamicConfigData.t_towerType[self._args.mapConfig.activeType]
		idx = towerTypeData.category
		--Desc.pata_floor
	end

	if self._args.mapConfig.category then
		idx=self._args.mapConfig.category
	end

	--print(1 , "enter : " , idx)
	if self._args.mapConfig.categoryData then
		self:setCardsByCategory(self._args.mapConfig.categoryData)
	else
		self:setCardsByCategory(idx)
	end
	
end


function BattlePrepareView:onCkickCgy(index)
	-- printTable(8848,">>>>>>>>>>>>>>>",self._args.mapConfig.categoryData)
	local categoryData = index 

	if self._args.mapConfig.activeType ~= nil  then
		local towerTypeData=  DynamicConfigData.t_towerType[self._args.mapConfig.activeType]
		local have=towerTypeData.category[1]==0
		if towerTypeData.category[1]~=0 then
			categoryData=towerTypeData.category
		end
		for k, category in pairs(towerTypeData.category) do
			if category==index then
				have=true
				break;
			end
		end
		if have==false then
			RollTips.show( "该玩法无法筛选种族" )
			self:setSelectedIndexs(towerTypeData.category)
			return
		end
	end
	if  self._args.mapConfig.category then--远征参数
		RollTips.show( "该玩法无法筛选种族" )
		self:setSelectedIndexs(self._args.mapConfig.category)
		return
	end

	--- 无尽试炼的判断
	if self._args.mapConfig.categoryData ~= nil then
		local have = false
		for k,v in pairs(self._args.mapConfig.categoryData) do
			if index == v then
 				have = true
 				break
			end
		end

		if not have then
			RollTips.show( "该玩法无法筛选种族")
			self:setCardsByCategory(self._args.mapConfig.categoryData)
			return 
		end
	end
	self:setCardsByCategory(categoryData)
end


function BattlePrepareView:battle_enter()
    ViewManager.close("BattlePrepareView")
end

function BattlePrepareView: battle_canCel()
	ViewManager.close("BattlePrepareView")
	SpineMnange.clearPool()
end

function BattlePrepareView:_exit()
	Dispatcher.dispatchEvent(EventType.squadtomodify_change);
	BattleModel.rollOverFx=false
	Scheduler.scheduleNextFrame(function()
		Dispatcher.dispatchEvent(EventType.module_open_hint)
	end)
	
	if self.autoStartTimer then
		Scheduler.unschedule(self.autoStartTimer)
	end
end

return BattlePrepareView