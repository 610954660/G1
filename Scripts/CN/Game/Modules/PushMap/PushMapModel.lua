
local BaseModel = require "Game.FMVC.Core.BaseModel"
local PushMapModel = class("PushMapModel", BaseModel)

function PushMapModel:ctor()
	print(33,"PushMapModel ctor")
	self.curOnhookInfo={}
	self.pushMapWorldcityInfo={}
	self.pushMapListInfo={}
	self.pushMaponHookInfo={}
	self.showPushmapmofangTime={}
	self.isWin=false;
	self.reward={};
	self.point =false	--# 最新章节
	self.level =false	--# 最新关卡
	self.city =false	--# 最新城市
	self.star =false	--# 最新星数
	self.starList={}--当前星数完成列表
	self.pushMapRedList={}  --红点列表
	self.targetRewardGuankaReward={}
	self.firstTenGuanka=false
	self.modulefirstPass=false
	self.battleCity={}
	self.jumpEnterState=false
	self.schedulerID=false
	self.chapterRewardViewParameter={}
	self.isShowCohesionView=false--在过场云后显示挂机奖励界面
 	self.jingbiTime={}
	self.jingbiRandom={}
	self.jingbiRunState={}
	self.barAnimationID=false
	self.isBarShowed=false
	self.pushmapRewardGuajiCache=0
	
	
	self.powerCurNodeId=1  --异能计划当前解锁的关卡
	self.powerPlantInfo=false
end



function PushMapModel:init()
	
end



function PushMapModel:getAllLevel()
	return #DynamicConfigData.t_TalentProjectGame
end




--获取推图里面异能计划的奖励
function PushMapModel:getPeriodReward()
	local rewardConfig=DynamicConfigData.t_TPStatgeReward
	for k, v in pairs(rewardConfig) do
		v.status=1
		if v.nodeId<self.powerCurNodeId then
			v.status=2
		end
		--local nodeInfo=v
		if self.powerPlantInfo and next(self.powerPlantInfo.myInfo.recvMap)~=nil then
			for k2, recvNodeInfo in pairs(self.powerPlantInfo.myInfo.recvMap) do
				 --print(5656,nodeId,"getPeriodReward")
				 if recvNodeInfo.nodeId==v.nodeId then
					v.status=0
				 end
			end
		end
	end
	TableUtil.sortByMap(rewardConfig, {{key="status", asc=true},{key="nodeId", asc=false}});
	
	return rewardConfig
end


function PushMapModel:powerGetChallTimes()
	return DynamicConfigData.t_TalentProjectConst[1].challengeTimes
end

function PushMapModel:checkBeginFight(finished)

	if self:getCheckTips() then
		finished()
		return
	end
	local info = {}
	info.text = Desc.powerPlant_desc7
	info.mask = true
	info.type = "yes_no"
	info.check=true
	info.onYes = function(isCheck)
		self:setCheckTips(isCheck)
		finished()
	end
	info.onNo = function(isCheck)
		self:setCheckTips(isCheck)
	end
	Alert.show(info)
end



function PushMapModel:setCheckTips(isCheck)
	local dayStr = DateUtil.getOppostieDays()
	local index = isCheck  and  1 or 0
	FileCacheManager.setIntForKey("powerPlant_isCheckTips" .. dayStr,index)
end



function PushMapModel:getCheckTips()
	local dayStr = DateUtil.getOppostieDays()
	return FileCacheManager.getIntForKey("powerPlant_isCheckTips" .. dayStr,0)==1
end




--#异能的所有信息
function PushMapModel:powerPlanGetInfo(finished)
	RPCReq.PowerPlan_GetInfo({},function (data)
		if finished then
		   printTable(5656,"异能计划",data)	
		   self.powerPlantInfo=data
		   self.powerCurNodeId=data.nodeInfo.nodeId
		   finished(data)
		end
	end)
end


--#异能开始挑战
function PushMapModel:powerPlanDoFight(nodeId,bossId,dif)
	local mapConfig={
		fightID = bossId,
		configType = GameDef.battleArrayType.PowerPlan,
		exParam = dif,
		index  =nodeId,
	}
	--local fightData = DynamicConfigData.t_fight[bossId]
	Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
			if eventName == "begin" then
				local params={
					nodeId = nodeId,
					bossId =bossId,
					dif    =dif,
				}
				local success=function(data)
					printTable(5656,"挑战返回",data)
				end
				RPCReq.PowerPlan_DoFight(params,success)
			elseif eventName == "end" then
				local battleData=RewardModel:getBattleData() or RewardModel:getSkipBattleData(RewardModel:getArrayType())
				if battleData.result==false then
					ViewManager.open("ReWardView",{page=0,isWin=battleData.result,showLose=true})
				end
				--ViewManager.open("ReWardView",{page=0,isWin=battleData.result,showLose=true})
				Dispatcher.dispatchEvent(EventType.PowerPlan_updateData)
			end
	end,mapConfig)
end


--异能计划领取阶段奖励
function PushMapModel:powerPlanRecvReward(nodeId,finished)
	local params={
		nodeId = nodeId,
	}
	local success=function(data)
		printTable(5656,"领奖返回",data)
		if finished then
			finished()
		end
	end
	RPCReq.PowerPlan_RecvReward(params,success)
end


function PushMapModel:powerPlanGetRecords(nodeId,finished)
	local params={
		rankType=GameDef.RankType.PowerPlan,	
		collectionId = nodeId,
	}
	local success=function(data)
		printTable(5656,"获取记录返回",data)
		if finished then
			finished(data)
		end
	end
	RPCReq.Rank_GetRankData(params,success)
	
end





function PushMapModel:getMonsterByBossId( bossId,monsterIndex )
	local monsterInfo = {}
	if DynamicConfigData.t_fight[bossId]["monsterId"..monsterIndex] then
		monsterInfo.code = DynamicConfigData.t_fight[bossId]["monsterId"..monsterIndex]
		monsterInfo.level = DynamicConfigData.t_fight[bossId]["level"..monsterIndex]
		monsterInfo.star = DynamicConfigData.t_fight[bossId]["star"..monsterIndex]
		monsterInfo.type = 2
	end
	return monsterInfo
end



function PushMapModel:setPushmapRewardGuajiCache(time)--给汉德领取奖励界面展示的数据
	self.pushmapRewardGuajiCache=time
end

function PushMapModel:getPushmapRewardGuajiCache()
	return self.pushmapRewardGuajiCache
end

function PushMapModel:setShowCohesionView(isShow)
	self.isShowCohesionView=isShow
end

function PushMapModel:getShowCohesionView()
	return self.isShowCohesionView
end

function PushMapModel:setChapterRewardViewParameter(cityId,chapterId)--设置章节奖励打开界面数据
	self.chapterRewardViewParameter["cityId"]=cityId
	self.chapterRewardViewParameter["chapterId"]=chapterId
end

function PushMapModel:getchapterRewardViewParameter()--得到设置章节奖励打开界面数据
	local cityId= self.chapterRewardViewParameter["cityId"]
	local chapterId= self.chapterRewardViewParameter["chapterId"]
	return cityId,chapterId
end

function PushMapModel:loginsetjumpEnterState()
	 local time=tostring(FileDataType.PUSHMAP_JUMPENTERSTATE..ModelManager.PlayerModel.userid) 
	-- local enter= FileCacheManager.getStringForKey(time, "", nil, true)
	local enter = FileCacheManager.getBoolForKey(time,false)
	if enter=="" then
		self.jumpEnterState=false
		return
	end
	self.jumpEnterState=enter
end
   
function PushMapModel:getChapterlessthanThreeStar(cityId,chapterId)--得到当前章节不足3星的关卡
	local stateTag=0--0是你已三星通关
	local cityInfo= self.pushMapListInfo
	if next(cityInfo)==nil then
		return 1,1,1
	end
	local cityInfo=self.pushMapListInfo[cityId];
	if cityInfo==nil then
		return stateTag;
	end
	local chaptedInfo= cityInfo[chapterId];
	if chaptedInfo==nil then
		return stateTag;
	end
	if chaptedInfo.star then
		for pointId, pointvalue in pairs(chaptedInfo.star) do
			if pointvalue.star<3 then
				return cityId,chapterId,pointId
			end
		end
	end
	return stateTag
