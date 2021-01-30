---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local BattleController,Super = class("BattleController",Controller)
local BattleConfiger=require "Game.ConfigReaders.BattleConfiger"
local ArrayName = require "Game.Consts.ArrayName"
local ViewArrayType = require "Game.Consts.ViewArrayType"
--local battleData= require "Game.Modules.Battle.Cell.battleData"--暂时通过一个表的形式下发战报数据
--local BattleFunc=false
local playEditBattleFunc=false

function BattleController:ctor()
	self.BattleFunc={}
	self.BattleConfigs={}
	self.LastMapConfig=false
end


function BattleController:battle_begin(_,args)
	PHPUtil.reportStep(ReportStepType.FIRST_FIGHT_BEGIN)
	
	local arrayType = args.arrayType;
	-- 多个队伍的玩法
	if (HigherPvPModel:judgType(arrayType)) then
		arrayType = GameDef.BattleArrayType.HigherPvpAckOne;
	elseif (HigherPvPModel: isHigherPvpType(arrayType)) then
		arrayType = GameDef.BattleArrayType.HigherPvpDefOne;
	elseif (WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType)) then
		arrayType = GameDef.BattleArrayType.WorldSkyPvpDefOne;
	elseif CrossPVPModel:isAckArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.HorizonPvpAckOne;
	elseif CrossPVPModel:isDefArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.HorizonPvpDefOne;
	elseif CrossArenaPVPModel:isAckArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.CrossArenaAckOne;
	elseif CrossArenaPVPModel:isDefArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.CrossArenaDefOne;
	elseif ExtraordinarylevelPvPModel:isAckArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.CrossSuperMundaneAckFirst;
	elseif ExtraordinarylevelPvPModel:isDefArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.CrossSuperMundaneDefFirst;
	elseif GuildLeagueOfLegendsModel:isGuildLegendsArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.GuildLeagueOne;
	elseif StrideServerModel:isCrossPVPType(arrayType) then --巅峰竞技
		arrayType = GameDef.BattleArrayType.TopArenaAckOne;
	end

	FightManager.onBegin(arrayType)
	if self.BattleFunc[arrayType] then
		self.BattleFunc[arrayType]("begin")
	end
	--printTable(086,self.BattleFunc,args.arrayType)
end

function BattleController:battle_setBattleFunc(name,func,mapConfig)
	self.BattleFunc[mapConfig.configType]=func
	self.BattleConfigs[mapConfig.configType]=mapConfig
end


--打开备战界面
--所有调用战前配置的模块在这里处理下发请求 mapConfig 类型 {fightID=当前玩法的fightID,configType= GameDef.BattleArrayType}
function BattleController:battle_requestFunc(name,battleFunc,mapConfig)
	print(5656,"battle_requestFunc"..mapConfig.configType)
	BattleModel:setMapConfig(mapConfig.configType, mapConfig)
	self.LastMapConfig=mapConfig
	if FightManager.getRequestList(mapConfig.configType) then
		local topView = ViewManager.getLayerTopWindow(LayerDepth.Window,{})
		if topView and  topView.window._viewName == "BattleBeginView" then
			RollTips.show("请等待上一场战斗结束")
			return
		else
			FightManager.removeRequestList(mapConfig.configType)
		end
	end
	--if FightManager.haveFight(mapConfig.configType) then
		--FightManager.openFight(mapConfig.configType)
		--return
	--end
	self.BattleFunc[mapConfig.configType]=battleFunc
	self.BattleConfigs[mapConfig.configType]=mapConfig
	
	if mapConfig.activeType~=nil then
		local towerLayer = ModelManager.PataModel:getPataFloor(mapConfig.activeType)
		mapConfig.title=string.format(Desc.pata_floor,towerLayer)
	end
	if mapConfig.configType==GameDef.BattleArrayType.Chapters then
		mapConfig.title=string.format(Desc.pushmap_text2,mapConfig.chapterInfo.sidname)
	end
	if mapConfig.skipBattle or mapConfig.skipArray or mapConfig.configType==GameDef.BattleArrayType.PveStarTemple then
		if mapConfig.configType==GameDef.BattleArrayType.Chapters then
			FightManager.addRequestList(mapConfig.configType) --推图快速点击做相应处理
		end
		BattleModel:setBattleConfig(mapConfig)
		Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType=mapConfig.configType})
	
	else
		local viewNode=ViewManager.getView("BattlePrepareView")
		if viewNode and viewNode.view:isVisible() then
			local arrayType=viewNode._args.mapConfig.configType
			Dispatcher.dispatchEvent(EventType.battle_canCel,{arrayType=arrayType})
		end
		BattleModel:setCureOpenType(mapConfig.configType)
		ViewManager.open("BattlePrepareView",{mapConfig=mapConfig})
	end

