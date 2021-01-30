
---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-13 19:30:46
---------------------------------------------------------------------
-- 战斗模块的modle
--
---@class ArrayBaseModel
local BattleConfiger = require "Game.ConfigReaders.BattleConfiger"--读取战斗配表
local BaseModel=require "Game.FMVC.Core.BaseModel"
local RedConst = require "Game.Consts.RedConst"
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local ArrayBaseModel = class("ArrayBaseModel",BaseModel)


ArrayBaseModel.SeatType =
{
	front={{GameDef.FightRowPos.Front*10+1,GameDef.FightRowPos.Front*10+3},{GameDef.FightRowPos.Back*10+1,GameDef.FightRowPos.Back*10+3}},--上阵前后排阵容
	replace={{GameDef.FightRowPos.Replace*10+1,GameDef.FightRowPos.Replace*10+2}}, --替补阵容
	godArms={{GameDef.FightRowPos.GodArms*10+1,GameDef.FightRowPos.GodArms*10+3}}, --迷武
	spirit={{GameDef.FightRowPos.Elf*10+1,GameDef.FightRowPos.Elf*10+3}}, --精灵
}

ArrayBaseModel.HeroPos =
{
	player={pos=100,name="L_"}, --玩家的信息
	enemy ={pos=200,name="R_"},
}
ArrayBaseModel.battleSpeed =
{
	[1]=1.2,--
	[2]=1.75,--填2实际上是1.75倍
	[3]=2.5,--
	[4]=3--
}





function ArrayBaseModel:ctor()

	self.__gameSpeed=1
	self.__arrayInfos={}--备战界面的我方和地方的阵容信息
	self.__seatInfos={}         --选择的作战英雄队列
	self.__enemyInfos={}        --敌方作战英雄队列
	self.__fightHeroLists={}    --作战双方的英雄信息
	self.__pushIndex=1          --需要放入卡牌的位置索引
	self.__battleData={}        --所有回合的战报信息
	self.__battleQueues=Queue.new()
	self.__requestArrayInfos={}
	self.__arrayEnemyInfos={}--敌方阵容的战前配置
	self.__heroInfos={}      --可上阵的卡牌信息
	self.__CardsCategory={}
	self.__myfightCamp=0--我方战力
	self.__mapConfig=false     --当前玩法配置数据
	self.__MapInfo={}         --战斗场景数据
	self.__dragData={index=0,overIndex=0}

	self.__mapPoints={
		center=false,
		enemyCenter=false,
		playerCenter=false,
		arrayCenter=false,
		allHurtTip=false
	}--地图上各种攻击点的位置

	self.roundNum=0
	self.rollOverFx=false --保存一个拖拽特效用
	self.batchRequest=false --录像库功能RecordCell 批量请求一堆历史战斗 这时候不需要显示窗口
	
	self.__gameLockSpeed=1 --花钱解锁的额外速度
	
	
end



function ArrayBaseModel:setSeatInfos(seatInfos)
	self.__seatInfos=seatInfos
end

function ArrayBaseModel: getSeatInfos()
	return self.__seatInfos
end

function ArrayBaseModel:setEnemySeatInfos(enemyInfos)
	self.__enemyInfos=enemyInfos
end

function ArrayBaseModel:getEnemySeatInfos()
	return self.__enemyInfos
end

function ArrayBaseModel:addFightCamp(value)
	self.__myfightCamp= self.__myfightCamp+value
	Dispatcher.dispatchEvent(EventType.battle_refightCamp)
end

function ArrayBaseModel:getFightCamp(value)
	return  self.__myfightCamp
end



--当前拖放数据
function ArrayBaseModel:setDragData(dragData)
	self.__dragData=dragData
end
--当前拖放数据
function ArrayBaseModel:getDragData()
	return self.__dragData
end

--划分区域管理换阵操作触控区
function ArrayBaseModel:getDropIndex(pos)

	local rawRange ={[1]={100,309},[2]={310,409},[3]={410,640}}
	local rowRange ={[1]=350,[2]=300,[3]=200}
	local rawIndex=0
	local rowIndex=0
    for k, range in pairs(rawRange) do
		 if pos.y>range[1] and pos.y<=range[2] then
			 rowIndex=k
			 rawIndex=k
		 end
	end
	if rowIndex==0 or pos.x>680  then
		return false
	end
	if pos.x<rowRange[rowIndex] then
		rowIndex=2
	else
		rowIndex=1
	end
	return rowIndex*10+rawIndex
	
end


--#获取敌方配置信息
--.arrayEnemyInfos {
--heroInfos              1:integer               #敌方阵容数据
--combat                 2:integer               #敌方总战力
--array                  3:BattleArrayPos(uuid)  #我们默认上阵配置
--}
function ArrayBaseModel:getEnemyArrayInfo()
	return self.__arrayEnemyInfos
