---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-10-13 20:34:50
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MultiBattleUtil

local FightManager = {}
local FightState=require "Game.Modules.Battle.MuitiBattle.FightState"
local fightList={}

local requestList={}--防止同一种战斗连续点击



local interval=1
local frontArrayType=false



function FightManager.init()
	local layerNode = ViewManager.getParentLayer(LayerDepth.Window)
	layerNode:displayObject():onUpdate(function (dt)
			FightManager.tick(dt)
	end,0)
end

function FightManager.setHeroStackTimes(arrayType,stackTimes)
	if fightList[arrayType] then
		fightList[arrayType]:setHeroStackTimes(stackTimes)
	end
end

function FightManager.tick(dt)
	interval=interval-dt
	if interval<=0 then
		--print(086,FightManager.tick,interval)
		interval=1
		for _, battleObj in pairs(fightList) do
			if battleObj then
				battleObj:pushTime()
			end
		end
	end
end


function FightManager.addRequestList(arrayType)
	requestList[arrayType]=true
	
end

function FightManager.removeRequestList(arrayType)
	if requestList[arrayType] then
		requestList[arrayType]=nil
	end
end

function FightManager.getRequestList(arrayType)
	return requestList[arrayType]
end


function FightManager.addFight(arrayType,args)
	local fightState=FightState.new(args)
	fightList[arrayType]=fightState
	RedManager.updateValue(arrayType, true);
	return fightState
end

function FightManager.removeFight(arrayType)
	fightList[arrayType]=nil
	RedManager.updateValue(arrayType, false);
	if frontArrayType==arrayType then
		frontArrayType=false
	end
end


function FightManager.hideFight(arrayType)
	if fightList[arrayType] then
		fightList[arrayType]:hideToBack()
	end
	if frontArrayType==arrayType then
		frontArrayType=false
	end
end

--是否后台战斗
function FightManager.isOnBack(arrayType)
	if fightList[arrayType] then
		return fightList[arrayType].isBackGroud
	end
end



function FightManager.getRunArrayType(viewName,args)
	printTable(086,args,"args")
	local arrayType=false
	for k, battleObj in pairs(fightList) do
		if battleObj.openInfo and battleObj.openInfo.view~="MainSubBtnView" and battleObj.openInfo.view==viewName  then	
			if args and args.activeType  then
				if args.activeType==battleObj.openInfo.args.activeType then
					arrayType=battleObj.arrayType
				end
			else
				arrayType=battleObj.arrayType
			end			
		end
	end
	return arrayType
end

--根据战斗类型返回后台战报
function FightManager.getBettleData(arrayType)
	local battleObj=fightList[arrayType]
	if battleObj then
		return battleObj.battleData
	end
end


function FightManager.haveFight(arrayType)
	return TableUtil:kIn(fightList,arrayType)
end

function FightManager.battleState(arrayType)
	local battleObj=fightList[arrayType]
	if battleObj then
		 if battleObj.isBackGroud then
			return "back"
		 else
			return "front"
		 end	
	end
end


--无尽等后台战斗进入下一场
function FightManager.nextFight(arrayType,battleData)
	local battleObj=fightList[arrayType]
	if battleObj then
		battleObj:resetData(battleData)
	end
end


--获取当前打开战斗的玩法类型
function FightManager.frontArrayType()
     return frontArrayType
end


function FightManager.openFight(arrayType,args)
	local playData=false
	local stepFight=false
	if TableUtil:kIn(fightList,arrayType) then
		local fightState=fightList[arrayType]
		playData=fightState:getStepData()
		args=fightState:getArgsInfo()
		stepFight=true
	else
		local fightState=FightManager.addFight(arrayType,args)
		playData=fightState.battleData
	end
	if frontArrayType then
		LuaLogE("背包跳转过来没有回到主界面的战斗将被新战斗覆盖！！ "..frontArrayType)
		Dispatcher.dispatchEvent(EventType.battle_close,{arrayType=frontArrayType})
	end
	frontArrayType=arrayType
	--FightManager.removeRequestList(arrayType)
	ViewManager.open("BattleBeginView",{isTest=args.isTest,playData=clone(playData),arrayType=arrayType,isRecord=args.isRecord,stepFight=stepFight},function ()
			Dispatcher.dispatchEvent(EventType.battle_enter)
	end)

end


function FightManager.openEditorFight(args)
	if args.arrayType==nil then
		args.arrayType=38888
	end
	args.battleData.gamePlayInfo={}
	args.battleData.gamePlayInfo.arrayType=args.arrayType
	args.editorFight=true
	local fightState=FightManager.addFight(args.arrayType,args)
	args.playData=fightState.battleData
	frontArrayType=args.arrayType
	ViewManager.open("BattleBeginView",args,function ()
			Dispatcher.dispatchEvent(EventType.battle_enter)
	end)

end


function FightManager.onBegin(arrayType)
	--local fightState=fightList[arrayType]
	--if fightState then
		--fightState:onBegin()
	--end	
end

function FightManager.onNext(arrayType,args)
	local fightState=fightList[arrayType]
	if fightState then
		fightState:onNext(args)
	end
end

function FightManager.onEnd(arrayType,args)

	local fightState=fightList[arrayType]
	if fightState then
		fightState:onEnd(args)
	end
	FightManager.removeRequestList(arrayType)
	FightManager.removeFight(arrayType)
end

function FightManager.clear()
	fightList={}
end


return FightManager