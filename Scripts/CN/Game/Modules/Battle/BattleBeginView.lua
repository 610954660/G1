
---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-13 19:30:46
---------------------------------------------------------------------
-- 战斗开始之后
--
---@class BattleModel
local BattleBeginView,Super = class("BattleBeginView", MutiWindow)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local HeroPos=ModelManager.BattleModel.HeroPos
local SeatType=ModelManager.BattleModel.SeatType
local HeroItem=require "Game.Modules.Battle.Cell.HeroItem"--每个英雄信息的item
local GodArmsCell=require "Game.Modules.Battle.Cell.GodArmsCell"--每个秘武的信息
local SpiritCell=require "Game.Modules.Battle.Cell.SpiritCell"--每个精灵的信息
local SubItem=require "Game.Modules.Battle.Cell.SubItem"

local BattleObjFactory=require "Game.Modules.Battle.Cell.BattleObjFactory"


local BattleConfiger=require "Game.ConfigReaders.BattleConfiger"
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local CameraController=require "Game.Modules.Battle.Effect.CameraController"
local MainMsgBoard = require "Game.Modules.MainUI.MainMsgBoard"
--local BuffBase= require "Game.Modules.Battle.Effect.BuffBase"


function BattleBeginView:ctor()
	self._packName = "Battle"
	self._compName = "BattleBeginView"
	
    self._batttleView=true
    
	self.playerSubList=false
	self.enemySubList=false
	self.cameraView=false
	
	self.battleData=false
	self.roundNum=false
	self.allNum=false

	self.hadEnd=false
	self._isFullScreen = true
	self.bgLoader=false
	self._rootDepth = LayerDepth.Window

	
	self.openSpeedFx=false
	
end

function BattleBeginView:setVisible(Value) 

	
end



function BattleBeginView:_initVM( )
	self.shakeView= self.view:getChildAutoType("shakeView")
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Battle.BattleBeginView
	--{vmFieldsEnd}:Battle.BattleBeginView
	--Do not modify above code----------
	vmRoot.isShowUI = self.shakeView:getChildAutoType("$isShowUI")--Button
	self.UIGroup=self.shakeView:getChildAutoType("UI")--Button
	self.UIGroup:setVisible(not __LJJ_BattleTest__)
	self.isShowUI:addClickListener(function ()
			__LJJ_BattleTest__=not self.isShowUI:isSelected()	
					
			self.UIGroup:setVisible(not __LJJ_BattleTest__)			
			self.BattleSecnesView:setVisible(not __LJJ_BattleTest__)
			self.SecretWeaponBattleView:setVisible(not __LJJ_BattleTest__)
			if self.AddTopChallengeView then
				self.AddTopChallengeView:setVisible(not __LJJ_BattleTest__)
			end

			local director = cc.Director:getInstance()
			--director:setDisplayStats(not __LJJ_BattleTest__)
			
	end)
	self.isShowUI:setVisible(false)
	if __AGENT_CODE__ == "optimiz" or __AGENT_CODE__ == "g19377sucai" then
		self.isShowUI:setVisible(true)
	end
end


function BattleBeginView:_initUI()
	--SoundManager.playMusic(5) 
	self:_initVM()

	self.gameLabel=self.shakeView:getChildAutoType("gameLabel")--替补进场飘字
	self.roundNum=self.shakeView:getChildAutoType("roundNum")
	self.cameraView=self.shakeView:getChildAutoType("CameraHang/CameraView")
	
	
	self.centerPoint=self.cameraView:getChildAutoType("centerPoint")
	self.enemyCenter=self.cameraView:getChildAutoType("enemyCenter")
	self.playerCenter=self.cameraView:getChildAutoType("playerCenter")
	self.arrayCenter=self.cameraView:getChildAutoType("arrayCenter")
	
	
	
	self.bgLoader=self.cameraView:getChildAutoType("fullScreen")	
	
	self.view:addClickListener(function ()
		ViewManager.close("BattleBuffView")
	end)
	self.view:displayObject():onUpdate(function (dt)
			BattleManager:getInstance():onUpdate(dt)
			SkillManager.onUpdate(dt)
	end,0)
	self:initData()