end


--所有回合动画队列
function ArrayBaseModel:clearQuese(func)
	self.__battleQueues=Queue.new()
end

--所有回合动画队列
function ArrayBaseModel:pushAckerQues(func)
	self.__battleQueues:enqueue(func)
end

--逐个播放战报
function ArrayBaseModel:playBattleInQue(info)
	local attackerFun= self.__battleQueues:dequeue()
	if attackerFun then
		attackerFun();
		print(086,"attackerFun=>",attackerFun)
	end
	if info then
		--rint(086,"本轮出手信息=>"..info)
	end
end


--更新所有回合的战报信息
function ArrayBaseModel:updateBettleData(battleData)
	self.__battleData=battleData
end

--所有回合的战报信息
function ArrayBaseModel:getBettleData()
	return self.__battleData
end






----更新所有回合的战报信息
--function ArrayBaseModel:updateRecordData(battleData)
	--self.__battleData=battleData
--end

----所有回合的战报信息
--function ArrayBaseModel:getRecorData()
	--return self.__battleData
--end






--输出最高的英雄 type = 1我方 type = 2敌方 3全部
function ArrayBaseModel:getMVPHero(type,battleObjSeq)
	local maxHurt=-1
	local heroInfo=nil
	local heroType = type or 1
	if battleObjSeq  then
		for i, battleObjSeq in pairs(battleObjSeq) do
			if battleObjSeq.hurt and battleObjSeq.type then
				if maxHurt<battleObjSeq.hurt and (heroType == 3 or battleObjSeq.type == heroType) and battleObjSeq.id < BattleModel.HeroPos.enemy.pos then
					maxHurt=battleObjSeq.hurt
					heroInfo=battleObjSeq
				end
			end
		end
	end
	return heroInfo
end



function ArrayBaseModel:setRequestArrayInfo(uuid,data)
	--printTable(521,uuid,data)
	if self.prepareArrayType==false then
		return 
	end
	if self.__requestArrayInfos[self.prepareArrayType]==nil then
		self.__requestArrayInfos[self.prepareArrayType]={}
	end
	self.__requestArrayInfos[self.prepareArrayType][uuid]=data
	printTable(526,"阵容保存信息更新了",self.__requestArrayInfos)
end

function ArrayBaseModel:getRequestArrayInfo(arrayType)
	return  self.__requestArrayInfos[arrayType]
end