end

function PushMapModel:getlessthanThreeStar()--得到不足3星的关卡
	local stateTag=0--0是你已三星通关
	local cityInfo= self.pushMapListInfo
	if next(cityInfo)==nil then
		return 1,1,1
	end
	for cityId, chaptervalue in pairs(cityInfo) do
		for chapterId, value in pairs(chaptervalue) do
			local curStar,allStar=self:getChatpterCurStarAndAllStar(cityId,chapterId)
			if curStar<allStar then
				if value.star then
					for pointId, pointvalue in pairs(value.star) do
						if pointvalue.star<3 then
							return cityId,chapterId,pointId
						end
					end
				end
			end
		end
	end
	return stateTag
end


function PushMapModel:setjumpEnterState()
	if self.jumpEnterState==false then
		self.jumpEnterState=true
	else
		self.jumpEnterState=false
	end
	local time=tostring(FileDataType.PUSHMAP_JUMPENTERSTATE..ModelManager.PlayerModel.userid) 
    FileCacheManager.setBoolForKey(time, self.jumpEnterState)
end


--当前挑战的城市，章节 关卡
function PushMapModel:getCurCityAndrChapterAndLevel()
	local City=self.pushMaponHookInfo["chapterCity"] or 1
	local chapter=self.pushMaponHookInfo["chapterPoint"] or 1
	local curLevel=self:getCurPointIndex(City,chapter) or 1
	return  City,chapter,curLevel
end


--获取当前挑战的关卡信息
function PushMapModel:getCurChapterInfo()
	local city=self.battleCity.cityId
	local chapterId=self.battleCity.chapterId
	local pointId=self.battleCity.pointId
	return DynamicConfigData.t_chaptersPoint[city][chapterId][pointId]
end

function PushMapModel:checkChapterConfiger(city,chapterId,pointId)
    if DynamicConfigData.t_chaptersPoint[city] and DynamicConfigData.t_chaptersPoint[city][chapterId] and DynamicConfigData.t_chaptersPoint[city][chapterId][pointId] then
        return true
	else
		return false
	end
end



function PushMapModel:haveBeenPassPoint()
	local Num=0
	Num= self:getCurPassedPointIndex(1,1)
	if Num==0 then
		return Num
	end
	local cityId,chapterId,pointId=self:getPushMapCurInfo()
	local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
   if configInfo then
	   Num=configInfo.auto
   end
   return Num
end


function PushMapModel:getTargetRewardGuankaList()
	local map={}
	local configInfo=DynamicConfigData.t_ChaptersTargetReward
	for key, value in pairs(configInfo) do
		local rewardInfo=value.reward[1]
		map[value.num]=rewardInfo
	end
	return map
end

function PushMapModel:getTargetRewardGuankaReward(cityId,chapterId,pointId)
	local Num=0
 	local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	if configInfo then
		Num=configInfo.auto
	end
	if self.targetRewardGuankaReward[Num] then
		return  self.targetRewardGuankaReward[Num]
	end
	return false
end


function PushMapModel:getTargetRewardGuankaId(cityId,chapterId,pointId)
	local Num=0
 	local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	if configInfo and configInfo.auto~=nil then
		Num=configInfo.auto
	end
	return Num
end


function  PushMapModel:TargetRewardEnter()
	local City=self.pushMaponHookInfo["chapterCity"] or 1
	local chapter=self.pushMaponHookInfo["chapterPoint"] or 1
	local curLevel=self:getCurPointIndex(City,chapter) or 1
	local chaptersInfo=DynamicConfigData.t_chaptersPoint[City][chapter];
	local chaptInfo= chaptersInfo[curLevel]
	if not chaptInfo then
		return
	end
    local cityId=chaptInfo.city
    local chapterId=chaptInfo.cid
    local pointId=chaptInfo.sid
    local storyId=chaptInfo.storyid
    local itemType= self:getPointType(cityId,chapterId,pointId);
    if itemType==3 then 
        local function endfunc()
         self:Battle(cityId,chapterId,pointId,itemType)
        end
        ViewManager.open("PushMapFilmView",{step =storyId[1],endfunc=endfunc})
    else 
        ViewManager.open('PushMapInvestigationView',{cityId=cityId,chapterId=chapterId,pointId=pointId})
    end
end

function PushMapModel:upTargetRewardRed()
	local Num = self:getTargetRewardGuankaNum()
	printTable(23,"打印的《《《《《《",Num)
    local configInfo=DynamicConfigData.t_ChaptersTargetReward
    local red = false
    for key, itemInfo in pairs(configInfo) do
		local lingqu = self:getTargetRewardLingqu(itemInfo.id)
        if  Num >= itemInfo.num and lingqu == false then --无法领取
			red = true
			break
        end
    end
    RedManager.updateValue("V_CHAPTERTARGETREWARDRED", red)
end

function PushMapModel:getTargetRewardGuankaNum()
	local Num=0
	if self.pushMaponHookInfo["chapterCity"]==1 and  self.pushMaponHookInfo["chapterPoint"]==1 and self.pushMaponHookInfo["chapterLevel"]==1 then
		return Num 
	end
	 local cityId,chapterId,pointId=self:getPushMapCurInfo()
	 printTable(23,">>>>>>>>>>>>>adsfewqfwqef",cityId,chapterId,pointId)
 	local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	if configInfo then
		Num=configInfo.auto
	end
    return Num
end

function PushMapModel:getTargetRewardLingqu(id)
	local serverInfo=self.pushMaponHookInfo.chapterTargetReward
	if not serverInfo then
		return false
	end
	local stateInfo= serverInfo[id]
	if stateInfo~=nil then--已领取
		return true
	else
		return false
	end
end