end



--覆盖掉多页签方法避免报错
function BattleBeginView:onViewControllerChanged()

end



--根据战斗玩法类型显示不同的备战场景
function BattleBeginView:showArrayTypeUI()
	
	
	BattleModel:setMapPoint({
			center=self.centerPoint,
			enemyCenter=self.enemyCenter,
			playerCenter=self.playerCenter,
			arrayCenter=self.arrayCenter,
	})
	--local testposition= self.view:getPosition()
	--print(5656,testposition,"testposition")
	
	CameraController.setScreenView(self.cameraView,self.shakeView)--设置镜头
	--printTable(086,self.cameraView:getPosition(),"??")
	local arrayType=self._args.arrayType
	--if arrayType == GameDef.BattleArrayType.GuildWorldBossNumOne 	-- 添加公会boss进度条
	 	--or arrayType == GameDef.BattleArrayType.GuildWorldBossNumTwo
	 	--or arrayType == GameDef.BattleArrayType.GuildWorldBossNumThree 
	 	--or arrayType == GameDef.BattleArrayType.GuildWorldBoss 
	 	--or arrayType == GameDef.BattleArrayType.GuildDailyBoss 
	 	--or arrayType == GameDef.BattleArrayType.GuildLimitBoss 
	 	--or arrayType == GameDef.BattleArrayType.EvilMountain then
		 --self:createComponentByPageName("GuildBossBarView")
	 --end
	self:createComponentByPageName("GuildBossBarView")
	if EndlessTrialModel:judgType(arrayType) then --无尽模式
		self:createComponentByPageName("AddTopChallengeView")---加载无尽特殊UI
	end
	
	if  self._args.isTest then      ---剧情剧情模式
		ModelManager.BattleModel:changeSpeedIndex(self._args.speed)--加快速度
		self.isShowUI:setVisible(false)
	end
	self:createComponentByPageName("SecretWeaponBattleView") --加载通用秘武模块
	self:createComponentByPageName("BattleSecnesView")  ---加载战斗基础UI
	self.playerSubList=self.ctlView["BattleSecnesView"].playerSubList
	self.enemySubList=self.ctlView["BattleSecnesView"].enemySubList
	--self.enemySubList=self.cameraView:getChildAutoType("enemySubList")
	self.ctlView["BattleSecnesView"].view:setSortingOrder(999)		
	local elvesHasOpen = ModuleUtil.moduleOpen( ModuleId.Elves_Attribute.id, false)  -- 判断精灵模块是否已经解锁
	if ModelManager.ElvesSystemModel.elvesOpenState  and elvesHasOpen and arrayType ~= GameDef.BattleArrayType.PveStarTemple then
		ModelManager.ElvesSystemModel.battlePrepareIsShow = false
		self:createComponentByPageName("ElvesAddTopView")  -- 加载通用的精灵模块
	end
	
	if VoidlandModel:isVoidlandMode(arrayType) then -- 虚空幻境
		if (arrayType == GameDef.BattleArrayType.DreamLandSingle) then -- 单人模式
			self.playerSubList:setVisible(false)
		end
		self:createComponentByPageName("VoidlandBattleView");
	end

	if CrossTeamPVPModel:isCrossTeamPvpType(arrayType) then
		CrossTeamPVPModel.interfaceType 	= CrossTeamPVPModel.interfaceTypeFlag and 3 or 1
		self:createComponentByPageName("CrossTeamPVPAddTopView");
	end
	
	if StrideServerModel:isCrossTeamPvpType(arrayType) then
		-- StrideServerModel.interfaceType 	= 2
		self:createComponentByPageName("StridePVPAddTopView");
	end

	if HigherPvPModel:judgType(arrayType) or 
	self._args.isTest or
	CrossPVPModel:isCrossPVPType(arrayType) or 
	CrossArenaPVPModel:isCrossPVPType(arrayType) or 
	ExtraordinarylevelPvPModel:isCrossPVPType(arrayType) or 
	CrossTeamPVPModel:isCrossTeamPvpType(arrayType) or
	StrideServerModel:isCrossPVPType(arrayType) or
	arrayType == GameDef.BattleArrayType.Trail
	then --跨服竞技场
		self.playerSubList:setVisible(false)
		self.enemySubList:setVisible(false)
	end
