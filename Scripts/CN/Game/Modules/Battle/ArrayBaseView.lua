---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-08 20:19:34
---------------------------------------------------------------------

-- 战前准备的操作界面
--
---@class ArrayBaseView
local ArrayBaseView,Super = class("ArrayBaseView", MutiWindow)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local SeatType=ModelManager.BattleModel.SeatType
local HeroPos=ModelManager.BattleModel.HeroPos
local SeatItem=require "Game.Modules.Battle.Cell.SeatItem"
local SubItem=require "Game.Modules.Battle.Cell.SubItem"

local BattleConfiger=require "Game.ConfigReaders.BattleConfiger"
function ArrayBaseView:ctor()
	self._packName = "Battle"
	self._compName = ""

	self.selectList=false--战前准备英雄选择列表
	self.categoryList=false--英雄筛选列表

	self.beginBtn=false  --开始战斗按钮
	self.saveBt=false    --
	self._isFullScreen = true
	self.bgIcon=false
	self.myFightCamp=false --我放战力
	self.enemyFightCamp=false--地方战力

	--self._waitBattle = true --如果有战斗未结束跳转到这里需要等待战斗结束

	self.playerSeatLatout=false
	self.playerList=false
	self.playerSubList=false
	self.enemyList=false
	self.enemySubList=false


	self.cardControllers=false
	self.handCardInfos=false
	self.HeroCells=false


	self.atackController=false

	self.troopBtn=false
	self.txt_tactical=false
	self.battleArrayType=false  --玩法id 对应的阵容
	self._rootDepth = LayerDepth.Window

	self.curCategory=0
	self.prepareTitle=false
	
	self._hadInit=false

end

function ArrayBaseView:_initVM( )

end



function ArrayBaseView:_initUI()
	PHPUtil.reportStep(ReportStepType.FIRST_FIGHT_PREPARE)
	local viewRoot = self.view
	
	self.bgIcon=self.view:getChildAutoType("frame")
	self.selectList=self.view:getChildAutoType("selectList")
	self.playerSeatLatout=self.view:getChildAutoType("playerSeatLatout")
	self.enemyFightCamp=self.view:getChildAutoType("enemyFightCamp")
	self.myFightCamp=self.view:getChildAutoType("myFightCamp")
	self.prepareTitle=self.view:getChildAutoType("prepareTitle")
	self.playerList=self.playerSeatLatout:getChildAutoType("playerList")
	self.playerSubList=self.playerSeatLatout:getChildAutoType("playerSubList")
	self.enemyList=self.playerSeatLatout:getChildAutoType("enemyList")
	self.enemySubList=self.playerSeatLatout:getChildAutoType("enemySubList")
	self._closeBtn=self.view:getChildAutoType("closeButton")
	self.troopBtn=self.view:getChildAutoType("troopBtn")
	self.txt_tactical=self.view:getChildAutoType("txt_tactical")
	self.categoryList=self.view:getChildAutoType("categoryList")
	self.atackController=self.view:getController("configType")
	self.beginBtn=self.view:getChildAutoType("beginBtn")
	self.saveBt=self.view:getChildAutoType("confirm")
	self.uiTypeCtr=self.view:getController("configType")
	
	
	RedManager.register("M_TACTICAL", self.troopBtn:getChild("img_red"))
	self.categoryList:setItemRenderer(function (index,item)
			item:setIcon(PathConfiger.getCardSmallCategory(index))
			item:addEventListener(FUIEventType.Click,function (context)
					self:onCkickCgy(index)
			end,101)

	end)
	self.categoryList:setNumItems(6)
	ModelManager.BattleModel:reInit()
	self.battleArrayType= self._args.mapConfig.configType
	self:initData()
	self:setCategoryLock()
	self:battle_refightCamp()
	self:tatical_change()
	
end



function ArrayBaseView:onViewControllerChanged() 
	
end


