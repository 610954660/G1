   
---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-13 19:30:46
---------------------------------------------------------------------
-- 战斗模块的modle
--

---@class BattleModel
local ArrayBaseModel=require "Game.Modules.Battle.ArrayBaseModel"
local RedConst = require "Game.Consts.RedConst"
local ArrayName = require "Game.Consts.ArrayName"
local BattleModel,Super = class("BattleModel",ArrayBaseModel)


function BattleModel:ctor()
	self.prepareArrayType=false--当前备战界面的玩法类型
	self.mapConfigs = {}
	self.recordSpeed=0

end

function BattleModel:setCureOpenType(configType)
	self.prepareArrayType=configType
end


function BattleModel:setMapConfig(configType, mapConfig)
	self.mapConfigs[configType] = mapConfig
end

function BattleModel:getMapConfig(configType)
	return self.mapConfigs[configType]
end



function BattleModel:crossPVPHandle(mapConfig,finished)
	local showHeroList = {}
	local data = HandbookModel.data
	if data then
		for k,v in pairs(data.race and data.race or {}) do
			for m,n in pairs(v.hero and v.hero or {}) do
				table.insert(showHeroList, n)
			end
		end
	end
	local cardListData = {}
	for key,value in pairs(showHeroList) do
		local config = DynamicConfigData.t_HorizonPvpTotems[value.heroCode]
		if config then
			local hero = {}
			hero.level = config.lv
			hero.star = config.heroStar
			hero.code = config.hero
			hero.uuid = tostring(config.hero)
			hero.combat = config.combat or 0
			--hero.fashionId = value.fashion
			cardListData[hero.uuid] = hero
		end
	end
	self:updateFightHeroList(cardListData)
	if finished then
		finished()
	end
end
		
--获取手牌数据 这里需要改成汪洋那边获取
function BattleModel:requestHeroArrayList(mapConfig,finished)
	if CrossPVPModel:isCrossPVPType(mapConfig.configType) then
		self:crossPVPHandle(mapConfig,finished)
		return 
	end
	local function success(data)
		 --printTable(086,data,"requestHeroArrayList")
		 local handCardData =CardLibModel:getFightHeroList(mapConfig)
		 if next(data.heroList) then
			for uuid, v in pairs(data.heroList) do
				handCardData[uuid]=v
			end
		 end
		 self:updateFightHeroList(handCardData)
		 if finished then
			finished()
		 end		 
	end
	local info = {
		arrayType = mapConfig.configType,
		index = mapConfig.index
	}
	--printTable(0866,"发送的参数 requestHeroList",info)
	RPCReq.Battle_GetHeroArrayList(info,success)
end


--处理对应玩法可上阵英雄的信息
function BattleModel:updateFightHeroList(data)
	if data==nil then return end
	local temp={}
	self.__heroInfos={}
	for uuid, card in pairs(data) do
		card.category=DynamicConfigData.t_hero[card.code].category
		if self.__heroInfos[card.category]==nil then
			self.__heroInfos[card.category]={}
		end
		local useHerosCodeList= CooperationActivitiesModel:gettCooperationUseHerosCodeList(GameDef.ActivityType.WorkTogetherAct)
		if self.prepareArrayType==GameDef.BattleArrayType.WorkTogether then
			if not useHerosCodeList[card.code] then
				table.insert(self.__heroInfos[card.category],card)
			end
		else
			table.insert(self.__heroInfos[card.category],card)
		end	
	end
end


--request告诉服务端保存战前阵容信息 每次只保存当前选中的玩法阵容
function BattleModel:requestBattleArrays(arrayType,arrayList, onSuccess)
	if not arrayList then
		arrayList={
		}
		for k, v in pairs(self.__requestArrayInfos[self.prepareArrayType]) do
			local array={}
			array.uuid=v.uuid
			array.id=v.id
			arrayList[v.uuid]=array
		end
	end
	
	local info={
			arrayType=arrayType,
			array=arrayList
		}
	local function success(data)
		self.__arrayInfos[arrayType]=info
		RedConst.initCardMap()
		Dispatcher.dispatchEvent(EventType.squadtomodify_change);
		ModelManager.CardLibModel:redCheck()
		if onSuccess then
			onSuccess()
		end
	end
	RPCReq.Battle_BatchUpdateBattleArray(info,success)
end