end



--直接下一场战斗直接刷数据
function BattleBeginView:battle_setData(_,args)
    self.hadEnd=false
	self._args.playData=args.playData
	self.battleData= self._args.playData
	for k, heroCell in pairs(BattleModel:getHeroItemLists()) do
		heroCell:resetData()
	end
	
	BattleManager:getInstance():beginGame()
	self:initBattleData()
	local loadCount=self:creatHeroItem(false)
	SkillManager.loadInFightData(1)
	BattleManager:getInstance():schedule(function()
			BattleManager:getInstance():playBeginFX2(function ()
					SpineMnange.clearPool()--无尽模式清除本场战斗无引用的对象
					ModelManager.BattleModel:playBattleInQue()--播放动作队列
			end)
	end,loadCount*0.1,1)
end

--开始一场新的战斗
function BattleBeginView:initData()
	

	BattleManager:getInstance():beginGame()
	self.battleData= self._args.playData
	self:setUpBattleScenes()
	self:showArrayTypeUI()
	self:initBattleData()
	local loadCount=self:creatHeroItem(true)
	SkillManager.loadInFightData(1)
	local ri=self.battleData.currentIndex or 1
	self.roundNum:setText(ri.."/"..self.allNum)

	BattleManager:getInstance():schedule(function()
			if self._args.stepFight then
				print(086,"stepFight",BattleModel.__battleQueues:size())
				ModelManager.BattleModel:playBattleInQue()--播放动作队列
				
			else
				BattleManager:getInstance():playBeginFX(function ()
						ModelManager.BattleModel:playBattleInQue()--播放动作队列
				end)
			end
	end,loadCount*0.1,1)
end


--创建英雄模型
function BattleBeginView:creatHeroItem(isNew)
	
	local heroStackTimes={}
	for i, battleObjSeq in ipairs(self.battleData.battleObjSeq) do --这里防止在备战界面有没缓存的spine提前加载		
		if battleObjSeq.type~=3 and battleObjSeq.type~=4 then
			local isHero=battleObjSeq.type==1
			local skeletonNode,spinePool=SpineMnange.createSprineById(battleObjSeq.code,isHero,1)
			local stacks={}
			for i = 1, 3 do
				local testTime=1
				if skeletonNode.getAnimationDuration then
					testTime=skeletonNode:getAnimationDuration("stack"..i)
				end
				stacks["stack"..i]=testTime	
			end
			heroStackTimes[battleObjSeq.code]=stacks
			spinePool:returnObject(skeletonNode)
		end
	end
	
	FightManager.setHeroStackTimes(self._args.arrayType,heroStackTimes)
	
	if isNew then
		local heroList={}
		for seatKey, seatIndexs in pairs(SeatType) do
			for k, ranges in ipairs(seatIndexs) do
				print(0933,seatKey,seatIndexs)
				local layer=0
				for seatId = ranges[1], ranges[2] do
					layer=layer+1					
					for posKey, posData in pairs(HeroPos) do	
						posData.seatId=seatId	
						local itemCell=self:creatItem(seatKey,posData,layer*4)
					    if itemCell then
							heroList[itemCell.index]=itemCell
						end
					end
					
				end
			end
		end
		ModelManager.BattleModel:setHeroItemLists(heroList)
	end
	
	local playerCount,enemyCount=0,0
	local godArmsData={}

	for i, battleObjSeq in ipairs(self.battleData["battleObjSeq"]) do
		if not battleObjSeq.deLayShow then
			local itemCell= ModelManager.BattleModel:getHeroItemById(battleObjSeq.id)
			if itemCell then
				if itemCell.isSub then
					itemCell:initItemCell(battleObjSeq.code,battleObjSeq.star,battleObjSeq.level,battleObjSeq.type, battleObjSeq.fashion, battleObjSeq.uniqueWeaponLevel)
					itemCell.baseData=battleObjSeq
					if itemCell.baseData.hp<=0 then
						itemCell:goDie()
					end
					itemCell:setAllController()
				end
				if itemCell.isFront then
					if itemCell.heroPos==HeroPos.player then
						playerCount=playerCount+1
						itemCell:setData(battleObjSeq,playerCount*(0.1),self._args.stepFight)
					else

						enemyCount=enemyCount+1
						itemCell:setData(battleObjSeq,enemyCount*(0.1),self._args.stepFight)
					end
				end
				if itemCell.godArms then
					battleObjSeq.heroPos=itemCell.heroPos
					itemCell:setData()
					table.insert(godArmsData,battleObjSeq)
				end

				if itemCell.spirit then
					battleObjSeq.heroPos=itemCell.heroPos
					itemCell:setData()
				end
			end
		end
	end
	
	SecretWeaponsModel:setArmsChoice(godArmsData)
	if playerCount>enemyCount then
	    return playerCount
	else
		return enemyCount
	end