function PushMapModel:getTargetRewardGuankaInfo(isSort)
    local temp={}
    local configInfo=DynamicConfigData.t_ChaptersTargetReward
    for id, value in pairs(configInfo) do
       local  stateIdex= self:getTargetRewardLingqu(id)
        if  stateIdex==true then--已领取
            value["getRewardIdex"]=1
        else
            value["getRewardIdex"]=0
        end
        temp[#temp+1]=value
    end
    if isSort==true then
        TableUtil.sortByMap(temp, {{key="getRewardIdex",asc=false} ,{key="id",asc=false}})
    end
    return temp
end


function PushMapModel:getMaxCityAndChapterAndPoint()
	local function success(data)
		if next(data)  then
			local cityId=	data.city--城市
			local chapterId=  data.point --1:integer #--章节
			local pointId= data.level --:integer #--关卡
			printTable(23,'#推送通关记录22222',cityId,chapterId,pointId)
			self.curOnhookInfo["chapterCity"]=cityId;
			self.curOnhookInfo["chapterPoint"]=chapterId;
			self.curOnhookInfo["chapterLevel"]=pointId;
			self:upTargetRewardRed()--目标奖励红点
			Dispatcher.dispatchEvent(EventType.module_check)
			Dispatcher.dispatchEvent(EventType.pushMap_getCurPassPoint,{cityId=cityId,chapterId=chapterId,pointId=pointId});
		end
	end
	local info = {
	}
	RPCReq.Chapters_GetHangUpState(info,success)
end

function PushMapModel:getPushMapCurInfo()
	 local cityId= self.curOnhookInfo["chapterCity"] or 1;
	 local chapterId =self.curOnhookInfo["chapterPoint"]or 1;
	 local pointId=self.curOnhookInfo["chapterLevel"]or 1;
	 return cityId,chapterId,pointId
end


function PushMapModel:getPushMapCurFightId()
	local cityId= self.curOnhookInfo["chapterCity"] or 1;
	 local chapterId =self.curOnhookInfo["chapterPoint"]or 1;
	 local pointId=self.curOnhookInfo["chapterLevel"]or 1;
	 local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	 if not configInfo then
		return 1
	 end
	 local fightId=configInfo.fightfd or 1
	 printTable(18,"别人需要的战斗ID",fightId)
	return fightId
end

function PushMapModel:getMonsterFigthByFightId(fightId)
	  local fightConfig=DynamicConfigData.t_fight[fightId];
	  if not fightConfig then
		  return 0;
	  end 
	  local posList = {}
	  for _, pos in ipairs(fightConfig.monsterStand) do
		posList[pos] = true
	  end
	  local fight = 0
	  for i=1,8 do
		if posList[i] then
		  local sIndex = tostring(i)
		  fight = fightConfig["combat"..sIndex]+fight;
		end
	  end
	  return fight;
  end


function PushMapModel:getWorldMapAllStar(cityId) 
	local config=DynamicConfigData.t_chapters[cityId];
	local star=0
	for key, value in pairs(config) do
		star=star+value.star;
	end
	return star
end

function  PushMapModel:getBossId(cityId, chapterId, pointId)
	local pointInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	if not pointInfo or pointInfo.boss==0 then
		return false
	end
	return pointInfo.boss
end

function  PushMapModel:getVipId(cityId, chapterId, pointId)
	local pointInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	if not pointInfo or pointInfo.VIP==0 then
		return false
	end
	return pointInfo.VIP
end

function  PushMapModel:guankaIsBoss(cityId, chapterId, levelId)
	local city=cityId or self.city
	local chapter=chapterId or self.point
	local level=levelId or self.level
	local isBoss=true
	local configcity= DynamicConfigData.t_chaptersPoint[city]
	if not configcity then
		return false
	end
	local configchapter=configcity[chapter]
	if not configchapter then
		return false
	end
	local pointInfo=configchapter[level]
	if not pointInfo or pointInfo.boss==0 then
		isBoss=false
	end
	return isBoss
end
	
function PushMapModel:getTargetHeroBg() 
	return string.format("%s.png","Icon/pushMap/pushMapTargetHero")
end

function PushMapModel:getInvesyingSidbg(sidbg) 
	return string.format("%s%s.jpg","Icon/pushMap/pusMapInvesyingSidbg",sidbg)
end

function PushMapModel:getPointMapBg() 
	return string.format("%s.jpg","Icon/pushMap/pusMapPointbg")
end

function PushMapModel:getWorldMapBg() 
	return string.format("%s.jpg","Icon/pushMap/pusMapWorldMap")
end

function PushMapModel:getChatperMapBg1(num) 
	return string.format("%s%s.jpg","Icon/pushMap/pusMapChatperbg",num)
end

function PushMapModel:getChatperMapBg2() 
	return string.format("%s.jpg","Icon/pushMap/pusMapChatperbg2")
end

function PushMapModel:getCityNamePic(cityId) 
	return string.format("%s%s.png","Icon/pushMap/pushmapCity_",cityId)
end

function PushMapModel:getCurBoxTransition()
	local serverInfo= self.pushMaponHookInfo;
	if not serverInfo then
		return	't0'
	end
	local curTime=serverInfo.hangUpMax
	local onhookTime=12*60*60;
	printTable(9,'>>>>>>>刷新挂机宝箱',curTime)
	local one= math.floor(onhookTime/6)
	if curTime<one  then
		return 't0'
	elseif curTime>=one and curTime<(one*2) then
		return 't1'
	elseif curTime>=(one*2) and curTime<(one*3) then
		return 't2'
	elseif curTime>=(one*3) and curTime<(one*5) then
		return 't3'
	elseif curTime>=(one*5) and curTime<(one*6) then
		return 't4'
	else
		return 't4'
	end
end

function PushMapModel:getCurBoxAnimationState()
	local serverInfo= self.pushMaponHookInfo;
	if not serverInfo then
		return	1
	end
	local curTime=serverInfo.hangUpMax
	if curTime<=20*60 then
		return 1
	elseif curTime>20*60 and curTime<=50*60 then
		return 2
	elseif curTime>50*60 then	
		return 3
	end
end

function PushMapModel:getCurMaxCityOpen(cityId)
	if self.pushMaponHookInfo  then
		if cityId<=self.pushMaponHookInfo.chapterCity then
			return true;
		end
	end
	return false;
end


function PushMapModel:getPointRewardDesc(cityId,chapterId,pointId)
	printTable(28,'>>>>>>>>>>>>>>>>getPointRewardDesc张姐姐姐姐i耳机IE',cityId,chapterId,pointId)
	local pointInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	local configInfo=DynamicConfigData.t_chaptersPointFightFd[pointInfo.fightfd];
	local descText={"战士","坦克","法师","刺客","射手","辅助"}
	local raceText={"神族","魔族","兽族","人族","械族"}
	if not configInfo then
		return {}
	end
	local categoryMap={}
	table.insert( categoryMap,configInfo.category)
	for i = 1, 4, 1 do
		local key="category"..i
		table.insert(categoryMap,configInfo[key])
	end
	local resultMap={}
	local descMap={};
	local num=0;
	for key, value in pairs(categoryMap) do
		local result={}
		result["type"]=key
		result["pos"]=value[1]
		if value[1]~=0 then
			num=num+1
			result["limit"]=value
		 	table.insert( resultMap, result)
		end 
	end
	printTable(28,"sadfqqwer>>>>>",resultMap)
	TableUtil.sortByMap(resultMap, {{key="pos",asc=false}})
	for i = 1, num, 1 do
		local config=resultMap[i]
		local value={}
		local str=''
		local limit=config["limit"]
		if config["type"]==1 then--职业通关条件
			str="包含"..limit[3].."个"..descText[limit[2]].."通关"
		elseif config["type"]==2 then--回合通关条件
			str=DescAuto[195]..limit[2]..DescAuto[196] -- [195]="在" -- [196]="回合内通关"
		elseif config["type"]==3 then--种族通关条件
			str=DescAuto[197]..limit[3]..DescAuto[198]..raceText[limit[2]] -- [197]="包含" -- [198]="个"
		elseif config["type"]==4 then--死亡人数和无死亡人通关条件
			if limit[2]==1 then
				str=DescAuto[199] -- [199]="全员存活通过"
				else
				str=DescAuto[200]..limit[2]..DescAuto[198] -- [200]="死亡人数不超过" -- [198]="个"
			end
		elseif config["type"]==5 then--种族通关条件
			str=DescAuto[201] -- [201]="成功通关"
		end
		value['desc']=str
		local rewardDropId=configInfo.starward[i];
		printTable(12,'>>>>>>>>>>>>>>>>getPointRewardDesc',rewardDropId)
		local rewardDrop= DynamicConfigData.t_reward[rewardDropId];
		if rewardDrop.goldExpr~=0 then
			local  rewardType={type=2,code=1,amount=rewardDrop.goldExpr}
			value['reward']=rewardType;
		else
			local  rewardType={type=2,code=2,amount=rewardDrop.diamond}
			value['reward']=rewardType;
		end
		table.insert( descMap, i ,value )
	end
	return descMap;
end


function PushMapModel:getQuickOnhookCount()
 local config=	DynamicConfigData.t_chapterSpeed
 printTable(10,'>>>>>>>>',config)
 local isFreeNum=0;
 for key, value in pairs(config) do
	if value.diamonds==0 then
		isFreeNum=isFreeNum+1
	end
 end
 local count=self.pushMaponHookInfo.fastCount
 printTable(10,'>>>>>>>>.......',isFreeNum,count)
 local remind= #config-count
 local isFree=true;
 if count>=isFreeNum then
	isFree=false
 end
 return isFree,remind
end

function PushMapModel:getPointType(cityId,chapterId,point)
	local configInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId]
	local info= configInfo[point];
	return info.sidtype;
end

function PushMapModel:getPointStar(cityId,chapterId,point)
	local cityInfo=self.pushMapListInfo[cityId];
	printTable(9,'MMMMMMMMM',cityInfo,cityId,chapterId,point)
	if cityInfo==nil then
		return 0;
	end
	local chaptedInfo= cityInfo[chapterId];
	if chaptedInfo==nil then
		return 0;
	end
	local starMap= chaptedInfo['star'];
	if starMap[point] then
		return starMap[point].star;
	else
		return 0;
	end
end