--根据uuid获取卡牌信息
function BattleModel:getHeroByUid(uuid)
	local hero=false
	local temp={}
	for category, groupInfos in pairs(self.__heroInfos) do
		for k, v in pairs(self.__heroInfos[category]) do
			--temp[#temp+1]=v
			if v.uuid==uuid then
				hero=v
			end
		end
	end
	return hero
end


--根据种族id 赛选对应种族
function BattleModel:getCardsByCategory(Category)
	if self.__heroInfos[Category] then
		local temp={};
		local listTable= self.__heroInfos[Category]
		for k, v in pairs(listTable) do
			temp[#temp+1]=v
		end
		temp=self:starSort(temp)
		self.__CardsCategory=temp;
	else
		self.__CardsCategory={}
	end
	return self.__CardsCategory
end


--根据种族id数组 同时选择多组卡牌
function BattleModel:getCardsByCategorys(Categorys)

	if Categorys[1]==0 then
		return self:getAllCards()
	end
	local temp={};
	for k, category in pairs(Categorys) do
		if self.__heroInfos[category] then
			local listTable= self.__heroInfos[category]
			for k, v in pairs(listTable) do
				temp[#temp+1]=v
			end
		end
	end
	temp=self:starSort(temp)
	self.__CardsCategory=temp;
	return self.__CardsCategory
end


--获取所有可上阵卡牌信息
function BattleModel:getAllCards()
	local temp={}
	for category, groupInfos in pairs(self.__heroInfos) do
		for k, v in pairs(self.__heroInfos[category]) do
			temp[#temp+1]=v
		end
	end
	temp=self:starSort(temp)
	return temp
end


--判断是否同一场战斗
function BattleModel:tryToBegin(arrayType)
	
	local eqWar=true
	local runArrayType=  self:getRunArrayType() --后台正在运行的战斗
	if runArrayType then
		if arrayType then
			if HigherPvPModel:judgType(arrayType)  then --这种玩法有三个类型所以只能这么判断
				eqWar= HigherPvPModel:judgType(runArrayType) --判断另外一种类型是否是高阶竞技场
			else
				eqWar=runArrayType==arrayType --不是三种类型的玩法直接判断是否相等
			end		
		else
			 RollTips.show("获取玩法信息错误")
			 eqWar= false
			 return eqWar
		end
	end
	
	if not eqWar then
		if ArrayName[runArrayType]  then
			RollTips.show("请等待"..ArrayName[runArrayType].."战斗结束")
		else
			RollTips.show("请等待"..runArrayType.."战斗结束")
		end
	end
	return eqWar
end



function BattleModel:changeCampeItem(campItem,heroPos,inBattle)
	
	if not campItem.fxEfect then
		local skeletonNode=SpineUtil.createSpineObj(campItem, Vector2.zero, nil, SpinePathConfiger.CircleEffect.path, SpinePathConfiger.CircleEffect.upEffect, SpinePathConfiger.CircleEffect.upEffect,false,true)
		--skeletonNode:setAnimation(0,SpinePathConfiger.CircleEffect.animatin_lan,true)
		skeletonNode:setScale(0.5,0.5)
		campItem.fxEfect=skeletonNode
		campItem.lastAimation="none"
	end
	if not campItem.campTable then
		campItem.campTable={}
	end
	
    campItem.fxEfect:setVisible(false)
	--if heroPos==self.HeroPos.player then
		--printTable(5656,campItem.lastAimation,"campItem.lastAimationcampItem.lastAimation")
	--end

	local campList={}
	if inBattle then
		campList=self:getCampAddInBattelData(heroPos)
		--printTable(5656,campList,"campListcampList")
	else
		campList=self:getCampAddition(heroPos)
	end
	local temp2={}
	for k, v in pairs(campList) do
		local addition=DynamicConfigData.t_camp[v.category][v.num]
		if addition then
			table.insert(temp2,v)
		end
	end

	TableUtil.sortByMap(temp2, {{key = "num", asc = true}})
	local campNum=table.nums(temp2)
	local lastCampNum=table.nums(campItem.campTable)
	local haveAni=false
	local playAniName=""
	

	if heroPos==self.HeroPos.player then
		printTable(5656,campItem.campTable,temp2)
		if  campNum>lastCampNum then
			for k, v in pairs(temp2) do
				if campItem.campTable[v.category]==nil then
					playAniName=SpinePathConfiger.CircleEffect.animations[v.category]
					haveAni=true
					break;
				end
				
			end

		end
	end
	local showType=campItem:getController("showType")
	if campNum==0 then
		showType:setSelectedPage("showType1")
	end
	if campNum>0 and campNum<4 then
		showType:setSelectedPage("showType2")
		for i = 1, 3 do
			local childItem=campItem:getChildAutoType("camp"..i)
			childItem:getChildAutoType("frame"):setURL("")
			childItem:getChildAutoType("activaCount"):setText("")
			childItem:getChildAutoType("activaFrame"):setVisible(false)
			if i==1 then
				childItem:getChildAutoType("category"):setURL("")
			end
		end
		local k=1
		for category, v in pairs(temp2) do
			local icon,frame= PathConfiger.getCampIconAFrame(v.category)
			local childItem=campItem:getChildAutoType("camp"..k)
			childItem:getChildAutoType("frame"):setURL(frame)
			childItem:getChildAutoType("activaCount"):setText(v.num)
			childItem:getChildAutoType("activaFrame"):setVisible(true)
			if k==1  then
				childItem:getChildAutoType("category"):setURL(icon)
			end
			
			k=k+1
		end
	end
	if campNum>3 then
		showType:setSelectedPage("showType3")
		local showType3=campItem:getChildAutoType("showType3")
		showType3:setItemRenderer(function(index,childItem)
				local campData=temp2[index+1]
				local icon,frame= PathConfiger.getCampIconAFrame(campData.category)
				childItem:getChildAutoType("frame"):setURL(frame)
				childItem:getChildAutoType("activaCount"):setText(campData.num)
					
				
		end)
		showType3:setNumItems(campNum)
	end

    if haveAni and not inBattle then
		campItem.fxEfect:setAnimation(0,playAniName,true)
		campItem.fxEfect:setVisible(true)
		campItem.lastAimation=playAniName
		GlobalUtil.delayCall(function()end,function ()
				if not tolua.isnull(campItem.fxEfect) then
					campItem.fxEfect:setVisible(campItem.lastAimation~=playAniName)
				end
		end,3,1)
		haveAni=false
	end
	
	campItem.campTable={}
	for k, v in pairs(temp2) do
		campItem.campTable[v.category]=v
	end
	
end




--获取加速配置
function BattleModel:getSpeedModule()
	local spConfig=DynamicConfigData.t_FightSpeed
	local tip=nil
	--local unLockSpeed=0
	local unLockInfor={}
	unLockInfor.unLockSpeed=0
	for k, v in ipairs(spConfig) do
		 local open=ModuleUtil.moduleOpen(v.moduleID,false)
		 if open then
			unLockInfor.unLockSpeed=v.speed
			unLockInfor.moduleID=v.moduleID
			unLockInfor.unLockAll=k==#spConfig
		 else
			tip=ModuleUtil.getModuleOpenTips(v.moduleID)
			tip=tip.."解锁"..v.speed.."倍速"
			break;
		 end 
		 v.open=open
	end
	unLockInfor.nextOpenTip=tip
	return spConfig,unLockInfor
end


function BattleModel:redCheck()
	GlobalUtil.delayCallOnce("BattleModel:redCheck",function()
			self:updateRed()
		end, self, 0.1)
end

function BattleModel:updateRed()
	local lastSpeed=self:getUnLockSpeed()
	self.recordSpeed=lastSpeed
	for k, v in ipairs(DynamicConfigData.t_FightSpeed) do
		--local open=ModuleUtil.moduleOpen(v.moduleID,false)
		RedManager.updateValue("V_unlockSpeed"..v.moduleID,v.speed>lastSpeed)
	end
end


--打开界面设置当前解锁的最高速度
function BattleModel:setUnLockSpeed(value)
	self.recordSpeed=value
	FileCacheManager.setIntForKey(PlayerModel.userid..FileDataType.UNLOCKSPPEDSETTING,value,nil,true)
end


--获取上次解锁的最高速度
function BattleModel:getUnLockSpeed()
	return  FileCacheManager.getIntForKey(PlayerModel.userid..FileDataType.UNLOCKSPPEDSETTING,0,nil,true)
end




--获取加速配置
function BattleModel:getRecommendInfo()
	local helpConfig=DynamicConfigData.t_HelpTips
	local rdInfo={}
	for k, v in pairs(helpConfig) do
		local open=ModuleUtil.moduleOpen(v.jump,false)
		if open or v.type== 0 then
             table.insert(rdInfo,v)	
		end
	end
	local r_index= math.random(1,#rdInfo)
    return rdInfo[r_index]
end





return  BattleModel