end



--根据id创建前排信息和替补信息
function BattleBeginView:creatItem(seatKey,posData,layer)

	local itemCell=false
	local child=false	
	if seatKey=="front" then
	    child=self.cameraView:getChildAutoType(posData.name..posData.seatId)
		child:setSortingOrder(layer)
		posData.isTest=self._args.isTest
	end	
	if seatKey=="replace" then
		child=false
		if posData==HeroPos.player then
			 child=self.playerSubList:getChildAutoType(posData.name..posData.seatId)
		else
			 child=self.enemySubList:getChildAutoType(posData.name..posData.seatId)
		end
	end
	if seatKey=="godArms" then  --秘武的UI
		child=self["SecretWeaponBattleView"]:getChildAutoType("item_1_1")
	end
	if seatKey=="spirit" then  --照着秘武初始化一下精灵UI 传给战斗 
		local elvesHasOpen = ModuleUtil.moduleOpen( ModuleId.Elves_Attribute.id, false)  -- 判断精灵模块是否已经解锁
		if ModelManager.ElvesSystemModel.elvesOpenState and elvesHasOpen and self._args.arrayType ~= GameDef.BattleArrayType.PveStarTemple then
			local childId = posData.pos+posData.seatId
			child = false
			if childId >= 151 and childId <= 153 then  -- 自己的
				child = self["ElvesAddTopView"]:getChildAutoType("list_myElves"):getChild("" .. childId)
			elseif childId >= 251 and childId <= 253 then -- 敌人的
				child = self["ElvesAddTopView"]:getChildAutoType("list_otherElves"):getChild("" .. childId)
			end
		end
	end
	if child then
		itemCell=BattleObjFactory.creatItem(seatKey,child,posData)
	end
	return  itemCell

end


--方便自己测试的lug输出
function BattleBeginView:logHelp(HeroItemCell)
	local metatable = {}
	metatable.__index =  function(t, k)
		if HeroItemCell[k] == false and HeroItemCell["isSetData"] == false then
			HeroItemCell:myError(k,"调用未初始化的值")
		end

		return HeroItemCell[k]
	end

	metatable.__newindex =  function(t, k,v)
		if HeroItemCell[k]~=nil then
			HeroItemCell[k] = v
		else
			print(4,"__newindex error",k)
		end
		if v==nil then 
			HeroItemCell:myError(k,"置空")
		end
		
	end
	return metatable
end