end


--保存阵容
function BattleController:battle_array(name,arrayType)
	if (HigherPvPModel:isHigherPvpType(arrayType) or WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType)) then
		HigherPvPModel:saveTeamInfo(arrayType, function ()
			Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType=arrayType})
		end);
	elseif CrossPVPModel:isCrossPVPType(arrayType) then
		CrossPVPModel:saveTeamToSever(function ()
			local state =  CrossPVPModel:getCurPVPType() == 0--进攻
			local arrayType = state and GameDef.BattleArrayType.HorizonPvpAckOne or GameDef.BattleArrayType.HorizonPvpDefOne
			Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType = arrayType})
		end)
	elseif CrossArenaPVPModel:isCrossPVPType(arrayType) then
		CrossArenaPVPModel:saveTeamToSever(function ()
			local state =  CrossArenaPVPModel:getCurPVPType() == 0--进攻
			local arrayType = state and GameDef.BattleArrayType.CrossArenaAckOne or GameDef.BattleArrayType.CrossArenaDefOne
			Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType = arrayType})
		end)
	elseif ExtraordinarylevelPvPModel:isCrossPVPType(arrayType) then
		ExtraordinarylevelPvPModel:saveTeamToSever(function ()
			local state =  ExtraordinarylevelPvPModel:getCurPVPType() == 0--进攻
			local arrayType = state and GameDef.BattleArrayType.CrossSuperMundaneAckFirst or GameDef.BattleArrayType.CrossSuperMundaneDefFirst
			Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType = arrayType})
		end)
	elseif GuildLeagueOfLegendsModel:isGuildLegendsArrayType(arrayType) then
		-- arrayType = GameDef.BattleArrayType.GuildLeagueOne;
		GuildLeagueOfLegendsModel:saveTeamInfo(arrayType, function ()
			Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType=arrayType})
		end);
	elseif StrideServerModel:isCrossPVPType(arrayType) then --巅峰竞技
		StrideServerModel:saveTeamToSever(function ()
			local state =  StrideServerModel:getCurPVPType() == 0--进攻
			local arrayType = state and GameDef.BattleArrayType.TopArenaAckOne
			Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType = arrayType})
		end)
	else
		ModelManager.BattleModel:requestBattleArrays(arrayType)
	end

end
	
function BattleController:battle_config(name,data)--因为后端协议字段不一致
	if data.arrays then
		ModelManager.BattleModel:updataArrayInfo(data.arrays)--主动战斗配置用1的数据
	elseif data then
		ModelManager.BattleModel:updataArrayInfo(data)--主动战斗配置用1的数据
	end
end



--"战斗取消"
function BattleController:battle_canCel(_,args)

	local arrayType = args.arrayType;
	-- 多个队伍的玩法
	if (HigherPvPModel:judgType(arrayType)) then
		arrayType = GameDef.BattleArrayType.HigherPvpAckOne;
	elseif (HigherPvPModel: isHigherPvpType(arrayType)) then
		arrayType = GameDef.BattleArrayType.HigherPvpDefOne;
	elseif (WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType)) then
		arrayType = GameDef.BattleArrayType.WorldSkyPvpDefOne;
	elseif CrossPVPModel:isAckArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.HorizonPvpAckOne;
	elseif CrossPVPModel:isDefArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.HorizonPvpDefOne;
	elseif CrossArenaPVPModel:isAckArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.CrossArenaAckOne;
	elseif CrossArenaPVPModel:isDefArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.CrossArenaDefOne;
	elseif GuildLeagueOfLegendsModel:isGuildLegendsArrayType(arrayType) then
		arrayType = GameDef.BattleArrayType.GuildLeagueOne;
	end
	
	if (self.BattleFunc[arrayType]) then
		self.BattleFunc[arrayType]("cancel")
	end
	self.BattleFunc[arrayType]=false
	self.BattleConfigs[arrayType]=false
end


--一场战斗结算检查是否有下一场战斗
function BattleController:battle_Next(_,args)
	PHPUtil.reportStep(ReportStepType.FIRST_FIGHT_END)
	local arrayType=args.arrayType
	FightManager.onNext(arrayType,args)
end




--战斗结束
function BattleController:battle_end(_,args)
	--所有战斗结束发结算了
	printTable(086,"battle_end",args)
	FsmMachine:getInstance():changeBattleState("end")
	FightManager.onEnd(args.arrayType,args)
	if (self.BattleFunc[args.arrayType]) then
		self.BattleFunc[args.arrayType]=false
		self.BattleConfigs[args.arrayType]=false
	end
	