function ArrayBaseModel:getLifeHero()
	local temp={}
	for k, v in pairs(self.__fightHeroLists) do
		if  v.isDie==false and v.baseData then
			temp[#temp+1]=v
		end
	end
	return temp
end

function ArrayBaseModel:setHeroItemLists(heroList)
	self.__fightHeroLists=heroList
end
function ArrayBaseModel:getHeroItemLists()
	return  self.__fightHeroLists
end

function ArrayBaseModel:getHeroItemById(index)
	return self.__fightHeroLists[index]
end

--下推战斗配置信息
function ArrayBaseModel:updataArrayInfo(data)
	self.__arrayInfos=data
	--换了阵容，需要重新初始化卡牌红点关系
	RedConst.initCardMap()
	ModelManager.CardLibModel:redCheck()
end



function ArrayBaseModel:setMapInfo(data)
	self.__MapInfo=data
end

function ArrayBaseModel:getMapInfo(data)
	return self.__MapInfo
end

function ArrayBaseModel:getBattleArrayType()
	if not self.__mapConfig then
		return
	end
	return self.__mapConfig.configType
end

--获取正在战斗的玩法
function ArrayBaseModel:getRunArrayType()
	if FsmMachine:getInstance():getBattleState()=="begin" then
		if not self.__mapConfig then
			return false
		end
		return self.__mapConfig.configType
	else
		return false
	end
end

function ArrayBaseModel:setBattleArrayType(arryType)
	
	if self:getRunArrayType() and self:getRunArrayType()~=arryType then
       return 
	end
	
	if not self.__mapConfig then
		self.__mapConfig={configType=arryType}
	end
    self.__mapConfig.configType=arryType
	printTable(0966,self.__mapConfig)
end


function ArrayBaseModel:setBattleConfig(data)
	if data then
		self.__mapConfig=data
		if self:getRunArrayType() then
			self.__mapConfig.configType=self:getRunArrayType()
		end
		if self.__requestArrayInfos[self.__mapConfig.configType]==nil and self.__mapConfig.configType then
			self.__requestArrayInfos[self.__mapConfig.configType]={}
		end
	end
end

function ArrayBaseModel:getBattleConfig()
	return  self.__mapConfig
end


--设置地图点信息
function ArrayBaseModel:setMapPoint(data)
	self.__mapPoints=data
end

--获取地图点信息
function ArrayBaseModel:getMapPoint()
	return  self.__mapPoints
end


--根据座位id 获取座位类型
function ArrayBaseModel:getSeatType(id)
	for typeKey, typeList in pairs(self.SeatType) do
		for k, ranges in ipairs(typeList) do
			for seatId = ranges[1], ranges[2] do
				if seatId==id then
					return typeKey
				end
			end
		end
	end
	return ""
end


--获取根据上阵英雄获取阵营加成信息
function ArrayBaseModel:getCampAddition(heroPos)
	local campCount={}
	local campList={}
	local seatInfo=false
	if heroPos==nil then
		heroPos=self.HeroPos.player
	end

	if heroPos==self.HeroPos.player then
		seatInfo=self.__seatInfos
	else
		seatInfo=self.__enemyInfos
	end
	local anyCamp=0--仙族可以和任意种族加成
	local demon=0--魔族单独加成
	for k, seat in pairs(seatInfo) do
		if seat.category then
			local heroInfo={}
			if seat.heroPos==heroPos then
				if seat.category==1 then
					anyCamp=anyCamp+1
				end
				if seat.category==2 then
					demon=demon+1

				end
				if seat.category>2 then
					if campCount[seat.category]==nil then
						campCount[seat.category]=0
					end
					campCount[seat.category]=campCount[seat.category]+1

				end
			end
		end
	end
	local maxCount={category=3,num=0}
	local secondCount=false
	for k, v in pairs(campCount) do
		local temp={category=k,num=v}
		table.insert(campList,temp)
	end
	table.sort(campList,function (a,b)
			if a.num==b.num then
				return  a.category<b.category
			else
				return a.num>b.num
			end
		end)

	if campList[1] then
		maxCount=campList[1]
		secondCount=campList[2] or false
	else
		campList[1]=maxCount
	end


	if maxCount then
		if maxCount.num<5 then
			if maxCount.num+anyCamp>=5 then
				anyCamp=anyCamp+maxCount.num-5
				maxCount.num=5
			else
				maxCount.num=anyCamp+maxCount.num
				anyCamp=0
			end
		else

			if secondCount ==false then
				secondCount={category=maxCount.category,num=maxCount.num-5}
				table.insert(campList,secondCount)
			end
			maxCount.num=5
		end
	end
	if secondCount then
		secondCount.num=anyCamp+secondCount.num
	end

	if demon>5 then
		table.insert(campList,{category=2,num=5})
		demon=demon-5
	end

	table.insert(campList,{category=2,num=demon})
	--printTable(086,campList,"campList")
	return  campList
end

--查看种族的激活信息
function ArrayBaseModel:getCampActivation(heroPos)
	local campCount={}
	local seatInfo=false
	if heroPos==nil then
		heroPos=self.HeroPos.player
	end

	if heroPos==self.HeroPos.player then
		seatInfo=self.__seatInfos
	else
		seatInfo=self.__enemyInfos
	end
	for k, seat in pairs(seatInfo) do
		if seat.category then
			local heroInfo={}
			if seat.heroPos==heroPos then
				if campCount[seat.category]==nil then
					campCount[seat.category]=0
				end
				campCount[seat.category]=campCount[seat.category]+1
			end
		end
	end
	local sorCampCount={}
	for category, v in pairs(campCount) do
		  if v>1 then
			sorCampCount[category]=v
		  end
	end

	return sorCampCount
end

--根据历史战报获取阵营加成信息
function ArrayBaseModel:getCampAddInBattelData(heroPos)
	if heroPos==nil then
		heroPos=self.HeroPos.player
	end
	local side=1
	if heroPos==self.HeroPos.enemy then
		side=2
	end
	local campList={}
	local battleData=FightManager.getBettleData(FightManager.frontArrayType())

	if battleData.campAddDataSeq then
		for k, v in pairs(battleData.campAddDataSeq) do
			if v.side==side then
				campList=v.categoryDataSeq
			end
		end
	end
	return campList

end


--将卡牌置入首选的一个空位
function ArrayBaseModel:getLateSeat()
	print(0866,"最近位置",self.__pushIndex)
	printTable(521,self.__seatInfos)
	local seat=self.__seatInfos[self.__pushIndex]
	return seat
end

--将卡牌置入首选的一个空位
function ArrayBaseModel:getSeatById(seatID)
	for k, v in pairs(self.__seatInfos) do
		if v.seatId== seatID then
			return  v
		end
	end
end



function ArrayBaseModel:getSeatByuuid(uuid)
	local tag=false
	for k, v in pairs(self.__seatInfos) do
		if v.uuid==uuid then
			return v
		end
	end

end


--设置一个位置的信息
function ArrayBaseModel:fillSeatByIndex(index,isEmpty,campValue)
	local seatItem=self.__seatInfos[index]
	seatItem.isEmpty=isEmpty
	self:addFightCamp(campValue)
	for k, v in ipairs(self.__seatInfos) do
		self.__pushIndex=k
		print(0866,"设置最近的位置为",self.__pushIndex)
		if v.isEmpty then
			return
		end
	end
end


--判断卡牌是否已放置
function ArrayBaseModel:checkCard(uuid)
	local tag=false
	for k, v in pairs(self.__seatInfos) do
		if v.uuid==uuid then
			tag=true
			return tag
		end
	end
	return tag
end

--判断是否有同类卡牌上阵
function ArrayBaseModel:checkPut(heroId)
	local tag=false
	for k, v in pairs(self.__seatInfos) do
		if v.heroId==heroId  then
			tag=true
			return tag
		end
	end
	return tag
end

--
function ArrayBaseModel:hasEmpty(heroId)
	local tag=false
	for k, v in pairs(self.__seatInfos) do
		if v.isEmpty==true  then
			tag=true
			return tag
		end
	end
	return tag
end


function ArrayBaseModel:getBattleHeroNum()
	local num=0
	for k, v in pairs(self.__seatInfos) do
		if v.isEmpty==false  then
			num = num + 1
		end
	end
	return num
end



--获取战斗配置信息
function ArrayBaseModel:getArrayInfo(arrayType , isEmpty)

	printTable(4,self.__arrayInfos,"self.__arrayInfos")
	if not arrayType then
		local battle = {}
		for i,v in pairs(self.__arrayInfos) do
			for k,card in pairs(v.array) do
				battle[k] = card
			end
		end
		return {array = battle}
	end
	if isEmpty==true then
		return self.__arrayInfos[arrayType] or {array={}}
	end
	return self.__arrayInfos[arrayType] or self.__arrayInfos[1]
	--return self.__arrayEnemyInfos.array
end


--判断一个英雄是否出现中
function ArrayBaseModel:isInBattle(uuid, arrayType)
	if not uuid then return false end
	local arrayInfo
	if arrayType then
		arrayInfo = {self:getArrayInfo(arrayType, true)}
	else
		arrayInfo = self.__arrayInfos
	end
	for i,v in pairs(arrayInfo) do
		for k,card in pairs(v.array) do
			if uuid == card.uuid then
				return true
			end
		end
	end
	return false
end

--获取一个卡牌在哪个出战阵容中
function ArrayBaseModel:getArrayType(uuid)
	for i,v in pairs(self.__arrayInfos) do
		for k,card in pairs(v.array) do
			if uuid == card.uuid then
				return i
			end
		end
	end
	return 0
end

--获取一个卡牌在哪些出战阵容中
function ArrayBaseModel:getArrayTypes(uuid)
	local arrayTypes = {}
	for i,v in pairs(self.__arrayInfos) do
		for k,card in pairs(v.array) do
			if uuid == card.uuid then
				table.insert(arrayTypes, i)
			end
		end
	end
	return arrayTypes
end

--下阵处理
function ArrayBaseModel:quitBattle(arrayType, uuid)
	for i,v in pairs(self.__arrayInfos) do
		local array = self.__arrayInfos[arrayType].array
		for k,card in pairs(array) do
			if uuid == card.uuid then
				array[k] = nil
				return
			end
		end
	end
	RedConst.initCardMap()
	ModelManager.CardLibModel:redCheck()
	return 0
end


--回合结束后清理一下buff回合数
function ArrayBaseModel:roundEnd()
	for k, v in pairs(self.__fightHeroLists) do
		if v.buffBase then
			local buffList= v.buffBase:getBuff()
			for k, buffData in pairs(buffList) do
				buffData.round=buffData.round-1
				if buffData.round==0 then
					--v.buffBase:removeBuff({[1]=buffData.id})
					--Dispatcher.dispatchEvent(EventType.battle_buffUpdate  , {index=k} )
				end
			end
		end
	end

end

--更新buff处理
--添加Buff
--id 是位置id
function ArrayBaseModel:addBuff(id , buffs)
	--映射关系 id关联相关buff列表

	local target=self:getHeroItemById(id)
	
	if target.buffBase then
		target.buffBase:addBuff(buffs)
		Dispatcher.dispatchEvent(EventType.battle_buffUpdate  , {index=id} )
	end
end


function ArrayBaseModel:refeashBuff(id , buffs)
	--映射关系 id关联相关buff列表

	local target=self:getHeroItemById(id)

	if target.buffBase then
		target.buffBase:refeashBuff(buffs)
	end
end



function ArrayBaseModel:addConnectBuff(id,targetId, buffs)
	--映射关系 id关联相关buff列表
	local target=self:getHeroItemById(id)
	target.buffBase:addConnectBuff(buffs)
end


--移除buff
function ArrayBaseModel:removeBuff(id, buffs)
	local target=self:getHeroItemById(id)
	if target.buffBase then
		target.buffBase:removeBuff(buffs)
		Dispatcher.dispatchEvent(EventType.battle_buffUpdate  , {index=id} )
	end
end


--替补上场时，交换buff位置
--id          1:integer          #替补位置
--replaceId   2:integer          #场上位置
function ArrayBaseModel:exchangeBuff(id , replaceId)

	local preTarget=self:getHeroItemById(replaceId)
	if preTarget and preTarget.buffBase then
		preTarget.buffBase:exchangeBuff(id)
	end
end

--角色死亡时，清理相关位置buff数据
function ArrayBaseModel:resetBuff(id)
	-- self.__buffData[ id ] = nil
end

--获取位置的buff信息
function ArrayBaseModel:getBuff(id)
	local target=self:getHeroItemById(id)
	if target.buffBase then
		return target.buffBase:getBuff()
	end
end



function ArrayBaseModel:starSort(temp)
	
	local sortConfig={"level","star","combat"}
	local test = self:getBattleArrayType()
	if self:getBattleArrayType() == GameDef.BattleArrayType.HolidayBoss then
		local func = function(a,b)
			local flag1 = ActCommonBossModel:checkIdInArray(a.code)
			local flag2 = ActCommonBossModel:checkIdInArray(b.code)
			local status1 = 0
			local status2 = 0
			if flag1  then
				status1 = 1
			end
			if flag2  then
				status2 = 1
			end
			if status1 == status2 then
				if a[sortConfig[1]]==b[sortConfig[1]] then
					if a[sortConfig[2]] ==b[sortConfig[2]] then
						return a[sortConfig[3]] >b[sortConfig[3]]
					else
						return a[sortConfig[2]]>b[sortConfig[2]]
					end
				else
					return a[sortConfig[1]]>b[sortConfig[1]]
				end
			else
				return status1>status2
			end
		end
        table.sort(temp,func)
	else
		table.sort(temp,function(a,b)
			if a.hp and b.hp then
				local status1 = 1
				local status2 = 1
				if a.hp<=0 then
					status1 = 0
				end
				if b.hp<=0 then
					status2 = 0
				end
				if status1 ==status2 then
					if a[sortConfig[1]]==b[sortConfig[1]] then
						if a[sortConfig[2]] ==b[sortConfig[2]] then
							return a[sortConfig[3]] >b[sortConfig[3]]
						else
							return a[sortConfig[2]]>b[sortConfig[2]]
						end
					else
						return a[sortConfig[1]]>b[sortConfig[1]]
					end
				else
					return status1>status2
				end
			else
				if a[sortConfig[1]]==b[sortConfig[1]] then
					if a[sortConfig[2]] ==b[sortConfig[2]] then
						return a[sortConfig[3]] >b[sortConfig[3]]
					else
						return a[sortConfig[2]]>b[sortConfig[2]]
					end
				else
					return a[sortConfig[1]]>b[sortConfig[1]]
				end
			end
		end)
	end
	return temp;
end




--request获取战前地图配置和当前玩法的默认阵容
function ArrayBaseModel:requestMapInfo(mapConfig,func)

	local requseInfo={}
	if mapConfig.playerId then --有玩家ID证明是竞技场
		requseInfo={
			fightId	=0,
			playerId=mapConfig.playerId,
			gamePlay=mapConfig.configType,
			serverId = mapConfig.serverId and mapConfig.serverId or 0
		}
	else
		requseInfo={
			fightId	=mapConfig.fightID,
			playerId=0,
			gamePlay=mapConfig.configType,
			index=mapConfig.index,
			exParam=mapConfig.exParam
		}
	end
	local function success(data)
		if mapConfig and mapConfig.vocationLimit and mapConfig.vocation then --职业限制自动下阵
			data = self:categoryLimitHander(data,mapConfig)
		end
		self.__arrayEnemyInfos=data
		if func then
			func(data)
		end
	end
	RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end

function ArrayBaseModel:categoryLimitHander(data,mapConfig)
	if not data.array then
		return data
	end
	for key,value in pairs(data.array) do
		local state = false
		local heroInfo = ModelManager.CardLibModel:getHeroByUid(value.uuid)
		for k,v in pairs(mapConfig.vocation) do
			if v == heroInfo.heroDataConfiger.professional then
				state = true
			end
		end
		if not state then
			data.array[key] = nil
		end
	end
	local complementList = {}
	for key,value in pairs(data.array) do
		if value.id >= 31 then--替补往前面补
			table.insert(complementList,value)
		end
	end
	if #complementList ~= 0 and #data.array - #complementList < 6 then --替补有人且需要补位
		local absentId = {}
		for i = 1,2 do
			for j = 1,3 do
				local state = false
				for key,value in pairs(data.array) do
					if value.id == i * 10 + j and not state then
						state = true
					end
				end
				if not state then
					table.insert(absentId,i * 10 + j)
				end
			end
		end
		for key,value in pairs(complementList) do
			if absentId[key] then
				value.id = absentId[key]
			end
		end
	end
	return data
end

--request获取战斗记录  
function ArrayBaseModel:requestBattleRecord(recordId,func,gamePlayType,serverId,batchRequest)--
	if gamePlayType and not self:getRunArrayType() then
		BattleModel:setBattleArrayType(gamePlayType)
	end
	local function success(data)
		if func then
			func()
		end
	end
	local info={
		recordId=recordId,
	}
	if gamePlayType then
		info.gamePlayType = gamePlayType
	end

	if serverId then
		info.serverId = serverId
	end
	if not batchRequest then
		self.batchRequest=false
	else
		self.batchRequest=true
	end

	RPCReq.Battle_GetBattleRecord(info,success)
end



function ArrayBaseModel:changeGameSpeed(value,inBattle)
	if value then		
		SoundManager.setSoundSpeed(value)
		local spV=0
		if inBattle then
			spV=self:getSpViewSetting()
			SoundManager.setSoundSpeed(value+spV) --插件加速 声音也要同步
		end
		cc.Director:getInstance():getScheduler():setTimeScale(value+spV)
		self.__gameSpeed=value
	else
		if self.__gameSpeed==1 then
			self.__gameSpeed=1.5
		else
			self.__gameSpeed=1
		end
		SoundManager.setSoundSpeed(1)
		cc.Director:getInstance():getScheduler():setTimeScale(self.__gameSpeed)
	end
end

function ArrayBaseModel:changeSpeedIndex(speedIndex,backNormal)
	self.__gameSpeed=self.battleSpeed[speedIndex] or 1
	SoundManager.setSoundSpeed(speedIndex)
	local spV=0
	if not backNormal then
		spV=self:getSpViewSetting()
		if not speedIndex then
			speedIndex=0
		end
		SoundManager.setSoundSpeed(speedIndex+spV)
	end
	cc.Director:getInstance():getScheduler():setTimeScale(self.__gameSpeed+spV)
end

function ArrayBaseModel:updateGameSpeed()
	local  frontType=FightManager.frontArrayType()
	if frontType then
		local spV=self:getSpViewSetting()
	    cc.Director:getInstance():getScheduler():setTimeScale(self.__gameSpeed+spV)
	end

end


function ArrayBaseModel:getSpeedIndex()
	return  self.__gameSpeed
end


function ArrayBaseModel:saveGameSpeed(value)
	if value then
		FileCacheManager.setIntForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPED,value,nil,true)
	else
		FileCacheManager.setIntForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPED,self.__gameSpeed,nil,true)
	end