--根据战报数据播放队列信息
function BattleBeginView:initBattleData()
	--self.allNum:setText(#self.battleData["roundDataSeq"])
	BattleModel:clearQuese()

	local numCount=0
	if self.battleData.campAddDataSeq  then
		Dispatcher.dispatchEvent(EventType.battle_tacticalUpdate,self.battleData.campAddDataSeq)
	end 
	--读取战报属性
	for i, roundData in ipairs(self.battleData["roundDataSeq"]) do
		--播放角色出手信息
		numCount=numCount+1
		local roundIndex=numCount
		--回合开始处理
		--回合结束增加buff 怒气增加
		local function roundStart()
			self:roundStartExcute(roundData.roundStartSeq,roundIndex)
		end
		ModelManager.BattleModel:pushAckerQues(roundStart)

		--剧情编辑的时候这里要上传添加英雄
		if roundData.addHeroData~=nil and  next(roundData.addHeroData)~=nil then
			local function addHeroFunc()
				self:addHero(roundData.addHeroData)
			end
			ModelManager.BattleModel:pushAckerQues(addHeroFunc)
		end
		
		if roundData.playFilm then
			local function playFilmFunc()
				self:playFilm(roundData.playFilm)
			end
			ModelManager.BattleModel:pushAckerQues(playFilmFunc)
		end
		
		local skillData={}
		--所有玩家一个回合出手信息
		for k, v in ipairs(roundData.dataSeq) do
			v.fightObjDataSeq["numCount"]=v.fightObjDataSeq["numCount"] or numCount
			
			local function attackFunc()
				self:fightObjDateSeq(v.fightObjDataSeq)  --一次出手中可能会连续追砍多次
			end
			for k, fightData in ipairs(v.fightObjDataSeq) do
				if fightData.skill then
					table.insert(skillData,fightData)
				end
			end
			ModelManager.BattleModel:pushAckerQues(attackFunc)
			if v.replaceDataSeq~=nil and  next(v.replaceDataSeq)~=nil then
				local function subFunc()
					self:replaceDataSeq(v.replaceDataSeq)
				end
				ModelManager.BattleModel:pushAckerQues(subFunc)
			end
		end
		SkillManager.addSkillData(skillData,roundIndex)

		--回合结束增加buff 怒气增加
		if roundData.heroDataSeq then
			local function addFuff()
				self:heroDataSeq(roundData.heroDataSeq)
			end
			ModelManager.BattleModel:pushAckerQues(addFuff)
		end


		--替补上场
		if roundData.replaceDataSeq and next(roundData.replaceDataSeq)~=nil then
			local function subFunc()
				self:replaceDataSeq(roundData.replaceDataSeq)
			end
			ModelManager.BattleModel:pushAckerQues(subFunc)
		end


	end

	--战斗胜利播放庆祝动作
	local function battleWin()
		ModelManager.BattleModel:changeSpeedIndex(1,true)
		local winHeroPos=HeroPos.player
		if self.battleData.result or self._args.arrayType==GameDef.battleArrayType.FairyLand then
			winHeroPos=HeroPos.player
		else
			winHeroPos=HeroPos.enemy
		end
		
		for k, v in pairs(ModelManager.BattleModel:getLifeHero()) do
			if v.heroPos==winHeroPos  then
				if v.playWin then
					v:playWin();
				end
			else
				--v:goDie()
			end
		end
		BattleManager:getInstance():schedule(function()
				ModelManager.BattleModel:playBattleInQue()--这里相当于进入结算那一步了
		end,2,1)
	end
	
	ModelManager.BattleModel:pushAckerQues(battleWin)
	
	--战斗结束
	local function battleEnd()
		self.hadEnd=true
		Dispatcher.dispatchEvent(EventType.battle_Next,{arrayType=self._args.arrayType,result=self.battleData.result})
	end
	ModelManager.BattleModel:pushAckerQues(battleEnd)
	
	
end


--#战斗角色每次出手信息
--.FightObjData {
    --id              1:integer               #战斗位置ID
    --skill           2:integer               #使用技能
    --buff            3:*BuffAddData          #生效的buff，技能施放前
    --removeBuffs     4:*integer              #删除的buff，技能施放前
    --skillEffectSeq  5:*SkillEffectData      #技能效果
    --skillValueSeq   6:*SkillValue           #角色受影响数据
    --buffEx          7:*BuffAddData          #生效的buff, 技能施放后
    --removeBuffExs   8:*integer              #删除的buff, 技能施放后
    --addShield       9:integer               #护盾值
	--rage            10:integer              #怒气值
	--suck            7:integer               #吸血
    --hurtBack        8:integer               #反伤血量  hurtBack - hurtBackShield 才是血量变化
    --hurtBackShield  9:integer               #反伤护盾
    --hurtBackRage    10:integer              #反伤怒气
    --isDoubleHit     11:integer              #1是连击
    --elfEnergy       12:integer              #精灵能量值
    --elfNextRound    13:integer              #精灵下回合能出手
--}
function BattleBeginView:fightObjDateSeq(fightObjData)
	self.roundNum:setText(fightObjData.numCount.."/"..self.allNum)
	BattleModel.roundNum=fightObjData.numCount
	BattleManager.getInstance():setFightInfo(fightObjData)
	BattleManager.getInstance():checkFightData()--检测攻击动作
end


--#替补上场信息
--.FightObjReplaceData {
	--id          1:integer          #替补位置
	--replaceId   2:integer          #场上位置
--}
function BattleBeginView:replaceDataSeq(replaceDataSeq)
	self.gameLabel:setVisible(true)
	local replaceCount=#replaceDataSeq
	self.gameLabel:getTransition("fadeIn"):play(function ()
			self.gameLabel:setVisible(false)
			for k, fightObjReplaceData in ipairs(replaceDataSeq) do
				printTable(521,"替补信息",fightObjReplaceData)
				local subtion=ModelManager.BattleModel:getHeroItemById(fightObjReplaceData.replaceId)
				local target=ModelManager.BattleModel:getHeroItemById(fightObjReplaceData.id)
	
				local baseData= clone(subtion.baseData)--替换信息上场
				subtion.baseData=clone(target.baseData)--替换信息上场
				target:beConverPos(baseData,function()
						--替补上场时，需要交换相关位置Buff信息
						ModelManager.BattleModel:exchangeBuff( fightObjReplaceData.id , fightObjReplaceData.replaceId )
						replaceCount=replaceCount-1
						if replaceCount==0 then
							ModelManager.BattleModel:playBattleInQue()--播放动画队列
						end
						
						if subtion.baseData~=false then
							subtion:initItemCell(subtion.baseData.code,subtion.baseData.star,subtion.baseData.level,subtion.baseData.type,subtion.baseData.fashionId, subtion.baseData.uniqueWeaponLevel)
							subtion.view:setGrayed(true)
							subtion.view:getChildAutoType("isDead"):setVisible(true)
						else
							subtion.view:getChildAutoType("stateLabel"):setText("已上阵")
							subtion.view:setGrayed(false)
							subtion.view:getChildAutoType("isDead"):setVisible(false)
							subtion.view:getChildAutoType("stateLabel"):setColor({r=0,g=255,b=0})
						end
						subtion.controller:setSelectedPage("into")
				end)
				
			end
	end)
end

--剧情编辑场景可以随时上阵英雄
function BattleBeginView:addHero(addHeroData)
	local replaceCount=#addHeroData
	for k, baseData in ipairs(addHeroData) do
		local target=ModelManager.BattleModel:getHeroItemById(baseData.id)
		target:beConverPos(clone(baseData),function()
				--替补上场时，需要交换相关位置Buff信息
				--ModelManager.BattleModel:exchangeBuff( fightObjReplaceData.id , fightObjReplaceData.replaceId)
				replaceCount=replaceCount-1
				if replaceCount==0 then
					ModelManager.BattleModel:playBattleInQue()--播放动画队列
				end
			end)

	end
end

--播放剧情
function BattleBeginView:playFilm(filmName,fun)
	ViewManager.open("PushMapFilmView",{_rootDepth = LayerDepth.WindowUI,step =filmName ,endfunc=function()
			if fun then
				fun()
		    else
				ModelManager.BattleModel:playBattleInQue()--播放动画队列	
			end
	end})
end


--#回合开始数据
--.RoundStartData {
	-- id              1:integer           #战斗位置
    -- buff            2:*BuffAddData      #生效的buff
    -- removeBuffs     3:*integer          #删除的buff
    -- buffShield      4:integer           #护盾值
--}
function BattleBeginView:roundStartExcute(data,numCount)
	if numCount<self.allNum then
		--print(086,numCount,"roundStartExcute")
		SkillManager.loadInFightData(numCount+1)--当前出手回合只加载下一个回合的特效,避免内存占用过高
	end
	for k, startData in pairs(data) do
		local seat=ModelManager.BattleModel:getHeroItemById(startData.id)
		SkillManager.buffEffectData(seat,startData.buffEffect)
	end
	print(086,numCount,"roundStartExcute  playBattleInQue")
	ModelManager.BattleModel:playBattleInQue("回合开始数据")
	Dispatcher.dispatchEvent(EventType.battle_roundStar,{arrayType=self._args.arrayType,numCount})
end


--#回合结算数据
--.RoundHeroData {
	-- id              1:integer           #战斗位置
    -- value           2:*integer          #效果列表
    -- removeBuffs     3:*integer          #删除的buff 
    -- rage            4:integer           #怒气
    -- buffShield      5:integer           #护盾值
    -- addShield
--}
function BattleBeginView:heroDataSeq(heroDataSeq)
	
	local notDone=false
	for k, roundHeroData in pairs(heroDataSeq) do
		local seat=ModelManager.BattleModel:getHeroItemById(roundHeroData.id)
		if seat then	
			if roundHeroData.roundRage~=nil then
				seat:addRege(roundHeroData.roundRage)
			end
			local buffEffect=roundHeroData.buffEffect			
			if buffEffect then
				notDone=true
				SkillManager.buffEffectData(seat,buffEffect)
			end	
	
		end
	end
	if notDone==false then
		--没有特殊buff 等初始化怒气后再进行下一步
		BattleManager:getInstance():schedule(function ()
				BattleManager:getInstance():roundEnd()
				ModelManager.BattleModel:playBattleInQue("buff伤害完成")
		end,0.3,1)
	else
		--有复活buff之类的等待动作完成
		BattleManager:getInstance():schedule(function ()
			BattleManager:getInstance():roundEnd()
			ModelManager.BattleModel:playBattleInQue("buff伤害完成")
		end,0.4,1)
	end
	Dispatcher.dispatchEvent(EventType.battle_roundEnd,{arrayType=self._args.arrayType})
end


--设置战斗场景资源
function BattleBeginView:setUpBattleScenes()
	local fightId=self.battleData.mapId
	if fightId==nil then
		fightId=1
	end
	local mapConfig=BattleConfiger.getMapByID(fightId)
	self.roundNum:setText("1/"..mapConfig.maxRound)
	self.allNum=mapConfig.maxRound
	if self.battleData.background then
		self.bgLoader:setIcon(PathConfiger.getMapBg(self.battleData.background))
	else
		self.bgLoader:setIcon(PathConfiger.getMapBg(mapConfig.map))
	end
	mapConfig.fightID=fightId
	BattleModel:setMapInfo(mapConfig)
	
end
--聊天频道接受的消息
function BattleBeginView:chat_newMsg(evt, data)
	if(self._mainMsgBoard) then
		self._mainMsgBoard:onNewMsg1(data)
	end
	
end


function BattleBeginView:_exit()
	--SoundManager.deleteLastMusicId()
	--local id = SoundManager.getLastMusicId()
	--print(1,"last musicid",id)
	--SoundManager.playMusic(id)
	BattleManager:getInstance():cleansup(true)
	BattleModel:changeSpeedIndex(1,true)--恢复游戏速度
end

return  BattleBeginView