function PushMapModel:getPointStarPassList(cityId,chapterId,point)
	local cityInfo=self.pushMapListInfo[cityId];
	printTable(9,'MMMMMMMMM',cityInfo,cityId,chapterId,point)
	if cityInfo==nil then
		return {};
	end
	local chaptedInfo= cityInfo[chapterId];
	if chaptedInfo==nil then
		return {};
	end
	local starMap= chaptedInfo['star'];
	if starMap[point] then
		return starMap[point].starList;
	else
		return {};
	end
end


function PushMapModel:getChatpterRewardRecord(cityId,chapterId,pos)
	local cityInfo=self.pushMapListInfo[cityId];
	if not cityInfo then
		return 0;
	end
	local chaptedInfo= cityInfo[chapterId];
	if not chaptedInfo then
		return 0;
	end
	local serverInfo= chaptedInfo['serverInfo'];
	if not serverInfo.starRecord then
		return 0
	end
	return serverInfo.starRecord[pos] or 0
end


function PushMapModel:getChatpterCurStarAndAllStar(cityId,chapterId)
	local star=0
	local allstar=DynamicConfigData.t_chapters[cityId][chapterId]
	local cityInfo=self.pushMapListInfo[cityId];
	if cityInfo==nil then
		return  star,allstar.star;
	end
	local chaptedInfo= cityInfo[chapterId];

	if chaptedInfo==nil then
		return  star,allstar.star;
	end
	local starMap= chaptedInfo['serverInfo'];
	star=starMap.starTotal
	return star, allstar.star;
end


function PushMapModel:getCurChapterIndex(cityId)
	local index=0
	local cityInfo=self.pushMapListInfo[cityId];
	if cityInfo==nil then
		return index+1;
	end
	for key, value in pairs(cityInfo) do
		index=index+1;
	end
	local chaptersInfo=DynamicConfigData.t_chaptersPoint[cityId][index];
	if cityInfo[index] and #cityInfo[index].star>=#chaptersInfo then
		index=index+1;
	end
	if index>=15 then
		index=15;
	end
	return index;
end

function PushMapModel:getCurPointIndex(cityId,chapterId)--当前关卡
	local index=1
	local cityInfo=self.pushMapListInfo[cityId];
	if cityInfo==nil then
		return 1;
	end
	local chaptedInfo= cityInfo[chapterId];
	if chaptedInfo==nil then
		return 1;
	end
	local starMap= chaptedInfo['star'];
	for key, value in pairs(starMap) do
		index=index+1
	end
	local chaptersInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
	if index>=#chaptersInfo then
		index=#chaptersInfo;
	end
	return index;
end

function PushMapModel:getCurPassedPointIndex(cityId,chapterId)--当前已通关的关卡
	local index=0
	local cityInfo=self.pushMapListInfo[cityId];
	printTable(9,'pppppppppppsdafsadfq',cityId,chapterId,index)
	if cityInfo==nil then
		return 0;
	end
	printTable(9,'pppppppppppsdafsadfq11',index)
	local chaptedInfo= cityInfo[chapterId];
	if chaptedInfo==nil then
		return 0;
	end
	printTable(9,'pppppppppppsdafsadfq22',index)
	local starMap= chaptedInfo['star'];
	for key, value in pairs(starMap) do
		index=index+1
	end

	local chaptersInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
	if index>=#chaptersInfo then
		index=#chaptersInfo;
	end
	return index;
end

function PushMapModel:CurPointisPassed(cityId,chapterId,index)--当前已通关的关卡
	local pass= self:getCurPassedPointIndex(cityId,chapterId)
	printTable(27,"sdaffffffffffffffffffffffffff",pass)
	if pass>=index then
		return true
	end
	return false
end

function PushMapModel:getModulePointisPassed(cityId,chapterId,index)--当前已通关的关卡
	local cityId=self.city or 1	--# 当前挑战城市
	local chapterId= self.point or 1 	--# 当前挑战章节
	local pointId= self.level or 1	--# 当前挑战关卡
	local roundId = self:CurPointisPassed(cityId,chapterId,pointId)
	if roundId==false  then--首通的话显示进度条动画
		self.isBarShowed=true
		else
		self.isBarShowed=false
	end
	self.modulefirstPass=roundId;
end

function PushMapModel:getModulePointisPassLimit(cityId,chapterId,pointId,limit)--模块开启
	printTable(27,"sssssssssssssssssss",cityId,chapterId,pointId,limit)
 local auto=self:getTargetRewardGuankaId(cityId,chapterId,pointId)
 local isBoss= self:guankaIsBoss(cityId, chapterId, pointId)
 if auto>=limit and not isBoss  then
	 return true
 end
	return false
end


function PushMapModel:isFirstTen()--是否是第一次10关
	if self:getCurPassedPointIndex(1,1)<10 then
		self.firstTenGuanka=true
	else
		self.firstTenGuanka=false
	end
	printTable(26,'#推送通关记录}}}}}}',self.firstTenGuanka)
end

function PushMapModel:getChapterRewardText(cityId,chapterId)
  local configInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId]
  local count= #configInfo;
  return configInfo[1].sidname ..'-'..configInfo[count].sidname;
end