end



function BattleController:callBattleFunc(arrayType,name)
	if  self.BattleFunc[arrayType] then
		self.BattleFunc[arrayType](name)
		self.BattleFunc[arrayType]=false
		self.BattleConfigs[arrayType]=false
	end
end


--重置战斗继续挑战
function BattleController:battle_reset(_,args)
	BattleManager:getInstance():cleansup(true)--清理战斗数据
	ViewManager.close("BattleBeginView")
	ModelManager.BattleModel:changeSpeedIndex(1,true)--恢复游戏速度
	FightManager.removeFight(args.arrayType)
	ViewManager.open("BattlePrepareView",{mapConfig=self.LastMapConfig})
end



--关闭一张战斗并后台运行
function BattleController:battle_close(_,args)
	BattleManager:getInstance():cleansup(true)--清理战斗数据
	ViewManager.close("BattleBeginView")
	ModelManager.BattleModel:changeSpeedIndex(1,true)--恢复游戏速度
	FightManager.hideFight(args.arrayType)
end




--进入下一场战斗
function BattleController:nextFight(args)
	local  arrayType=args.battleData.gamePlayInfo.arrayType
	FightManager.nextFight(arrayType,args.battleData)
end



--玩法请求返回战报  开始战斗时候
function BattleController:Battle_BattleData(_,args)

	FsmMachine:getInstance():changeBattleState("begin")
	local arrayType=args.battleData.gamePlayInfo.arrayType
	args.arrayType=arrayType
	local frontType=FightManager.frontArrayType()
	if self.BattleFunc[arrayType] then
		args.battleFunc=  self.BattleFunc[arrayType]
	end
	
	
	if not ViewArrayType[arrayType] then
		--RollTips.show("请在ViewArrayType.lua里面配置后台战斗玩法跳转转界面")
		LuaLogE("请在ViewArrayType.lua里面配置后台战斗玩法跳转转界面 "..arrayType)
	end
	

	
	--跳过战斗
	if self.BattleConfigs[arrayType]  and self.BattleConfigs[arrayType].skipBattle then --之前是跳过布阵，有后台战斗 有跳过按钮不用非得又搞个直接跳过战斗  有意思的设计
		RewardModel:setSkipBattleData(arrayType,args.battleData)
		local fightState=FightManager.addFight(arrayType,args)
		--args.arrayType=arrayType
		Dispatcher.dispatchEvent(EventType.battle_end,args)
        return 
	end
	

	
	--多场战斗的处理
	if FightManager.haveFight(arrayType)  then --战斗窗口正在打开
		self:nextFight(args)--直接下一场战斗
		return
	end
	
	--不在当前玩法的后台战斗直接进入挑战
	local ViewArrayInfo = ViewArrayType[arrayType]
	if  ViewArrayInfo and not GuideModel:IsGuiding() then
		
		local viewNode=ViewManager.getView(ViewArrayInfo.view)
		if viewNode and ViewArrayInfo.args and ViewArrayInfo.args.page then 
			viewNode = viewNode._prePage == ViewArrayInfo.args.page
		end
		if  not viewNode  then
			RollTips.show("已自动进入挑战")
			--args.arrayType=arrayType
			local fightState=FightManager.addFight(arrayType,args)  --不在该玩法界面直接进入后台战斗 恶心的需求
			FightManager.hideFight(arrayType)
			return
		end
	end

	
	
	
	
	--正常开始的战斗
	FightManager.openFight(arrayType,args)
end


--服务器返回历史战报天
function BattleController:Battle_BattleRecordData( _, args )
	if BattleModel.batchRequest then --录像库功能批量请求不需要显示窗口
		if args.battleData.recordId then
			ChatModel:addBattleData(args.battleData.recordId,args.battleData)
		end
		return 
	end
	if CrossLaddersChampModel.isFigthtRecord then
		ViewManager.open("BattledataView",{isWin=args.battleData.result,isRecord=true,battleData=args.battleData})
		CrossLaddersChampModel.isFigthtRecord = false
		return
	end

	if CrossLaddersChampModel.isLookQuiz then
		CrossLaddersChampModel.isLookQuiz = false
		return
	end	
	
	local arrayType=args.battleData.gamePlayInfo.arrayType
	local gamePlayType=args.battleData.gamePlayInfo.gamePlayType
	
	if gamePlayType == GameDef.GamePlayType.SkyLadChampion and  CrossLaddersChampModel:isPreMatch() then
		return
	end

	
	if  HigherPvPModel:judgType(arrayType) or WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType) then --高阶竞技场
		print(086,"跨服竞技场有三条历史战报，要单独处理")
	elseif CrossPVPModel:isCrossPVPType(arrayType) then
	elseif CrossArenaPVPModel:isCrossPVPType(arrayType) then
	elseif ExtraordinarylevelPvPModel:isCrossPVPType(arrayType) then
	elseif CrossTeamPVPModel:isCrossTeamPvpType(arrayType) then
	elseif StrideServerModel:isCrossPVPType(arrayType) then --巅峰竞技
	elseif arrayType ==  GameDef.BattleArrayType.GodMarket then --神虚历险
	else	
		ViewManager.open("BattledataView",{isWin=args.battleData.result,isRecord=true,battleData=args.battleData})
	end