end

function ArrayBaseModel:getGameSpeed()
	return  FileCacheManager.getIntForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPED,self.__gameSpeed,nil,true)
end


function ArrayBaseModel:saveOpenSpeed()
	FileCacheManager.setBoolForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPEDX2,ModuleUtil.moduleOpen(ModuleId.BattleSpeed.id,true),false,false)
	FileCacheManager.setBoolForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPEDX3,ModuleUtil.moduleOpen(ModuleId.BattleSpeed3.id,true),false,false)
end


function ArrayBaseModel:getSpViewSetting()
	return  FileCacheManager.getIntForKey(PlayerModel.userid..FileDataType.BATTELESPPEDSETTING,self.__gameLockSpeed,nil,true)
end


function ArrayBaseModel:saveSpViewSetting(value)
	FileCacheManager.setIntForKey(PlayerModel.userid..FileDataType.BATTELESPPEDSETTING,value,nil,true)
end


function ArrayBaseModel:checkOpenSpeedFx()
	local x2= ModuleUtil.moduleOpen(ModuleId.BattleSpeed.id,false)
	local x3= ModuleUtil.moduleOpen(ModuleId.BattleSpeed3.id,false)
	return  (x2 and  FileCacheManager.getBoolForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPEDX2,false,false,false)==false) or (x3 and FileCacheManager.getBoolForKey(PlayerModel.userid..FileDataType.BATTELEGAMESPPEDX3,false,false,false)==false)