function PushMapModel:upNewCity(cityId1,chapterId1,pointId1)
	local cityId=cityId1
	local chapterId=chapterId1
	local pointId=pointId1
	local chaptersInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
    if not chaptersInfo then
        return   
	end
	local curCity=self.pushMaponHookInfo["chapterCity"] or 1
	local curPoint=self.pushMaponHookInfo["chapterPoint"] or 1
	local curLevel=self.pushMaponHookInfo["chapterLevel"] or 1
	if cityId <curCity then
		self:dispatchShowBarAni(false)
		return 
	end
	if chapterId<curPoint then
		self:dispatchShowBarAni(false)
		return
	end
	if pointId<curLevel then
		self:dispatchShowBarAni(false)
		return
	end
	local curMaxPoint=self:getCurPassedPointIndex(cityId,chapterId)--当前关卡
	self:dispatchShowBarAni(true)
	local allCityNum=#(DynamicConfigData.t_chapters)
	local allChapter=DynamicConfigData.t_chapters[cityId]
	local maxCityNum=#(DynamicConfigData.t_chapters)
	local MaxChapterNum=DynamicConfigData.t_chapters[maxCityNum]
	local maxPointNum=DynamicConfigData.t_chaptersPoint[maxCityNum][#MaxChapterNum];
	printTable(19,'最大>>>>>>>',cityId,chapterId,pointId,maxCityNum,#maxPointNum,#MaxChapterNum,curMaxPoint)
	if cityId==maxCityNum and pointId==#maxPointNum and chapterId==#MaxChapterNum  and curMaxPoint==#maxPointNum  then
		
	else
		if pointId==#chaptersInfo and  curMaxPoint>=#chaptersInfo then
			chapterId=chapterId+1;
			if chapterId>#allChapter then
				chapterId=1
				cityId=cityId+1
				if cityId>=allCityNum then
					cityId=allCityNum
				end
			end
			pointId=1
		end
	end
	printTable(32,'每次刷新的最高数1111111',cityId,chapterId,pointId,self.pushMaponHookInfo["chapterCity"],self.pushMaponHookInfo["chapterPoint"],self.pushMaponHookInfo["chapterLevel"])
	self.pushMaponHookInfo['chapterCity'] =cityId
	self.pushMaponHookInfo['chapterPoint'] =chapterId --1:integer #--章节
	self.pushMaponHookInfo['chapterLevel'] =pointId  --:integer #--关卡
end

function PushMapModel:setPushMapCityAndChapterRed1(cityId,chapterId)
	local rewardArr=DynamicConfigData.t_chapters[cityId][chapterId].dropid;
	if not rewardArr then
		return
	end
	local red=false
	local curStar,allStar= self:getChatpterCurStarAndAllStar(cityId,chapterId);
	if not curStar then
		return
	end
	if cityId==1 then
	end
	for i = 1, #rewardArr, 1 do
		local ItemInfo = rewardArr[i]
		local star=ItemInfo.star;
		local pos=ItemInfo.pos;
		local getState= self:getChatpterRewardRecord(cityId,chapterId,pos)
		if curStar>=star and getState==0 then
			red=true
		end
	end
	self.pushMapRedList[cityId.."_"..chapterId]=red
end

function PushMapModel:setPushMapCityAndChapterRed(cityId)
	local red=false
	local chapterNum=DynamicConfigData.t_chapters[cityId]
	for key, value in pairs(chapterNum) do
		printTable(19,"asdfasdf>>>11111",cityId,key)
		local chapterRed= self.pushMapRedList[cityId.."_"..key]
		if chapterRed and  chapterRed==true then
			red=true
			break
		end
	end
	self.pushMapRedList[cityId]=red
end

function PushMapModel:setPushMapRed(cityId,chapterId)
	self:setPushMapCityAndChapterRed1(cityId,chapterId)
	self:setPushMapCityAndChapterRed(cityId)
	if cityId==1 then
		printTable(19,"打印当前的红点",self.pushMapRedList)
	end
	self:upCityRed()
	Dispatcher.dispatchEvent(EventType.pushMap_upChapterRewardRed)
end

function PushMapModel:upCityRed()
	local allCityNum=#(DynamicConfigData.t_chapters)
	local red=false
	for i = 1, allCityNum, 1 do
	local itemRed =self:getPushMapcityRed(i)
		if itemRed then
			red=true
			break
		end
	end
	RedManager.updateValue("V_CHAPTERREWARDRED", red);  
end


function PushMapModel:getPushMapcityRed(cityId)
	return self.pushMapRedList[cityId] or false
end

function PushMapModel:getPushMapchapterRed(cityId,chapterId)
	return self.pushMapRedList[cityId.."_"..chapterId] or false
end


function PushMapModel:upPushMapMofangRed()--更新魔方红点
	local red=false
	RPCReq.Chapters_GetFastTimes({},function(args)
		printTable(27,"我我我我我我",args)
		local isFree = args.usrFreeTimes - args.freeTimes 	-- 免费次数
		if isFree>0 then
			red=true
		end
		printTable(27,"wwwwwwwwwwwwwwwwwwwwwwwwwwww[[[[[[[[[aaaaaa",red)
		RedManager.updateValue("V_PUSHMAPMOFANGRED", red);  
	end)
end

function PushMapModel:getChapterRewardbtnDesc(cityId,chapterId)--可领取章节描述文字
	local curStar,allStar= self:getChatpterCurStarAndAllStar(cityId,chapterId);
	local rewardArr=DynamicConfigData.t_chapters[cityId][chapterId].dropid;
	for i = 1, #rewardArr, 1 do
		local ItemInfo = rewardArr[i]
		local star=ItemInfo.star;
		if curStar<star then
			return "还差"..ColorUtil.formatColorString1(star-curStar, "#3bfe44").."星"
		end
	end
	return   ""
end

function PushMapModel:gettongguanRewardbtnDesc()--可领取通关奖励描述文字
	local passNum=self:getTargetRewardGuankaNum()
	local configInfo=DynamicConfigData.t_ChaptersTargetReward
	local red=RedManager.getTips("V_CHAPTERTARGETREWARDRED")
	if red==nil then
		red=false
	end
	if red==false then
		for i = 1, #configInfo, 1 do
			local ItemInfo = configInfo[i]
			local num=ItemInfo.num;
			if passNum<num then
				return "还差"..ColorUtil.formatColorString1(num-passNum, "#3bfe44").."关"
			end
		end
	end
	return   ""
end

function PushMapModel:showQuickOnhookReward(cityId,chapterId,pointId)--显示挂机收益3个奖励
	if cityId==1 and chapterId==1 and pointId==1 then
		return
	end
	local roundId= self.modulefirstPass--首次通关才显示
	if roundId ==false and self.isWin==true then
		local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
		local fightReward= DynamicConfigData.t_chaptersPointFightFd[configInfo.fightfd] 
		local nextCityId,nextChapter,nextPoint=self:prevInfo(cityId, chapterId, pointId)
		local nextconfigInfo=DynamicConfigData.t_chaptersPoint[nextCityId][nextChapter][nextPoint]
		local nextfightReward= DynamicConfigData.t_chaptersPointFightFd[nextconfigInfo.fightfd] 
		if not nextfightReward then
			return 
		end
		if not fightReward then
			return 
		end

		local rewardList = {}
		for index, reward in ipairs(fightReward.greward) do
			local nextReward = nextfightReward.greward[index]
			if nextReward.amount < reward.amount then
				table.insert(rewardList, {nextReward, reward})
			end
		end

		Scheduler.unschedule(self.schedulerID)
		self.schedulerID = Scheduler.schedule(function()
				if ViewManager.getView("UpgradeView") then return end
				if ViewManager.getView("ModuleOpenView") then return end
				if ViewManager.getView("SecretWeaponsGetView") then return end
				if ViewManager.getView("VipUpLevelView") then return end
				if ViewManager.getView("ReWardView") then return end
				if self:getShowCohesionView() then return end
				RollTips.showCohesionRewardView({
					leftLevelName = string.format("通关%s", nextconfigInfo.sidname), -- TODO
					rightLevelName = string.format("通关%s", configInfo.sidname), -- TODO
					rewardList = rewardList,
				})
				Scheduler.unschedule(self.schedulerID)
			end,0.2)
	
	end
end

function  PushMapModel:nextInfo(cityId, chapterId, pointId)--下一关
	local curCityId=cityId
	local curChapter=chapterId
	local curPoint=pointId
    local chaptersInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
    local allCityNum=#(DynamicConfigData.t_chapters)
	local allChapter=DynamicConfigData.t_chapters[cityId]
	local maxCityNum=#(DynamicConfigData.t_chapters)
	local MaxChapterNum=DynamicConfigData.t_chapters[maxCityNum]
	local maxPointNum=DynamicConfigData.t_chaptersPoint[maxCityNum][#MaxChapterNum];
    if  maxCityNum==cityId and chapterId==#MaxChapterNum and pointId==#maxPointNum  then
    else
		if  pointId>=#chaptersInfo then
					curChapter=chapterId+1;
					curPoint=1
					if chapterId>#allChapter then
						curChapter=1
						curCityId=cityId+1
						if curCityId>=allCityNum then
							curCityId=allCityNum
						end
						curPoint=1
					end
				else
				curPoint=pointId+1
			end
		end
	return  curCityId,curChapter,curPoint
end

function  PushMapModel:prevInfo(cityId, chapterId, pointId)--上一关
	local curCityId=cityId
	local curChapter=chapterId
	local curPoint=pointId
	local maxCityNum=#(DynamicConfigData.t_chapters)
	local MaxChapterNum=DynamicConfigData.t_chapters[maxCityNum]
	local maxPointNum=DynamicConfigData.t_chaptersPoint[maxCityNum][#MaxChapterNum];
	if  maxCityNum==cityId and chapterId==#MaxChapterNum and pointId==#maxPointNum  then
		return cityId,chapterId,pointId-1
	else
			if cityId>1 and chapterId==1 and pointId==1 then	
				curCityId=cityId-1
				curChapter=#DynamicConfigData.t_chapters[curCityId]
				curPoint=#DynamicConfigData.t_chaptersPoint[curCityId][curChapter];
			elseif chapterId>1 and pointId==1 then
				curCityId=cityId
				curChapter=chapterId-1
				curPoint=#DynamicConfigData.t_chaptersPoint[curCityId][curChapter];
			else
				curCityId=cityId
				curChapter=chapterId
				curPoint=curPoint-1
			end
		end
	return  curCityId,curChapter,curPoint
end


function PushMapModel:getJingBiSaTime(type)
	local countDowmTime= self.jingbiTime[type]
	if countDowmTime>self.jingbiRandom[type] then
		self.jingbiRandom[type]=(math.ceil(math.random(3,7)))*10
		self.jingbiTime[type]=0
		self.jingbiRunState[type]=true
		if type==1 then
			Dispatcher.dispatchEvent(EventType.pushMap_jingbisa1)
		else
			Dispatcher.dispatchEvent(EventType.pushMap_jingbisa2)
		end
	end
end

function PushMapModel:showPushmapmofangText(txt_time,type)
	if self.jingbiTime[1]==nil then 
		self.jingbiTime[1]=0
	end
	if self.jingbiTime[2]==nil then 
		self.jingbiTime[2]=0
	end
	if self.jingbiRandom[1]==nil then 
		self.jingbiRandom[1]=0
	end
	if self.jingbiRandom[2]==nil then 
		self.jingbiRandom[2]=0
	end
	if self.jingbiRunState[1] ==nil then
		self.jingbiRunState[1]=false
	end
	if self.jingbiRunState[2] ==nil then
		self.jingbiRunState[2]=false
	end
	local serverInfo= self.pushMaponHookInfo
	if next(serverInfo)==nil  then
		return
	end
	local hangUpMax=serverInfo.hangUpMax
	local onhookTime=12*60*60 + VipModel:getVipPrivilige(GameDef.VipPriviligeType.OnhookTime) * 3600;
		if not tolua.isnull(txt_time) then
			txt_time:setText(TimeLib.formatTime(hangUpMax,true,false))
		end
		if hangUpMax==0 then
			hangUpMax=1
		end
			local function onCountDown( time )
				self.jingbiTime[1]=self.jingbiTime[1]+1
				self.jingbiTime[2]=self.jingbiTime[2]+1
				self:getJingBiSaTime(1)
				self:getJingBiSaTime(2)
				if time>=onhookTime then
					time=onhookTime
				end
				if not tolua.isnull(txt_time) then
					txt_time:setText(TimeLib.formatTime(time,true,false))
				end	
		    end
		    local function onEnd( ... )
		    end
		    if self.showPushmapmofangTime[type] then
		    	TimeLib.clearCountDown(self.showPushmapmofangTime[type])
		    end
		self.showPushmapmofangTime[type] = TimeLib.newCountDown(hangUpMax, onCountDown, onEnd, false, true,false)
end

function PushMapModel:getCurrentBossNeedAnim(com,pos)--当前关卡boss红色特效
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "ui_hong_loop", "Effect/UI", "fx_guangqia", "fx_guangqia",false) 
	animation:setAnimation(0, "ui_hong_loop", true)
	return animation
end

function PushMapModel:getCurrentNeedAnim(com,pos)--当前关卡黄色特效
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "ui_huang_loop", "Effect/UI", "fx_guangqia", "fx_guangqia",false) 
	animation:setAnimation(0, "ui_huang_loop", true)
	return animation
end

function PushMapModel:getItemAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "pingzhikuang_hong", "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",false) 
	animation:setAnimation(0, "pingzhikuang_hong", true)
	animation:setScale(0.5)
	return animation
end


function PushMapModel:getBossAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "zhencha_weixian", "Effect/UI", "efx_zhencha_2", "efx_zhencha_2",false) 
	animation:setAnimation(0, "zhencha_weixian", true)
	return animation