end

 

--重新播放战报或者三场以上的联系战斗走这种方式(如高阶竞技场)
function BattleController:Battle_replayRecord(_,args)

	if not args.battleData then return end
	if args.battleData.gamePlayInfo==nil then
		args.battleData.gamePlayInfo={}
	end
	local arrayType=args.battleData.gamePlayInfo.arrayType or 0
	
	
	--跳过战斗
	if self.BattleConfigs[arrayType]  and self.BattleConfigs[arrayType].skipBattle then --之前是跳过布阵，有后台战斗 有跳过按钮不用非得又搞个直接跳过战斗  有意思的设计
		args.arrayType=arrayType
		if self.BattleFunc[arrayType] then
			args.battleFunc=self.BattleFunc[arrayType]
		end
		local fightState=FightManager.addFight(arrayType,args)
		args.notRemove=true
		Dispatcher.dispatchEvent(EventType.battle_end,args)
		return
	end
	
	
	--正常开局
	if args.battleData then
		BattleModel:updateBettleData(args.battleData)
		BattleModel:setBattleArrayType(arrayType)
	end
	local  frontType=FightManager.frontArrayType()
	print(086,arrayType,"Battle_replayRecord")
	if  FightManager.haveFight(arrayType) then --战斗窗口正在打开
		self:nextFight(args)--直接下一场战斗
	else
		FsmMachine:getInstance():changeBattleState("begin")
		if self.BattleFunc[arrayType] then
			args.battleFunc=self.BattleFunc[arrayType]
		end
		FightManager.openFight(arrayType,args)
	end
end

--播放剧情编辑动画
function BattleController:Battle_playEditBattle(_,mapConfig,battleConfig,playEditFunc)
	
	printTable(086,"播放剧情战斗")
	if not BattleModel:tryToBegin(0) then
		return
	end
	if mapConfig.arrayType==nil then
		mapConfig.arrayType=38888
	end
	
	
	self.BattleFunc[mapConfig.arrayType]=playEditFunc
	if  self.BattleFunc[mapConfig.arrayType] then
		self.BattleFunc[mapConfig.arrayType]("begin")
	end
	
	
	local battleData=BattleModel:creatBattleData(battleConfig)
	
	
	for i, battleObjSeq in ipairs(battleData.battleObjSeq) do  --假战斗出场的英雄提前加载
		if battleObjSeq.type~=3 then
			local skeletonNode,spinePool=SpineMnange.createSprineById(battleObjSeq.code,true,1)--这是英雄
			spinePool:returnObject(skeletonNode)
		end
	end
	
	for i, roundData in ipairs(battleData.roundDataSeq) do --每个回合补场的英雄提前加载
		if roundData.addHeroData~=nil and  next(roundData.addHeroData)~=nil then			
			for k, baseData in ipairs(roundData.addHeroData) do
				local isHero=baseData.type==1
				local skeletonNode,spinePool=SpineMnange.createSprineById(baseData.code,isHero,1)
				spinePool:returnObject(skeletonNode)
			end
		end
	end
		
	if mapConfig then
		local mapData=BattleConfiger.getMapByID(mapConfig.fightID)
		BattleModel:setMapInfo(mapData)
		BattleModel:setBattleConfig(mapConfig)
	end
	local function goOpenFight()	
		FightManager.openEditorFight({arrayType=mapConfig.configType,speed=battleData.speed,isTest=true,isRecord= true,skip=battleData.skip,battleData=battleData,battleFunc=self.BattleFunc[mapConfig.arrayType]})
    end
	ModelManager.BattleModel:updateBettleData(battleData)
	if battleData.gameBegin then
		ViewManager.open("PushMapFilmView",{_rootDepth = LayerDepth.WindowUI,step =battleData.gameBegin.playFilm ,endfunc=function()
					goOpenFight()
		end})
	else
		goOpenFight()
	end
end


return BattleController