end


--根据配置类型生成战报
function ArrayBaseModel:creatBattleData(config)

	local battleData={}
	local configData=config or DynamicConfigData.FightConfig

	battleData.battleObjSeq={}
	for k, heroInfo in ipairs(configData.hero) do
		local heroObj={}
		heroObj.cure=heroInfo.hp
		heroObj.code=heroInfo.id
		heroObj.hpMax=heroInfo.hp
		heroObj.id=heroInfo.pos
		heroObj.hp=heroInfo.hp
		heroObj.level=heroInfo.level or 1
		heroObj.scale=heroInfo.scale or 1
		heroObj.type=heroInfo.type or 1
		heroObj.hurt=heroInfo.hurt or 999
		heroObj.cure=heroInfo.cure or 1
		heroObj.beHurt=heroInfo.beHurt or 999
		--hurt=1320,cure=0,beHurt=2519
		table.insert(battleData.battleObjSeq,heroObj)
	end

	if configData.background then
		battleData.background=configData.background
	end

	if configData.gameBegin then
		battleData.gameBegin=configData.gameBegin
	end

	if configData.gameEnd then
		battleData.gameEnd=configData.gameEnd
	end
	if configData.speed then
		battleData.speed=configData.speed or 2
	end
	if configData.skip==false then
		battleData.skip=configData.skip
	end

	battleData.roundDataSeq={}
	for roundNum, roundData in ipairs(configData.round) do
		local roundDataSeq={}
		roundDataSeq.dataSeq={}
		roundDataSeq.heroDataSeq={}
		roundDataSeq.roundStartSeq={}
		roundDataSeq.addHeroData={}
		if configData.enemy and configData.enemy[roundNum] then
			printTable(0933,configData.enemy[roundNum],"configData.enemy[roundNum])")
			for k, rData in pairs(configData.enemy[roundNum]) do
				local heroObj={}
				heroObj.cure=rData.hp
				heroObj.code=rData.id
				heroObj.hpMax=rData.hp
				heroObj.id=rData.pos
				heroObj.hp=rData.hp
				heroObj.level=rData.level or 1
				heroObj.scale=rData.scale or 1
				heroObj.type=2
				heroObj.hurt=rData.hurt or 999
				heroObj.cure=rData.cure or 1
				heroObj.beHurt=rData.beHurt or 999
				heroObj.deLayShow=true
				table.insert(roundDataSeq.addHeroData,heroObj)
				table.insert(battleData.battleObjSeq,heroObj)
			end
		end
		if configData.addHero and  configData.addHero[roundNum] then
			for k, rData in pairs(configData.addHero[roundNum]) do
				local heroObj={}
				heroObj.cure=rData.hp
				heroObj.code=rData.id
				heroObj.hpMax=rData.hp
				heroObj.id=rData.pos
				heroObj.hp=rData.hp
				heroObj.level=rData.level or 1
				heroObj.scale=rData.scale or 1
				heroObj.type=1
				heroObj.hurt=rData.hurt or 999
				heroObj.cure=rData.cure or 1
				heroObj.beHurt=rData.beHurt or 999
				heroObj.deLayShow=true
				table.insert(roundDataSeq.addHeroData,heroObj)
				table.insert(battleData.battleObjSeq,heroObj)
			end
		end
		if configData.playFilm and configData.playFilm[roundNum] then
			roundDataSeq.playFilm=configData.playFilm[roundNum]
		end

		roundDataSeq.replaceDataSeq={}
		for k, fightData in ipairs(roundData) do  --一个人的出手
			local dataSeq={}
			dataSeq.replaceDataSeq={}
			dataSeq.fightObjDataSeq={}
			local skillEffectSeqs={}
			for k, target in pairs(fightData.pos2) do --出手选择的多个目标
				local skillEffectSeq={}
				skillEffectSeq.id=fightData.pos2[k]
				skillEffectSeq.value={}  --默认一段伤害
				skillEffectSeq.status=fightData.status[k]
				local skillData=SkillConfiger.getSkillById(fightData.skillid)
				local activeSkill = skillData.activeSkill[1]
				local activeData = DynamicConfigData.t_activeSkill[activeSkill]
				for i = 1, #activeData.skillEffect do
					table.insert(skillEffectSeq.value,math.floor(fightData.subHp[k]/#activeData.skillEffect))
				end
				skillEffectSeq.skill=activeSkill
				table.insert(skillEffectSeqs,skillEffectSeq)

			end
			local fightObjDataSeq={
				skillEffectSeq=skillEffectSeqs,
				id=fightData.pos1,
				skill=fightData.skillid,
			}
			------------buff
			fightObjDataSeq.buffEffect={}
			if fightData.buff then  --出手前增加buff
				self:creatBuffData(fightData.buff,"buff",fightObjDataSeq.buffEffect)
			end
			if fightData.removeBuff then  --出手前增加buff
				self:creatBuffData(fightData.removeBuff,"removeBuff",fightObjDataSeq.buffEffect)
			end
			fightObjDataSeq.buffEffectEx={}
			if fightData.hitBuff then
				self:creatBuffData(fightData.hitBuff,"buff",fightObjDataSeq.buffEffectEx)
			end
			if fightData.hitRemoveBuff then  --出手前增加buff
				self:creatBuffData(fightData.hitRemoveBuff,"removeBuff",fightObjDataSeq.buffEffectEx)
			end
			------------buff

			if fightData.text then
				fightObjDataSeq.talking=fightData.text
			end

			dataSeq.fightObjDataSeq[1]=fightObjDataSeq
			table.insert(roundDataSeq.dataSeq,dataSeq)
		end
		table.insert(battleData.roundDataSeq,roundDataSeq)
	end

	return battleData
end







function ArrayBaseModel:creatSkillData(attackerID,targetID,skillId,buffId)
	local skill=skillId
	local fightObjData={
		skillEffectSeq={
			[1]={
				value={
				},
				buffEffect={
					buff={
						[1]={
							buffId=buffId or 111,
							round=2,
							id=1,
							contactIds={
								[1]=221
							}

						},
					}
				},
         		--status=GameDef.ShowEffectType.Crit,
				skill=24002311,
				id=targetID,
			},
		},
		
		
		id=attackerID,
		skill=skill,
		buffShield=0,
	}

	if not buffId then
		fightObjData.skillEffectSeq[1].buffEffect=nil
	end
	local rBuffs={
		[1]=1

	}
	BattleModel:removeBuff(targetID,rBuffs)
	rBuffs={
		[1]=1,
	}
	BattleModel:removeBuff(attackerID,rBuffs)
	local skillInfo=SkillConfiger.getSkillById(skill)
	fightObjData.skillEffectSeq[1].skill=skillInfo.activeSkill[1] or 55004110
	local activeSkill = DynamicConfigData.t_activeSkill[fightObjData.skillEffectSeq[1].skill]
	if activeSkill.enemy == 1 then 
		local eventCount=#activeSkill.skillEffect
		for i = 1, eventCount do
			local hurtValue=-i*100000
			table.insert(fightObjData.skillEffectSeq[1].value,hurtValue)
		end
	end
	return fightObjData
end


--创建战斗spine
function ArrayBaseModel:creatFightItem(index,heroId,fashionId,parent,heroPos)
	local testData={
		cure=0,
		code=heroId,
		fashion=fashionId,
		id=index,
		hp=800,
		hpMax=800,
		hurt=200,
		addShield=300,
		level=999,
	}
	local L_item=BindManager.bindFightItem(parent)
	L_item.index=testData.id
	L_item.heroPos=heroPos or self.HeroPos.player
	L_item:setData(testData,nil,true)
	local heroList=self:getHeroItemLists()
	heroList[index]=L_item
	self:setHeroItemLists(heroList)
	return L_item
end








function ArrayBaseModel:creatBuffData(buffs,key,buffEffec)

	for k, v in pairs(buffs) do
		local BuffEffectData={}
		local buffData={}
		buffData.id=v.buffId
		buffData.buffId=v.buffId
		buffData.round=DynamicConfigData.t_buff[v.buffId].round
		BuffEffectData[key]={}
		BuffEffectData[key][1]=buffData
		BuffEffectData.id=v.id
		table.insert(buffEffec,BuffEffectData)
	end
end


--游戏结束
function ArrayBaseModel:endGame()
	if ArrayBaseModel then
		for k, v in pairs(self.__fightHeroLists) do
			if v.exit then
				v:exit();
			end
		end
	end
	SpineMnange.clearPool()--清楚spine角色缓存
	self:reInit()
end


--再次打开界面的时候清理
function ArrayBaseModel:reInit()
	self.__myfightCamp=0
	--self.__battleData={}        --所有回合的战报信息
	--self.__fightHeroLists={}    --作战双方的英雄信息
	self.__seatInfos={}
	self.__requestArrayInfos={}
	self.__heroInfos={}
	self.__CardsCategory={}
	self.__pushIndex=1
	--self.roundNum=0
end


--重新登录的时候清理
function ArrayBaseModel:clear()

	self.__seatInfos={}         --选择的作战英雄队列
	self.__fightHeroLists={}    --作战双方的英雄信息
	self.__pushIndex=1          --需要放入卡牌的位置索引
	self.__battleData={}        --所有回合的战报信息
	self.__requestArrayInfos={}
	self.__battleQueues=Queue.new()--战报队列
	self.__heroInfos={}
	self.__CardsCategory={}
	self.__mapConfig=false
	self.roundNum=0
	BattleManager:getInstance():cleansup(true)--清理战斗数据
	for k, v in pairs(self:getSeatInfos()) do--重连的情况清理备战界资源
		v:exit()
	end

end

return  ArrayBaseModel