end

function PushMapModel:getVIPAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "zhencha_vip", "Effect/UI", "efx_zhencha_2", "efx_zhencha",false) 
	animation:setAnimation(0, "zhencha_vip", true)
	animation:setScale(0.87)
	return animation
end

function PushMapModel:getNextBtnAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "zhencha_dianjianniu", "Effect/UI", "efx_zhencha_3", "efx_zhencha",false) 
	animation:setAnimation(0, "zhencha_dianjianniu", true)
	return animation
end

function PushMapModel:getworldMapAnim(com,pos)
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "zhencha_changjing", "Effect/UI", "efx_zhencha", "efx_zhencha",false) 
	animation:setAnimation(0, "zhencha_changjing", true)
	return animation
end

function PushMapModel:getworldMapLanAnim(com,pos)--已挑战过的特效蓝光
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "zhencha_tiaozhan_languang", "Effect/UI", "efx_zhencha", "efx_zhencha",false) 
	animation:setAnimation(0, "zhencha_tiaozhan_languang", true)
	return animation
end

function PushMapModel:getworldMapHuangAnim(com,pos)--当前挑战过的黄光
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "zhencha_tiaozhan_changguang", "Effect/UI", "efx_zhencha", "efx_zhencha",false) 
	animation:setAnimation(0, "zhencha_tiaozhan_changguang", true)
	return animation
end

function PushMapModel:getChapterAnim(com,pos)--章节特效
	local animation=false
	if not pos then
		pos=Vector2.zero
	end
	animation= SpineUtil.createSpineObj(com,{x=0,y=0}, "animation", "Effect/UI", "efx_zhencha", "efx_zhencha",false) 
	animation:setAnimation(0, "animation", true)
	return animation
end

function PushMapModel:dispatchShowBarAni(isPass)
	self.isBarShowed=false
	if not isPass then
		return
	end
	printTable(156,"11111")
	self.isBarShowed=true
	Scheduler.unschedule(self.barAnimationID)
	self.barAnimationID = Scheduler.schedule(function()
	 local viewName=ViewManager.getLayerTopWindow()
	  -- printTable(156,"222222222",viewName.name)
	 if viewName.name=="PushMapCheckPointView" then
		--printTable(156,"22222222211111112",viewName.name)
		Dispatcher.dispatchEvent(EventType.pushMap_showBarAnim)
		Scheduler.unschedule(self.barAnimationID)
	 end
		end,0.2)
end


--##开始战斗
function PushMapModel:Battle(city,point,level,figthType)
	local function success(data)
		printTable(28,"开始战斗返回",data)
		if figthType==3 then
			Dispatcher.dispatchEvent(EventType.show_gameReward)
		end
		if data.code==1 then
			self.isWin=true;
			if data.city==1 and data.point==1 and data.level==10 and self.firstTenGuanka==true then
				printTable(152,'#推送通关记录}}}}}}11111',self.firstTenGuanka)
				Dispatcher.dispatchEvent(EventType.pushMap_specificguidancepoint)
				self.firstTenGuanka=false
			end
			local activeInfo=ActivityModel:getActityByType( GameDef.ActivityType.CollectStar )
			if activeInfo and  ActivityModel:getActStatusAndLastTime(activeInfo.id) and ActivityModel:getActStatusAndLastTime(activeInfo.id) ==2 then
				OperatingActivitiesModel:getServerCollectStarInfo()
			end
			self:upNewCity(data.city,data.point,data.level)
			self:setPushMapRed(data.city,data.point)
			self:upTargetRewardRed()
			Dispatcher.dispatchEvent(EventType.pushMap_shownextGuankaComp)	
		else
			self.isWin=false;
		end
		self.reward=data.reward or {};
		self.point =data.point	--# 当前挑战章节
		self.level =data.level	--# 当前挑战关卡
		self.city =data.city	--# 当前挑战城市
		self.star =data.star or 0--# 当前挑战最新星数
		self.starList=data.starList or {}--# 当前挑战最新星数列表
	end 
	self.point =point	--# 当前挑战章节
	self.level =level	--# 当前挑战关卡
	self.city =city	--# 当前挑战城市
	self:getModulePointisPassed(city,level,point)
	local info = {
		city=city,	--	0:integer #城市
		point=point,	--	1:integer #章节
		level=level	--	2:integer #关卡
	}
	printTable(9,"开始战斗",info)
	RPCReq.Chapters_Battle(info,success)
end


--#祈愿 快速战斗
function PushMapModel:FastBattle(city,point,level,callfunc)
	local function success(data)
		printTable(152,"快速战斗返回",data.FastCount)
		if data then
			self.pushMaponHookInfo['fastCount']= data.FastCount
			if (not PriviligeGiftModel:getPriviligeGift(1)) and data.FastCount==1 then
				GuideModel:checkGuideActivate({{name="kuaisuguaji",id=ModuleId.PushMap.id}})	
				--Dispatcher.dispatchEvent(EventType.guide_open,{guideMode = 2,guideName = "kuaisuguaji"})
			end
			callfunc(true)
		end
		Dispatcher.dispatchEvent(EventType.show_gameReward,{gamePlayType=GameDef.GamePlayType.ChaptersFastBattle})
		self:upPushMapMofangRed()
	end
	local info = {
		city=city,	--	0:integer #城市
		point=point,	--	1:integer #章节
		level=level	--	2:integer #关卡
	}
	printTable(9,"快速战斗",info)
	local failfunc = function(res)
		-- body
		RollTips.showError(res)
		callfunc(false)
	end
	RPCReq.Chapters_FastBattle(info,success,failfunc)