--阵法切换
function ArrayBaseView:tatical_change()
	local tactical = ModelManager.TacticalModel:getCurTactical(self._args.mapConfig.configType)
	local info = DynamicConfigData.t_TacticalUnlock[tactical]
	local level = ModelManager.TacticalModel:getTacticalLevel(tactical)
	if tolua.isnull(self.troopBtn) then return end
	local taticalCell = BindManager.bindTacticalCell(self.troopBtn)
	taticalCell:setData(tactical == 0 and 1 or tactical)
	if tactical ~= 0 then
		self.txt_tactical:setText(info.name)
	else
		if not ModelManager.TacticalModel:isActived(1) then
			self.txt_tactical:setText(Desc.battle_tacticalNotActive)
		else
			self.txt_tactical:setText(Desc.battle_tacticalNotUse)
		end
	end
end


--确认阵容或者开始战斗都会保存阵容配置
function ArrayBaseView:beginBattle()
	local arrayType = self._args.mapConfig.configType
	local arryData=ModelManager.BattleModel:getRequestArrayInfo(arrayType)
	if arryData==nil or  next(arryData)==nil and not GuildLeagueOfLegendsModel:isGuildLegendsArrayType(self._args.mapConfig.configType) then
		RollTips.show(Desc.battle_DetailsStr2)
		return
	end
	local haveFront=false
	for k, v in pairs(arryData) do
		--printTable(521,v.id,"保存阵容")
		if v.id<31 then
			haveFront=true
			break
		end
	end
	if  haveFront==false and not GuildLeagueOfLegendsModel:isGuildLegendsArrayType(self._args.mapConfig.configType) then
		 RollTips.show(Desc.battle_DetailsStr3)
		return
	end
	local chooseArrayType=self._args.mapConfig.configType
	Dispatcher.dispatchEvent(EventType.battle_array,chooseArrayType)--保存阵容信息
	if (not HigherPvPModel:isHigherPvpType(chooseArrayType)) and 
		not CrossPVPModel:isCrossPVPType(chooseArrayType) and 
		not CrossArenaPVPModel:isCrossPVPType(chooseArrayType) and
		not StrideServerModel:isCrossPVPType(chooseArrayType) and
		not ExtraordinarylevelPvPModel:isCrossPVPType(chooseArrayType) and
		not GuildLeagueOfLegendsModel:isGuildLegendsArrayType(self._args.mapConfig.configType) then
		Dispatcher.dispatchEvent(EventType.battle_begin,{arrayType=chooseArrayType})
	end
end



--初始化座位信息
function ArrayBaseView:initData()
	--初始化三列位置的信息
	local seatInfos={}
	local enemyInfos={}
	local index=0
	for seatKey, ranges in ipairs(SeatType.front) do
		local layer=0
		for seatId = ranges[1], ranges[2] do
			index=index+1
			layer=layer+1
			seatInfos[index]=self:creatItem(self.playerList,seatId)
			seatInfos[index].index=index
			seatInfos[index].heroPos=HeroPos.player
			seatInfos[index].zIndex=layer

			seatInfos[index].view:setSortingOrder(index)

			enemyInfos[seatId]=self:creatItem(self.enemyList,seatId)
			enemyInfos[seatId].index=index
			enemyInfos[seatId].seatId=seatId+HeroPos.enemy.pos
			enemyInfos[seatId].heroPos=HeroPos.enemy
			enemyInfos[seatId].zIndex=layer
			if GuildModel:isBossArrayType(self._args.mapConfig.configType) then
				enemyInfos[seatId].view:setVisible(false)
			end

		end
	end
	for seatKey, ranges in ipairs(SeatType.replace) do
		for seatId = ranges[1], ranges[2] do
			index=index+1
			seatInfos[index]=self:creatItem(self.playerSubList,seatId)
			seatInfos[index].index=index
			seatInfos[index].heroPos=HeroPos.player
			seatInfos[index]:initUI()
			enemyInfos[seatId]=self:creatItem(self.enemySubList,seatId)
			enemyInfos[seatId].index=index
			enemyInfos[seatId].seatId=seatId+HeroPos.enemy.pos
			enemyInfos[seatId].heroPos=HeroPos.enemy

		end
	end
	BattleModel.rollOverFx= fgui.GObject:create()
	SpineUtil.createSpineObj(BattleModel.rollOverFx,Vector2(0,0),"animation",PathConfiger.getSettlementRoot(),"Ef_tongyongxuanzhongguang")
	self.view:addChild(BattleModel.rollOverFx)
	BattleModel.rollOverFx:setVisible(false)
	ModelManager.BattleModel:setSeatInfos(seatInfos)
	ModelManager.BattleModel:setEnemySeatInfos(enemyInfos)
	

	ModelManager.BattleModel:requestHeroArrayList(self._args.mapConfig,function ()
			if tolua.isnull(self.view) then
				return 
			end
			self:requestHeroFinished()	
	end)
end



function ArrayBaseView:creatItem(list,seatId)
	local child=list:getChildAutoType(seatId)
	local itemCell=false
	if BattleModel:getSeatType(seatId)=="replace" then
		itemCell=SubItem.new(child)--替补位操作一致
	else
		itemCell=BindManager.bindSeatItem(child)
	end
	itemCell.seatId=seatId
	itemCell.Onclick=function(uuid,seatId)
		self:outToTable(uuid,seatId)
	end
	return itemCell
end


--设置战斗场景地方阵容信息
function ArrayBaseView:setBattleScenes(mapCinfig)

end


--更新对阵阵容信息
function ArrayBaseView:updateScenes() 
	local arryData=ModelManager.BattleModel:getEnemyArrayInfo()
	self:setPlayerInfos(arryData)--设置我方数据
	if self.uiTypeCtr:getSelectedPage()~="defandConfig"  then
		self:setEnemyInfos(arryData)--设置敌方数据
	end
	self._hadInit=true
end


--更新敌方阵容信息
function ArrayBaseView:setEnemyInfos(arryData)
	self.enemyFightCamp:setText(StringUtil.transValue(arryData.combat or 0))
	for k, seat in pairs(ModelManager.BattleModel:getEnemySeatInfos()) do
		seat:resetItem()
	end
	if arryData.heroInfos then
		for i, v in pairs(arryData.heroInfos) do
			if v.hp == 0 then
				print(4,v.id,"已阵亡")
			else
				local seat=ModelManager.BattleModel:getEnemySeatInfos()[v.id]
				if seat then
					seat.view:setVisible(true)
					seat:initItemCell(v.code,v.star,v.level,v.type,v.fashionCode,v.uniqueWeaponLevel,self._args.mapConfig.configType)
					seat.isEmpty = false
				else
					print(4,v.id,"没有座位信息")
				end
			end
		end
	end
	BattleModel:changeCampeItem(self.eneymyCamp,BattleModel.HeroPos.enemy)
end


--更新自己阵容信息
function ArrayBaseView:setPlayerInfos(arrayData)
	if arrayData==nil then
		return
	end
	self.battleArrayType= self._args.mapConfig.configType
	
	for k, seat in pairs(ModelManager.BattleModel:getSeatInfos()) do
		seat:resetItem()
	end
	if arrayData.array then
		for i, v in pairs(arrayData.array) do --默认第一种战斗配置
			local hero=ModelManager.BattleModel:getHeroByUid(v.uuid)
			if hero==false then
				RollTips.show("阵容信息错误 uuid:"..v.uuid)
				break
			end
			local seat=ModelManager.BattleModel:getSeatById(v.id)
			if seat then
				self:putoTable(seat,hero)
			else
				print(4,v.id,"没有座位信息")
			end
		end
	end
	self:battle_refightCamp()
	self:tatical_change()
	BattleModel:changeCampeItem(self.selfCamp,BattleModel.HeroPos.player)
end



function ArrayBaseView:setSelectedIndexs(Categorys)
	if type(Categorys)~="table" then
		Categorys={
			[1]=Categorys
		}
	end
	if tolua.isnull(self.categoryList) then return end
	for i = 0, self.categoryList:getNumItems()-1 do
		self.categoryList:removeSelection(i)
	end
	for k, category in pairs(Categorys) do
		self.categoryList:addSelection(category,false)
	end
end



--设置角色选择信息
function ArrayBaseView:setCardsByCategory(Categorys)
	if type(Categorys)~="table" then
		Categorys={
			[1]=Categorys
		}
	end
	self:setSelectedIndexs(Categorys)
	local CardslList=false
	CardslList=ModelManager.BattleModel:getCardsByCategorys(Categorys)--如果选中两种种族则都会显示出来
	self:setCardList(CardslList)
end