end


--#领取挂机收益
function PushMapModel:receiveHangUpReward()
	local function success(data)
		printTable(9,"领取挂机收益返回",data)
		RollTips.show('领取成功')
		self.pushMaponHookInfo['hangUpMax']=data.hangUpMax;
		self.pushMaponHookInfo['reward']={}
		Dispatcher.dispatchEvent(EventType.pushMap_updateInfo,data);
	end
	local info = {
	}
	printTable(9,"领取挂机收益",info)
	RPCReq.Chapters_ReceiveHangUpReward(info,success)
end

--#挂机
function PushMapModel:startHangUp(time)
	local function success(data)
		printTable(9,"挂机返回",data)
		--Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,data);
	end
	local info = {
		time=time --1:integer #每挂机30秒通知一下
	}
	printTable(9,"挂机",info)
	RPCReq.Chapters_StartHangUp(info,success)
end

--#结束挂机
function PushMapModel:endHangUp()
	local function success(data)
		printTable(9,"结束挂机返回",data)
		--Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,data);
	end
	local info = {
	}
	printTable(9,"结束挂机",info)
	RPCReq.Chapters_EndHangUp(info,success)
end

--#获取挂机
function PushMapModel:getHangUpState()
	local function success(data)
		printTable(18,"获取挂机返回",data)
		if next(data)  then
			self.curOnhookInfo['chapterCity']=data.city;
			self.curOnhookInfo['chapterPoint']=data.point;
			self.curOnhookInfo['chapterLevel']=data.level;
			self.pushMaponHookInfo['hangUpMax']=data.hangUpMax;
			if data.reward then
				self.pushMaponHookInfo['reward']={}
				self.pushMaponHookInfo['reward']=data.reward
			else
				self.pushMaponHookInfo['reward']={}
			end
			Dispatcher.dispatchEvent(EventType.pushMap_updateInfo,data);
		end
	end
	local info = {
	}
	printTable(9,"获取挂机",info)
	RPCReq.Chapters_GetHangUpState(info,success)
end


--##获取旧的通关章节信息
function PushMapModel:getOldBattleData(city)
	local function success(data)
		printTable(22,"#获取旧的通关章节信息返回",data)
		if data and data.battlelevelRecord then
			local info= data.battlelevelRecord
			local isCityOver=false
			for key, value in pairs(info) do
				if value.pointMark and value.pointMark>0 then
					isCityOver=true
				end
			end
			if isCityOver==true then
				for key, value in pairs(info) do
					local configInfo=DynamicConfigData.t_chaptersPoint[value.city]
					for i = 1, #configInfo, 1 do
						local heroList=self.pushMapListInfo[value.city] or {}
						local chapterStarNum=0
						local configChpaterInfo=DynamicConfigData.t_chaptersPoint[value.city][i]
						for j, v in pairs(configChpaterInfo) do
							chapterStarNum=chapterStarNum+3
						end
						local chapterInfo={}
						chapterInfo["city"] =value.city			
						chapterInfo["point"] =i			
						chapterInfo["starTotal"]=	chapterStarNum 				
						chapterInfo["starRecord"]={[1]=1,[2]=1,[3]=1}				
						chapterInfo["levels"]={}			
						chapterInfo["levelMark"]=1	
						local map={};
						local levels=self:buildServerPointData(chapterInfo,city,chapterInfo.point)
						chapterInfo.levels=levels
						map['star']=chapterInfo.levels
						map['serverInfo']=chapterInfo
						heroList[chapterInfo.point]=map;
						self.pushMapListInfo[city]=heroList
						self:setPushMapCityAndChapterRed1(city,key)
						self:setPushMapCityAndChapterRed(city)
						self:upCityRed()
					end
				end
			else
				for key, value in pairs(info) do
					local heroList=self.pushMapListInfo[city] or {}
					local map={};
					local levels=self:buildServerPointData(value,city,value.point)
					value.levels=levels
					map['star']=value.levels
					map['serverInfo']=value
					heroList[value.point]=map;
					self.pushMapListInfo[city]=heroList
					self:setPushMapCityAndChapterRed1(city,key)
					self:setPushMapCityAndChapterRed(city)
					self:upCityRed()
					if city==1 then
						printTable(19,"打印当前的红点",self.pushMapRedList)
					end
					end
				end
			end

		printTable(10,"#获取旧的通关章节信息返回>>>",self.pushMapListInfo)
		Dispatcher.dispatchEvent(EventType.pushMap_updatePointInfo)
	end
	local info = {
		city= city,    --0:integer #城市
	}
	printTable(9,"#获取旧的通关章节信息",info)
	RPCReq.Chapters_GetOldBattleData(info,success)
end

function  PushMapModel:buildServerPointData(value,city,chapter)--构建服务端章节数据
	local levels={}
	if value.levelMark and value.levelMark>0 then--服务端优化过后的数据
		local configInfo= DynamicConfigData.t_chaptersPoint
		local pointMap=configInfo[city][chapter]
		for i = 1, #pointMap, 1 do
			local info={}
			info["level"]=i
			info["star"]=3
			info["starList"]={}
			for j = 1, 3, 1 do
				info["starList"][j]=true
			end
			levels[i]=info
		end
	else
		levels=value.levels
	end
	return levels
end

--领取星数奖励
function PushMapModel:receiveStarReward(city,point,pos)
	local function success(data)
		printTable(9,"领取星数奖励返回",data)
		if data.ret then
			local cityInfo=self.pushMapListInfo[city];
			local chaptedInfo= cityInfo[point];
			local serverInfo= chaptedInfo['serverInfo'];
			 serverInfo.starRecord[data.ret]=1;
			 self.pushMapListInfo[city]=cityInfo;
			 self:setPushMapRed(city,point)
			 Dispatcher.dispatchEvent(EventType.pushMap_chapterRewardRecord,data); 
			--  Dispatcher.dispatchEvent(EventType.cardView_activeSkillSuc,data);
		end
	end
	local info = {
		city =city,		--0:integer#城市
		point=point,-- 		1:integer#章节
		pos =pos--	2:integer#领取奖励位置
	}
	printTable(9,"领取星数奖励",info)
	RPCReq.Chapters_ReceiveStarReward(info,success)
end

function PushMapModel:_initListeners()
	
end

function PushMapModel:loginPlayerDataInit(info)
	local data = info.baseData.chapters
	printTable(23,">>>>>>>>>>>>>>>>> = ",data)
	-- self.chaptersId = data.chapterPoint
	-- self.levelId = data.chapterLevel
	-- --self.reward = data.reward
	-- self.fastCount = data.fastCount
	-- --self.hangUpMax = data.hangUpMax
	-- self.hangUpDayMax = data.hangUpDayMax
	-- self.curTime = os.time()
	self.pushMaponHookInfo=data
end


--获取城市的通关章节信息
function PushMapModel:getOldCityBattleData()
	local function success(data)
		printTable(19,"获取城市的通关章节信息返回",data)
		local cityInfo=data.battlelevelRecord
		for key, value in pairs(cityInfo) do
			self.pushMapWorldcityInfo[value.city]=value
		end
		Dispatcher.dispatchEvent(EventType.pushMap_updateCityInfo,data); 
	end
	local info = {
	}
	printTable(9,"获取城市的通关章节信息",info)
	RPCReq.Chapters_GetOldCityBattleData(info,success)
end

--主动请求获取目标奖励领取状态
function PushMapModel:getTargetReward()
	if self.pushMaponHookInfo["chapterTargetReward"]==nil  then
		self.pushMaponHookInfo["chapterTargetReward"]={}
	end
	local function success(data)
		printTable(32,"主动请求获取目标奖励领取状态",data)
		if data and data.reward then
			for key, id in pairs(data.reward) do
				self.pushMaponHookInfo["chapterTargetReward"][id]={id=id}
			end
			self:upTargetRewardRed()
		end
		Dispatcher.dispatchEvent(EventType.pushMap_upTargetRewardRed); 
	end
	local info = {
	}
	printTable(23,"主动请求获取目标奖励领取状态",info)
	RPCReq.Chapters_GetTargetReward(info,success)