--设置卡牌展示
function ArrayBaseView:setCardList(CardList)
	self.cardControllers={}
	self.HeroCells={}
	self.handCardInfos=CardList
	if tolua.isnull(self.view) then
		return
	end
	self.selectList:setVirtual()
	self.selectList:setItemRenderer(function(index,card)
			local carInfo=CardList[index+1]
			-- printTable(1,carInfo)
			local carStateCtrl=card:getController("state")
			self:tempCommonCell(carInfo,card)
			self.cardControllers[carInfo.uuid]=carStateCtrl
			carStateCtrl:setSelectedPage("out")
			self:setMaskOnCard()
			--玩法的特殊处理
			if self._args.mapConfig.configType == GameDef.BattleArrayType.Maze or self._args.mapConfig.configType == GameDef.BattleArrayType.DevilRoad then
				card:getController("hadHPCtrl"):setSelectedIndex(1)
				card:getChildAutoType("progressBar"):setMax(carInfo.maxHp)
				card:getChildAutoType("progressBar"):setValue(carInfo.hp)
				if carInfo.mirror >=1 then
					card:getController("mirrorCtrl"):setSelectedIndex(1)
				else
					card:getController("mirrorCtrl"):setSelectedIndex(0)
				end

				if carInfo.hp<=0 then
					if card:getController("grayCtrl") then
						card:getController("grayCtrl"):setSelectedIndex(1)
					end
				else
					if card:getController("grayCtrl") then
						card:getController("grayCtrl"):setSelectedIndex(0)
					end
				end
				if carInfo.rage and carInfo.rage>0 then
					card:getController("npCtrl"):setSelectedIndex(1)
					--card:getChildAutoType("nqprogressBar"):setValue(10000)
					card:getChildAutoType("nqprogressBar"):setValue(carInfo.rage/100)
				else
					card:getController("npCtrl"):setSelectedIndex(0)
				end
				
			elseif self._args.mapConfig.configType == GameDef.BattleArrayType.DreamLandMultiple then
				if carInfo.mirror >=1 then
					card:getController("mirrorCtrl"):setSelectedIndex(1)
				else
					card:getController("mirrorCtrl"):setSelectedIndex(0)
				end

				if carInfo.hp<=0 then
					if card:getController("grayCtrl") then
						card:getController("grayCtrl"):setSelectedIndex(1)
					end
				else
					if card:getController("grayCtrl") then
						card:getController("grayCtrl"):setSelectedIndex(0)
					end
				end
			elseif self._args.mapConfig.configType ==  GameDef.BattleArrayType.HolidayBoss then
				if  ActCommonBossModel:checkIdInArray(carInfo.code) then
					card:getController("jianCtrl"):setSelectedIndex(1)
				else
					card:getController("jianCtrl"):setSelectedIndex(0)
				end
			end
		end
	)
	self.selectList:setNumItems(#CardList);
end

--放入阵前
function ArrayBaseView:checkTable(heroInfo,seatId)
	--上阵英雄个数限制
	if self._args.mapConfig.heroNum and ModelManager.BattleModel:getBattleHeroNum()>=self._args.mapConfig.heroNum then
		RollTips.show(Desc.battle_heronumtips:format(self._args.mapConfig.heroNum))
		return
	end

	local seat=false
	if seatId then
		seat=ModelManager.BattleModel:getSeatInfos()[seatId]
	else
		seat=ModelManager.BattleModel:getLateSeat()
	end

	if seat and seat.isSub then
		if seat.seatId==31 then
			if not ModuleUtil.moduleOpen(ModuleId.Alternate_Front.id,true) then
				return
			end
		end
		if seat.seatId==32 then
			if not ModuleUtil.moduleOpen(ModuleId.Alternate_Back.id,true) then
				return
			end
		end
	end
	if ModelManager.BattleModel:hasEmpty()==false then
		RollTips.show("阵容已满！")
		return
	end

	local hasPut=ModelManager.BattleModel:checkPut(heroInfo.code)
	if hasPut then
		RollTips.show(Desc.battle_DetailsStr1)
		return
	end
	self:putoTable(seat,heroInfo,true)

end


--英雄下阵
function ArrayBaseView:outToTable(uuid,seatId)
	local seatItem=ModelManager.BattleModel:getSeatById(seatId)
	seatItem:resetItem()
	self:setMaskOnLock()
end

--刷新桌子
function ArrayBaseView:putoTable(seat,heroInfo,playBorn)
	--print(086,"putoTable")
	seat:setHeroInfo(heroInfo,playBorn,self._args.mapConfig.configType,1)
	self:setMaskOnLock(playBorn)
	if playBorn then
		BattleModel:changeCampeItem(self.selfCamp,BattleModel.HeroPos.player)
	end
end


--已选卡牌放入遮罩
function ArrayBaseView:setMaskOnCard()
	self:setMaskOnLock()
end


function ArrayBaseView:setMaskOnLock(playBorn)
	for k, heroCell in pairs(self.HeroCells) do
		local  stateCtrl=heroCell.view:getController("state")
		heroCell.view:setGrayed(false)
		stateCtrl:setSelectedPage("out")
		if  ModelManager.BattleModel:checkCard(heroCell.uuid) then
			stateCtrl:setSelectedPage("on")
		elseif ModelManager.BattleModel:checkPut(heroCell.code) then
			stateCtrl:setSelectedPage("lock")
			--heroCell.view:setGrayed(true)
		end
	end
end

--刷新战力
function ArrayBaseView:battle_refightCamp()
	if tolua.isnull(self.myFightCamp) then
		return 
	end
	self.myFightCamp:setText(StringUtil.transValue(ModelManager.BattleModel:getFightCamp() + ModelManager.TacticalModel:getTacticalCombat(self.battleArrayType)))
end



function ArrayBaseView:tempCommonCell(carInfo,card)--暂时替代卡牌通用框
	local carStateCtrl=card:getController("state")
	card:removeEventListener(FUIEventType.Click,101)
	card:addEventListener(FUIEventType.Click,function (context)
			if carInfo.hp and carInfo.hp<=0 then
				RollTips.show(Desc.battle_cardUseTxt)
				return
			end
			context:stopPropagation()--阻止事件冒泡
			SoundManager.playSound(1,false)
			if carStateCtrl:getSelectedPage()=="on" then
				local seat=ModelManager.BattleModel:getSeatByuuid(carInfo.uuid)
				local seatId = seat and seat.seatId or false;
				self:outToTable(carInfo.uuid, seatId)
				return
			end
			self:checkTable(carInfo)
		end,101)
	local heroCell = BindManager.bindHeroCell(card)
	table.insert(self.HeroCells,heroCell)
	if self._args.mapConfig.configType == GameDef.BattleArrayType.EndlessRoad then
		heroCell:setData(carInfo)
	else
		heroCell:setBaseData(carInfo)
	end
end


--选择默认的种族手牌
function ArrayBaseView:updateDefaultCamp()
	local idx = 0
	if self._args.mapConfig.activeType ~= nil  then
		local towerTypeData=  DynamicConfigData.t_towerType[self._args.mapConfig.activeType]
		idx = towerTypeData.category
		--Desc.pata_floor
	end

	if self._args.mapConfig.category then
		idx=self._args.mapConfig.category
	end

	print(1 , "enter : " , idx)
	self:setCardsByCategory(idx)
end



--种族选择框被点击时
function ArrayBaseView:onCkickCgy(index)
	local categoryData=index
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
		self:setSelectedIndex(self._args.mapConfig.category)
		return
	end
	self:setCardsByCategory(categoryData)
end


function ArrayBaseView:setCategoryLock()
	local categoryData=0
	if self._args.mapConfig.activeType ~= nil  then
		local towerTypeData=  DynamicConfigData.t_towerType[self._args.mapConfig.activeType]
		local have=towerTypeData.category[1]==0
		if towerTypeData.category[1]~=0 then
			for i=0,self.categoryList:getNumItems()-1 do
				self.categoryList:getChildAt(i):setGrayed(true)
			end
			for k, category in pairs(towerTypeData.category) do
				self.categoryList:getChildAt(category):setGrayed(false)
			end
		end

	end
	
	


end




--返回上一
function ArrayBaseView:_returnView()
	local arrayType=self._args.mapConfig.configType
	Dispatcher.dispatchEvent(EventType.battle_canCel,{arrayType=arrayType})--战斗取消
end



return ArrayBaseView