end


--获取目标奖励物品
function PushMapModel:receiveTargetReward(id)
	local function success(data)
		printTable(32,"获取目标奖励物品返回",data)
		if data and data.reward then
			local servesrInfo=self.pushMaponHookInfo["chapterTargetReward"]
			servesrInfo[data.reward]= {id = data.reward}
			self.pushMaponHookInfo["chapterTargetReward"]=servesrInfo
			printTable(23,"获取目标奖励物品返回",self.pushMaponHookInfo["chapterTargetReward"])
			self:upTargetRewardRed()
		end
		Dispatcher.dispatchEvent(EventType.pushMap_upTargetRewardRed); 
	end
	local info = {
		id=id
	}
	printTable(23,"获取目标奖励物品",info)
	RPCReq.Chapters_ReceiveTargetReward(info,success,nil,nil,0.3)
end


function PushMapModel:PushMapQuickEnter(cityId,chapterId,pointId)
	local chaptInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	local storyId=chaptInfo.storyid
	local itemType= self:getPointType(cityId,chapterId,pointId);
			if itemType==2 then 
				local function battleHandler(eventName)
					if eventName == "begin" then
						self:Battle(cityId,chapterId,pointId)
					elseif eventName == "end" then
					ViewManager.open("ReWardView",{page=2,type=1,data='',film=0,isWin=self.isWin,againFunc = function()
						self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
					end})
					end
				end
				self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
			elseif itemType==1 then
				local curMaxPoint=self:getCurPassedPointIndex(cityId,chapterId)--当前关卡
				if pointId<=curMaxPoint then
					local function battleHandler(eventName)
						if eventName == "begin" then
							self:Battle(cityId,chapterId,pointId)
						elseif eventName == "end" then
							ViewManager.open("ReWardView",{page=2,type=1,data='',film=0,isWin=self.isWin,againFunc = function()
								self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
							end})
							--ViewManager.open("PushMapEndLayerView",{film=0})
						end
					end
					self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
				else
					local function exitfunc1(eventName)
				
					end
					if  storyId[1]~="0" and storyId[3]~="0" then
						local function endfunc1(eventName)
						local function battleHandler(eventName)
							if eventName == "begin" then
								self:Battle(cityId,chapterId,pointId)
							elseif eventName == "end" then
								ViewManager.open("ReWardView",{page=2,type=1,data='',film=storyId[3],isWin=self.isWin,againFunc = function()
									self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
								end})
								--ViewManager.open("PushMapEndLayerView",{film=storyId[3]})
							end
						end
						self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
						end
						ViewManager.open("PushMapFilmView",{isShowGuochangyun=false,step = storyId[1],endfunc=endfunc1,exitfunc=exitfunc1})
					elseif storyId[1]=="0" and storyId[3]~="0" then
						local function battleHandler(eventName)
							if eventName == "begin" then
								self:Battle(cityId,chapterId,pointId)
							elseif eventName == "end" then
								ViewManager.open("ReWardView",{page=2,type=1,data='',film=storyId[3],isWin=self.isWin,againFunc = function()
									self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
								end})
							-- ViewManager.open("PushMapEndLayerView",{film=storyId[3]})
							end
						end
						self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
				elseif storyId[1]~="0" and storyId[3]=="0" then
						local function endfunc1(eventName)
							local function battleHandler(eventName)
								if eventName == "begin" then
									self:Battle(cityId,chapterId,pointId)
								elseif eventName == "end" then
									ViewManager.open("ReWardView",{page=2,type=1,data='',film=0,isWin=self.isWin,againFunc = function()
										self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
									end})
								-- ViewManager.open("PushMapEndLayerView",{film=0})
								end
							end
						
						self:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
						end
					ViewManager.open("PushMapFilmView",{isShowGuochangyun=false,step = storyId[1],endfunc=endfunc1,exitfunc=exitfunc1})
					end
				end 
		elseif itemType==4 then
			local curMaxPoint=self:getCurPassedPointIndex(cityId,chapterId)--当前关卡
			if pointId<=curMaxPoint then
				local function battleHandler(eventName)
					if eventName == "begin" then
						self:Battle(cityId,chapterId,pointId)
					elseif eventName == "end" then
						ViewManager.open("ReWardView",{page=2,type=1,data='',film=0,isWin=self.isWin,againFunc = function()
							self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
						end})
					end
				end
				self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
			else
				local function exitfunc1(eventName)
			
				end
				if  storyId[1]~="0" and storyId[3]~="0" then
					local function endfunc1(eventName)
					local function battleHandler(eventName)
						if eventName == "begin" then
							printTable(31,">>>>>>>>>>>>1111111111111begin")
							self:Battle(cityId,chapterId,pointId)
						elseif eventName == "end" then
							printTable(31,">>>>>>>>>1111111111111end")
							ViewManager.open("ReWardView",{page=2,type=1,data='',film=storyId[3],isWin=self.isWin,againFunc = function()
								self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
							end})
						end
					end
					self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
					end
					ViewManager.open("PushMapFilmView",{isShowGuochangyun=false,step = storyId[1],endfunc=endfunc1,exitfunc=exitfunc1})
				elseif storyId[1]=="0" and storyId[3]~="0" then
					local function battleHandler(eventName)
						if eventName == "begin" then
							self:Battle(cityId,chapterId,pointId)
						elseif eventName == "end" then
							ViewManager.open("ReWardView",{page=2,type=1,data='',film=storyId[3],isWin=self.isWin,againFunc = function()
								self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
							end})
						end
					end
					self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
			elseif storyId[1]~="0" and storyId[3]=="0" then
					local function endfunc1(eventName)
						local function battleHandler(eventName)
							if eventName == "begin" then
								self:Battle(cityId,chapterId,pointId)
							elseif eventName == "end" then
								ViewManager.open("ReWardView",{page=2,type=1,data='',film=0,isWin=self.isWin,againFunc = function()
									self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
								end})
							end
						end
					
					self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
					end
				ViewManager.open("PushMapFilmView",{isShowGuochangyun=false,step = storyId[1],endfunc=endfunc1,exitfunc=exitfunc1})
				end
			end 
		elseif itemType==5 then 
			local function battleHandler(eventName)
				if eventName == "begin" then
					self:Battle(cityId,chapterId,pointId)
				elseif eventName == "end" then
				ViewManager.open("ReWardView",{page=2,type=1,data='',film=0,isWin=self.isWin,againFunc = function()
					self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])
				end})
				end
			end
			self:sendFalseBattle(battleHandler,cityId,chapterId,pointId,storyId[2])


	end
end

function PushMapModel:sendBattleInfo(battleHandler,cityId,chapterId,pointId)
local copyConfig=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
local guankaInfo=copyConfig[pointId];
Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,{fightID=guankaInfo.fightfd,configType=GameDef.BattleArrayType.Chapters,chapterInfo=guankaInfo,skipArray=self.jumpEnterState})
end

function PushMapModel:sendFalseBattle(battleHandler,cityId,chapterId,pointId,FightConfigName)
    local copyConfig=DynamicConfigData.t_chaptersPoint[cityId][chapterId];
    local guankaInfo=copyConfig[pointId];
--     local luaFile = GMModel.currentAssets .."Scripts/CN/Configs/Generate/"..FightConfigName..".lua"
--    local battle_Config = loadstring(io.readfile(luaFile))()
	local arr=string.split(FightConfigName, ",")
	local str=arr[1]
	if PlayerModel.sex==2 then--女的
		str=arr[2]
	end
	if str == "0" then return end
	local battle_Config= DynamicConfigData[str]
	-- local battle_Config= DynamicConfigData[FightConfigName]
	-- if not battle_Config then
	-- 	return
	-- end
	if not battle_Config then
		return
	end
    Dispatcher.dispatchEvent(EventType.Battle_playEditBattle,{fightID=guankaInfo.fightfd,configType=GameDef.BattleArrayType.Chapters,isWin=true,isRecord=false},battle_Config,battleHandler)
end


return PushMapModel
