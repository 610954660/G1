local BaseModel = require "Game.FMVC.Core.BaseModel"
local GuildModel = class("PlayerModel", BaseModel)

function GuildModel:ctor()
	self.settingLv = {
        [0] = {desc = Desc.CohesionReward_str35},
        [1] = {desc = Desc.CohesionReward_str36},
        [2] = {desc = Desc.CohesionReward_str37}
	}
	self._btnListSetting = {
		{action = 0, lable = Desc.CohesionReward_str38, priority = 0},
		{action = 1, lable = Desc.CohesionReward_str39, priority = 0},
		{action = 2, lable = Desc.CohesionReward_str40, priority = 3},
		{action = 3, lable = Desc.CohesionReward_str41, priority = 0},
       -- {action = 4, lable = "全员邮件", priority = 4},
	}
	
	self._btnListSetting1 = {
		{action = 11, lable=Desc.CohesionReward_str42, priority = 5}, 
		{action = 12, lable=Desc.CohesionReward_str43, priority = 5}, 
		{action = 13, lable=Desc.CohesionReward_str44, priority = 5}, 
        {action = 14, lable=Desc.CohesionReward_str45, priority = 1} 
	}
	self.guildQuitTime=0;
	self.guildHave = false
	self.guildApplyList={}--申请入会
	self.guildList = {}--公会信息列表
	self.recommendedguildlist={};--推荐公会列表
	self.guildRecord={}--公会记录
	self.guildBossReward={};--挑战公会boss奖励
	self.guildGuildSkillLevel={};--公会技能等级信息
	self.guildGuildDivunation={};--公会占卜信息
	self.guildfirstLogin={}--首次登陆
	self.guildSkillOpenLv={}
	self.guildBossHurt={}--公会boss最高伤害值
	--次元裂缝
	self.cylfBossData = {}
	self.cylfBossRankData = {}
	self.cylfResultData = {}
	self.cylfMainData = {}
	self.cylfBossDataTemp = {}
	self.guildRecommendIndex=1--公会推荐列表页数
	self.moduleOperInfo={}--公会在线玩家公会操作内容
end


function GuildModel:getGuildBossTitleArrow(bossId)
	local arr={}
	local configInfo= DynamicConfigData.t_boss[bossId]
	if configInfo  then
		arr=  configInfo.tag
	end
	return arr
end

function GuildModel:getGuildcylfBossTitleArrow(bossId)
	local arr={}
	local configInfo= DynamicConfigData.t_GuildWorldBossConfig[bossId]
	if configInfo  then
		arr=  configInfo.tag
	end
	return arr
end

function GuildModel:getBossHurt(copyCode)--公会boss最高伤害值
	local hurt=0
	if self.guildBossHurt[copyCode]==nil then
		return hurt
	end
	return self.guildBossHurt[copyCode]
end


function GuildModel:getFightSceenNeed( ... )
    local config = self:getBossRankConfig( self.cylfBossData.levelId )
	-- local hpGroup={}
    local damage = self.cylfBossData.standardDamage
    local tempArr = {}
	for i=#config,2,-1 do
		if config[i].damage ==0 then
			table.insert(tempArr,1)
		else
			table.insert(tempArr,math.ceil(damage/100*config[i].damage))
		end
	end
	table.insert(tempArr,999999999)
	-- hpGroup = {1}
	-- for i=2,#tempArr do
	-- 	table.insert(hpGroup,tempArr[i]-tempArr[i-1])
	-- end
	-- table.insert(hpGroup,999999999) --王者的怪物最后一管血
	printTable(1,tempArr)
	local bossConfig = self:getBossConfigById( self.cylfBossData.bossId)
	local boosIcon = PathConfiger.getBossHead(bossConfig.bossHead)
    return tempArr,999999999,boosIcon
end

function GuildModel:setCylfMainData( data )
	self.cylfMainData = data
end

function GuildModel:getCylfMainData(  )
	return self.cylfMainData
end

function GuildModel:judgcylfType(configType)
    return configType==GameDef.BattleArrayType.GuildWorldBossNumOne
	or configType==GameDef.BattleArrayType.GuildWorldBossNumTwo
	or configType==GameDef.BattleArrayType.GuildWorldBossNumThree
end

function GuildModel:setCylfMainJoin(  )
	if self.cylfMainData and (not self.cylfMainData.isJoin) then
		self.cylfMainData.isJoin = true
		RedManager.updateValue("V_Guild_CYLF",false)
	end
end

--服务器数据原因 需要缓存早早返回的数据
function GuildModel:setCylfBossDataTemp( data )
	self.cylfBossDataTemp = data
end

function GuildModel:getCylfBossDataTemp(  )
	return self.cylfBossDataTemp
end



function GuildModel:setCylfResultData( data )
	self.cylfResultData = data
end

function GuildModel:getCylfResultData(  )
	return self.cylfResultData
end

function GuildModel:setCylfBossData( data )
	self.cylfBossData = data
end

function GuildModel:getCylfBossData(  )
	return self.cylfBossData 
end

function GuildModel:setCylfDataCount( count )
	self.cylfBossData.challengeCount = count
end

function GuildModel:getLastTime( ... )
	local serverTime = self.cylfBossData.endStamp
	local time = ServerTimeModel:getServerTime()
	local lasttime = serverTime - time
	if lasttime<=0 then lasttime = 0 end
	return lasttime
end

function GuildModel:getBossRankConfig( index )
	local config = DynamicConfigData.t_GuildWorldBossRankConfig[index]
	if config then
		return config
	end
	return {}
end

function GuildModel:getBossRankConfigByIndexs( index,rankIndex )
	local config = DynamicConfigData.t_GuildWorldBossRankConfig[index]
	for i,v in ipairs(config) do
		if v.rank==rankIndex then
			return v
		end
	end
	return nil
end

function GuildModel:getMaxRankLevel( index )
	local config = DynamicConfigData.t_GuildWorldBossRankConfig[index]
	return #config
end

function GuildModel:getWorldBossLevel( id )
	local config = DynamicConfigData.t_GuildWorldBossLevelConfig[id]
	if config then
		return config.level
	end
	return 0
end


function GuildModel:getBossConfigById( id )
	return DynamicConfigData.t_GuildWorldBossConfig[id]
end

function GuildModel:setCylfBossRankData( data )
	self.cylfBossRankData = data
end

function GuildModel:getCylfBossRankData(  )
	return self.cylfBossRankData 
end

function GuildModel:getCylfNumCount( )
	return DynamicConfigData.t_guildSystemParam[3600].worldBossBuyCost
end


function GuildModel:init()
	
end

function GuildModel:getguildFirstLoginState(key)
	if self.guildfirstLogin[key]==nil then
		return true
	end
	return  self.guildfirstLogin[key]
end

function GuildModel:setguildFirstLoginState(key)
	self.guildfirstLogin[key]=false 
	printTable(21,"打印是后的说法11111",key,self.guildfirstLogin[key])
end


function GuildModel:getCurskillId(id)
	local skillMap={}
	local skillLV = self:getguildskillLevel(id)
	printTable(30,"1111111111111111",skillLV)
	local ConfigInfo=DynamicConfigData.t_guildSkill[id]
	if skillLV==0 then
		skillLV=1
	end
    local configCost= ConfigInfo[skillLV]
	local skillArr= configCost.skill
	for i = 1, #skillArr, 1 do
		local info={}
		local skillId=skillArr[i]
		if skillId==0 then
			info["isLock"]=true
			local key="skill"..i
			skillId=DynamicConfigData.t_guildPassiveSkill[id][key]
			info["skillId"]=skillId[1]
			table.insert( skillMap,info) 
		else
			info["isLock"]=false
			info["skillId"]=skillId
			table.insert( skillMap,info) 
		end
	end
	return skillMap
end

function GuildModel:getCurskillLv(id,skillId)
	local lv=0
	local ConfigInfo=DynamicConfigData.t_guildPassiveSkill[id]
	for i = 1, 3, 1 do
		local key="skill"..i
		local skillArr=ConfigInfo[key]
		for k = 1, #skillArr, 1 do
			local lvskill=skillArr[k]
			if lvskill==skillId then
				lv=k
			end
		end
	end
	return lv
end

function GuildModel:curSkillIsJihuo(id,skillLV,curSkill)
	local ConfigInfo=DynamicConfigData.t_guildSkill[id]
	local oldfigCost= ConfigInfo[skillLV-1]
	local configCost= ConfigInfo[skillLV]
	local skillId=0
    if not configCost or not oldfigCost  then
        return false
	end
	local oldskill= oldfigCost.skill
	local curskill= configCost.skill
	for i = 1, #oldskill, 1 do
		local old=oldskill[i]
		local cur=curskill[i]
		if old==0 and cur~=0 then
			skillId=cur
		end
	end
	if skillId~=0 and skillId>=curSkill then
		return true
	end
	return false
end


function GuildModel:showActivateSkillView(id,skillLV)
	local ConfigInfo=DynamicConfigData.t_guildSkill[id]
	local oldfigCost= ConfigInfo[skillLV-1]
	local configCost= ConfigInfo[skillLV]
	local skillId=0
    if not configCost or not oldfigCost  then
        return
	end
	local oldskill= oldfigCost.skill
	local curskill= configCost.skill
	for i = 1, #oldskill, 1 do
		local old=oldskill[i]
		local cur=curskill[i]
		if old==0 and cur~=0 then
			skillId=cur
		end
	end
	if skillId~=0 then
		ViewManager.open("GuildskillsOpenView",{id=skillId})
	end
end

function GuildModel:setGuildSkillOpenLv()
	if next(self.guildSkillOpenLv)==nil then
		for i = 1, 6 do
			local ConfigInfo=DynamicConfigData.t_guildSkill[i]
			for skillLV = 1, #ConfigInfo do
				local oldkey=skillLV-1
				if oldkey<=0 then
					oldkey=1
				end
				local oldfigCost= ConfigInfo[oldkey]
				local configCost= ConfigInfo[skillLV]
				local skillId=0
				if not configCost or not oldfigCost  then
					return
				end
				local oldskill= oldfigCost.skill
				local curskill= configCost.skill
				for i = 1, #oldskill, 1 do
					local old=oldskill[i]
					local cur=curskill[i]
					if old~=cur then
						self.guildSkillOpenLv[cur]=skillLV
					end
				end
				
			end
		end
	
	end
end

function GuildModel:getGuildSkillOpenLv(skilllv)
	printTable(31,"1111111111111111",skilllv,self.guildSkillOpenLv)
	return self.guildSkillOpenLv[skilllv]
end



function GuildModel:setGuildSkillRed()
	local configInfo=DynamicConfigData.t_guildSkill
	local max=0
	for skillId, value in pairs(configInfo) do
		local maxskillLv=#value
		local skillLV = self:getguildskillLevel(skillId)
		if skillLV~=maxskillLv and skillLV>=max then
			max=skillLV
		end
	end
	for skillId, value in pairs(configInfo) do
		--local maxskillLv=#value
		local red= false
		local skillLV = self:getguildskillLevel(skillId)
		 local cost=self:getGuildSkillCost(skillId)
		 printTable(152,"2222222QQQQQQQQQQQQQ",cost,skillId,skillLV,max)
		-- if self.guildHave==true and skillLV==max and cost==true and self:getguildFirstLoginState("GuildSkillRed"..skillId)==true then
		-- 	printTable(21,"打印是后的说法",skillId,self:getguildFirstLoginState("GuildSkillRed"..skillId))
		-- 	red=true
		-- end
		if self.guildHave==true and skillLV==max and cost==true then
			red=true
		end
		RedManager.updateValue("V_Guild_SKILLITEM"..skillId, red);  
	end
end

function GuildModel:getGuildSkillCost(id)
	local curLv= self:getguildskillLevel(id)
	local ConfigInfo=DynamicConfigData.t_guildSkill[id]
	if not ConfigInfo then
		return false;
	end
    local configCost= ConfigInfo[curLv+1]
    if configCost==nil then
        return false;
    end
    local curCost=configCost.cost;  
    local has1=  PlayerModel:getMoneyByType(curCost[1].code)
    local has2=  PlayerModel:getMoneyByType(curCost[2].code)
    if has1<curCost[1].amount or has2<curCost[2].amount then
		return false
    else
		return true
    end
end

function GuildModel:isTogetherGuild(playerId)
	 local together=false
	local memberMap= self.guildList['memberMap']
	if not memberMap then
		return together;
	end
	if memberMap[playerId] then
		together=true;
	end
	return together
end

function GuildModel:getBossViewdi()
	return "UI/Guild/guildBossdi.png";
end

function GuildModel:getDvinationBg()
	return "UI/Guild/guildDvinationBg.jpg";
end

function GuildModel:getQualityFrame(num)
	return "Icon/guild/guildColor"..num..".png";
end

function GuildModel:getFaceIcon(num)
	return "Icon/guild/"..num..".png";
end

function GuildModel:getjurisdictionIcon(num)
	return "Icon/guild/guildjurisdiction"..num..".png";
end

function GuildModel:setFrameViewBg(view,url)
	local frame= view:getChildAutoType('frame')
	if  not frame then
		return
	end
	local fullScreen=frame:getChildAutoType('fullScreen')
	local bgIcon=fullScreen:getChildAutoType('icon')
	bgIcon:setURL(url) 
end

--1个参数只返回属性名,2个参数返回属性值
function GuildModel:getFightAttrName(type,value)
	if value==nil then
		local attrConfig= DynamicConfigData.t_combat[type]
		return attrConfig.name;
	else
		if type<=100 then
			return value
		else
			return value/100 ..'%' 
		end
	end
end

function GuildModel:getguildskillInfo()
	local heroId={}
	for key, value in pairs(CardLibModel.__heroInfos) do
		if value then
			local uidList=value;
			for uid, info in pairs(uidList) do
				local codeMap= heroId[info.code] or {};
				codeMap[#codeMap+1]=info;
				heroId[info.code]=codeMap;
			end
		end
	end
	for key, value in pairs(heroId) do
		table.sort( value, function (a,b)
			 return a.star>b.star;
		end )
	end
	local hasList= heroId;
	local temp={}
	local sertList={}
	local configInfo=DynamicConfigData.t_hero;
	local clonInfo=clone(configInfo) 
	for key, value in pairs(clonInfo) do
		if value.heroStar>4 and value.isGet==1 then
			local list= temp[value.professional] or {}
			value['has']=false
			if hasList[value.heroId]~=nil then
				value['has']=true
				value.heroStar=hasList[value.heroId][1].star;
			end
			 if sertList[value.heroId]==nil then
			
				list[#list+1]=value;
			 end
			sertList[value.heroId]=value
			temp[value.professional]=list;
		end
	end
	return temp;
end

function GuildModel:getguildskillLevel(id)
 local level=self.guildGuildSkillLevel[id]
	if not level then
		return 0;
	end
	return level;
end

function GuildModel:getguildBossisOpen(type)
	local timeInfo= self.guildList.boss;
	if not timeInfo then
		return false
	end
	local time=timeInfo[type];
	local curTime = ServerTimeModel:getServerTime()
	--local remintime=time.timeStamp-curTime
	--printTable(11,'>>>>>>>2',type,time,curTime,remintime)
	if time then
		local remintime=time.timeStamp-curTime
		if remintime>0 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function GuildModel:getBossRemainTime(type)
	local timeInfo= self.guildList.boss;
	local time=timeInfo[type];
	local curTime = ServerTimeModel:getServerTime()
	if time then
		 local reminTime=time.timeStamp-curTime;
		 printTable(11,'>>>>>>>1',timeInfo,curTime,reminTime)
		return 	math.floor(reminTime/3600),	math.floor((reminTime%3600)/60)
	end
end

function GuildModel:getBossInfo()
	local boss= DynamicConfigData.t_boss
	local temp={}
	for key, value in pairs(boss) do
		temp[#temp+1]=value;
	end
	return temp;
end

function GuildModel:getPostionPromotionBtn(priority)
	local listData = {}
	local listValue={}
	local array = DynamicConfigData.t_guildPosition[priority]
    local settingData = self._btnListSetting1
    for _, v in ipairs(settingData) do
        if (table.indexof(array.privilegeList, v.priority)) ~= false then
			table.insert(listData, v.lable)
			table.insert(listValue, v.action)
        end
    end
   return listData ,listValue
end

function GuildModel:getPostionSettingBtn(priority)
	local array= DynamicConfigData.t_guildPosition[priority] 
	if table.indexof(array.privilegeList,6)~=false then
		return true
	end
		return false;
end

function GuildModel:getPostionNoticeBtn(priority)
    local array= DynamicConfigData.t_guildPosition[priority] 
	if table.indexof(array.privilegeList,7)~=false then
		return true
	end
		return false;
end

function GuildModel:getPostionApplyRed(priority)
    local array= DynamicConfigData.t_guildPosition[priority] 
	if table.indexof(array.privilegeList,3)~=false then
		return true
	end
		return false;
end
--权限开启boss
function GuildModel:getPostionOpenbossBtn(priority)
    local array= DynamicConfigData.t_guildPosition[priority] 
	if table.indexof(array.privilegeList,2)~=false then
		return true
	end
		return false;
end

--占卜别人帮助的次数
function GuildModel:getGuildupLuckCount()
	local info=DynamicConfigData.t_guildSystemParam
	for key, value in pairs(info) do
		return value.upLuckCount;
	end
end

function GuildModel:getGuildCreateCost()
	local info=DynamicConfigData.t_guildSystemParam
	for key, value in pairs(info) do
		return value.maxApplyNum , value.createCost, value.renameCost;
	end
end

function GuildModel:getGuildJoinTime()
	local info=DynamicConfigData.t_guildSystemParam
	for key, value in pairs(info) do
		return value.joinInterval;
	end
end

function GuildModel:getGuildBossOpencost()
	local info=DynamicConfigData.t_guildSystemParam
	for key, value in pairs(info) do
		return value.openPoint;
	end
end

function GuildModel:getGuildDivinationCount()--等到最大占卜次数改运次数
	local divinationCount=0
	local retryCount=0
	local luckyVal=0
	local  serverInfo= self.guildGuildDivunation;
	if serverInfo and next(serverInfo)~=nil then
		 divinationCount=serverInfo.divinationCount;
		 retryCount=serverInfo.retryCount;
		 luckyVal=serverInfo.luckyVal;
	end
	local config=0
	local config1=0
	local cost=0
	local info=DynamicConfigData.t_guildSystemParam
	for key, value in pairs(info) do 
		config= value.divinationCount;
		config1=value.retryCount;
		cost=value.divinationCost
	end
	if self.guildHave==true and (config-divinationCount)>0 and  luckyVal>=cost then
		RedManager.updateValue("V_Guild_DIVINATIONRED",true);  
	else
		RedManager.updateValue("V_Guild_DIVINATIONRED",false);  
	end

	return  config-divinationCount,config1-retryCount
end

function GuildModel:getGuildisOpenTimeView()
	local isOpen=false
	local remain=0
	local curTime = ServerTimeModel:getServerTime()
	local time= self:getGuildJoinTime()
	if curTime-self.guildQuitTime<=time then
		isOpen=true
		remain=math.ceil( (time-(curTime-self.guildQuitTime))/60 ) 
	end
	return  isOpen ,remain
end

function GuildModel:getGuildProfessionalIcon(Position)
	return  PathConfiger.getCardProfessional(Position);
end

function GuildModel:getGuildskillTypeName(id)
	local name={[1]=Desc.CohesionReward_str70,[2]=Desc.CohesionReward_str71,[3]=Desc.CohesionReward_str72,[4]=Desc.CohesionReward_str73,[5]=Desc.CohesionReward_str74,[6]=Desc.CohesionReward_str75}
	if name[id] then
		return  name[id]
	end
	return Desc.CohesionReward_str70
end

function GuildModel:getGuildPosition(Position)
	if Position==1 then
		return Desc.CohesionReward_str76
	elseif  Position==2 then
		return Desc.CohesionReward_str77
	elseif Position==3 then	
		return Desc.CohesionReward_str78
	end
end

function GuildModel:getGuildLuckText(num)
	local config= DynamicConfigData.t_guildLuck
	for key, value in pairs(config) do
		if num>=value.minValue and num<=value.maxValue then
		return value.luckLv,value.desc,self:getFaceIcon(value.face);
	end
	end
end

function GuildModel:getGuildFirstRankReward(rankType,hurtNum)
	local gamePlayType=500;
	if rankType==GameDef.RankType.GuildLimitBoss then
		gamePlayType=501
	end
	local configInfo = DynamicConfigData.t_bossReward
	local configData = configInfo[gamePlayType]
	for key, value in pairs(configData) do
		if  hurtNum>=value.damageMin and hurtNum<=value.damageMax then
			 local rewardId=value.extraReward;
			 local reward =DynamicConfigData.t_reward[rewardId]; 
			 printTable(9,'>>>>>>>',rewardId,reward.item1)
			 if reward then
				return reward.item1;
			 end
		elseif key==#configData and hurtNum>=value.damageMax then
			local rewardId=value.extraReward;
			local reward =DynamicConfigData.t_reward[rewardId]; 
			if reward then
				return reward.item1;
			end
		end
	end
	return {};
end

function GuildModel:getGuildOnline(item)
	if item.onlineState==1 then
		return Desc.CohesionReward_str62
	else
		local time = ServerTimeModel:getServerTime()
		local onlimeTime=time-item.offlineStamp;
		--printTable(9,'?????????????',time,item.offlineStamp,onlimeTime)
		local hour=3600*24
		local hour1=3600*24*30
		local hour2=3600*24*30*12
		if onlimeTime<3600 then
			if onlimeTime/60<=1 then 
				return  Desc.CohesionReward_str63
			end
			return  math.floor((onlimeTime/60) ) ..Desc.CohesionReward_str64
			elseif onlimeTime>=3600 and onlimeTime<(hour) then
				return math.floor((onlimeTime/3600))..Desc.CohesionReward_str65
			elseif onlimeTime>=(hour) and onlimeTime<(hour1) then
				return math.floor((onlimeTime/(hour))) ..Desc.CohesionReward_str66
			elseif onlimeTime>=(hour1) and onlimeTime<(hour2) then
				return math.floor((onlimeTime/(hour1))) ..Desc.CohesionReward_str67
			elseif onlimeTime>(hour2) then
				return math.floor((onlimeTime/(hour2))) ..Desc.CohesionReward_str68
		end
		return Desc.CohesionReward_str69
	end
end

function GuildModel:getGuildHead(headId)
	if headId==nil then
		return "Icon/guild/1.png";
	else
		return "Icon/guild/"..headId..'.png';
	end
end

function GuildModel:getGuildName()
	local str=""
	if not self.guildList then
		return str
	end
	return 	self.guildList.name	
end


function GuildModel:getGuildPlayerHead(headId)
	if headId==nil then
		return PathConfiger.getHeroHead(1);
	end
	return PathConfiger.getHeroHead(headId);
end

function GuildModel:setGuildCardColor(star)
	local resInfo= DynamicConfigData.t_heroResource[star]
	local color= resInfo.headRes
	if star==nil then
		return "Icon/rarity/k_1.png";
	end
	return "Icon/rarity/k_"..color..'.png';
end


function GuildModel:playersSort(temp)
	table.sort(temp,function(a,b)
		local infoMap= self.guildList.memberMap;
		local infoA= infoMap[a];
		local infoB=infoMap[b];
		if not infoA or not infoB then
			return;
		end
		if infoA.onlineState==infoB.onlineState then
			if infoA.onlineState==1 then
				return  infoA.position<infoB.position
			elseif infoA.onlineState==0 then
				if infoA.offlineStamp ==infoB.offlineStamp then
					return infoA.position<infoB.position
				else
					return infoA.offlineStamp>infoB.offlineStamp
				end
			end
		else
			return infoA.onlineState>infoB.onlineState
		end
	end)
	return temp;
end

--获取推荐帮会
function GuildModel:getRecommendGuild(tag)
	local function success(data)
		printTable(8,"获取推荐帮会",data)
		local temp={}
		for key, value in pairs(data.result) do
			temp[#temp+1]=value
		end
		self.guildRecommendIndex=data.index or 1
		TableUtil.sortByMap(temp, {{key = "activeScore", asc = true}});
		self.recommendedguildlist=temp;
		Dispatcher.dispatchEvent(EventType.guild_up_recommendedList);
	end
	printTable(8,"获取推荐帮会")
	local info={
	  index=tag
	}
	RPCReq.Guild_GetRecommendGuild(info,success)
end

--修改公会名称
function GuildModel:setGuildName(name)
	local function success(data)
		printTable(8,"修改公会名称",data)
		RollTips.show(Desc.CohesionReward_str61);
		ViewManager.close('GuildReNameView');
	end
	local info = {
		name = name
	}
	printTable(8,"修改公会名称",info)
	RPCReq.Guild_SetGuildName(info,success)
end


--修改公会公告
function GuildModel:setGuildNotice(notice)
	local function success(data)
		printTable(8,"修改公会公告",data)
		RollTips.show(Desc.CohesionReward_str61);
		ViewManager.close("GuildEditNoticeView");
	end
	local info = {
		notice = notice
	}
	printTable(8,"修改公会公告",info)
	RPCReq.Guild_SetGuildNotice(info,success)
end


--#修改公会信息
function GuildModel:setGuildInfo(guildIcon,announcement,joinLimitInfo)
	local function success(data)
		printTable(8,"修改公会信息",data)
		RollTips.show(Desc.CohesionReward_str61);
		ViewManager.close('GuildSettingView');
	end
	local info = {
		guildIcon= guildIcon ,--     1:integer                   #公会图标
        announcement  =announcement,--  2:string                    #公会宣言
        joinLimitInfo =  joinLimitInfo--3:Guild_JoinLimitInfo       #入会条件
	}
	printTable(8,"修改公会信息",info)
	RPCReq.Guild_SetGuildInfo(info,success)
end


--#离开公会请求
function GuildModel:leaveGuildReq()
	local function success(data)
		printTable(8,"#离开公会请求",data)
		if data.result==true then
			ViewManager.close('GuildMainView')
			ViewManager.close('GuildMallView')
		end
	end
	printTable(8,"#离开公会请求")
	RPCReq.Guild_LeaveGuildReq({},success)
end

--移除公会成员
function GuildModel:kickMember(play,playerName)
	local function success(data)
		printTable(12,"移除公会成员",data)
		if data.result==true then
			RollTips.show(string.format( Desc.CohesionReward_str46,playerName))
		end
	end
	local info = {
		playerId = play-- #玩家id
	}
	printTable(8,"移除公会成员",info)
	if play==PlayerModel.userid then
		RollTips.show(Desc.CohesionReward_str60)
	else
		RPCReq.Guild_KickMember(info,success)
	end
end


--调整成员职位
function GuildModel:setMemberPosition(playerId,position,type,playerName)
	local function success(data)
		printTable(12,"调整成员职位返回",data)
		local posStr=self:getGuildPosition(position)
		if type==1 and data.result==true then
			RollTips.show(string.format( Desc.CohesionReward_str47,playerName, posStr))
		elseif type==2 and data.result==true then
			RollTips.show(string.format(Desc.CohesionReward_str48,playerName,posStr))
		end
	end
	local info = {
		playerId =playerId,     --  1:integer       #玩家id
        position  =position,     -- 2:integer       #职位id
	}
	printTable(8,"调整成员职位",info)
	if playerId==PlayerModel.userid then
		RollTips.show(Desc.CohesionReward_str59)
	elseif position>3 then
		RollTips.show(Desc.CohesionReward_str58)
	else
		RPCReq.Guild_SetMemberPosition(info,success)
	end
end

--#转移会长
function GuildModel:transferLeader(playerId,playerName)
	local function success(data)
		printTable(12,"#转移会长返回",data)
		if data.result==true then
			RollTips.show(playerName..Desc.CohesionReward_str49)
		end
	end
	local info = {
		playerId =playerId,     --  1:integer       #玩家id
	}
	if playerId==PlayerModel.userid then
		RollTips.show('您不能调整自己职位')
	else
	printTable(8,"#转移会长",info)
	RPCReq.Guild_TransferLeader(info,success)
	end
end

--当前都是查询的本服
function GuildModel:guildBaseInfoReq(guildId)
	local function success(data)
		printTable(8,"当前都是查询的本服",data)
	end
	local info = {
		guildId    =  guildId,      -- 1:integer           #公会id
	}
	printTable(8,"当前都是查询的本服",info)
	RPCReq.Guild_GuildBaseInfoReq(info,success)
end


--请求获取自己公会详细信息
function GuildModel:guildInfoReq()
	local function success(data)
		printTable(8,"请求获取自己公会详细信息",data)
	end
	printTable(8,"请求获取自己公会详细信息")
	RPCReq.Guild_GuildInfoReq({},success)
end


--请求创建公会
function GuildModel:createGuild(name,icon)
	local function success(data)
		printTable(8,"请求创建公会",data)
		RollTips.show(Desc.CohesionReward_str57)
		 ViewManager.close('GuildListView')	
		 ViewManager.open('GuildMallView')	
	end
	local info = {
		name =name,          -- 1:string        #公会名字
        icon =icon,         --  2:integer       #公会图标id
	}
	printTable(8,"请求创建公会",info)
	RPCReq.Guild_CreateGuild(info,success)
end

--加入公会请求
function GuildModel:joinGuildReq(id)
	local function success(data)
		printTable(155,"加入公会请求",data)
		if data.result==1 then
			ViewManager.close("GuildApplyView")	
			ViewManager.close("GuildListView")	
			ViewManager.open("GuildMallView")	
			RollTips.show(Desc.CohesionReward_str55)
		elseif data.result==2 then
			RollTips.show(Desc.CohesionReward_str56)
			ViewManager.close("GuildApplyView")	
		end
	end
	local info = {
		id  =id, --            1:integer       #公会id
	}
	printTable(155,"加入公会请求",info)
	RPCReq.Guild_JoinGuildReq(info,success)
end

--批准加入公会
function GuildModel:acceptJoinGuild(id,type)
	local function success(data)
		printTable(8,"批准加入公会",data)
		if type==1 and data.result==true then
			RollTips.show(Desc.CohesionReward_str54)
		end
	end
	local info = {
		id    =id  ,      -- 1:integer       #玩家id
		type  =type          --2:integer       #类型 1同意, 2拒绝
	}
	printTable(8,"批准加入公会",info)
	RPCReq.Guild_ApplyOperate(info,success)
end


--搜索公会
function GuildModel:serchGuildById(guildId)
	local function success(data)
		printTable(8,"搜索公会",data)
		if data and data.result then
			Dispatcher.dispatchEvent(EventType.guild_Apply_upData,data.result);
		end
	end
	local info = {
		guildId  =guildId        -- 1:integer       #玩家id
	}
	printTable(8,"搜索公会",info)
	RPCReq.Guild_QueryGuildById(info,success)
end

--搜索公会
function GuildModel:serchGuildByName(name)
	local function success(data)
		printTable(8,"搜索公会",data)
		if data then
			self.recommendedguildlist={};
			local temp={}
			for key, value in pairs(data.result) do
				temp[#temp+1]=value
			end
			TableUtil.sortByMap(temp, {{key = "activeScore", asc = true}});
			self.recommendedguildlist=temp
			Dispatcher.dispatchEvent(EventType.guild_up_recommendedList);
		end
	end
	local info = {
		name  =name        -- 1:integer       #玩家id
	}
	printTable(8,"搜索公会",info)
	RPCReq.Guild_QueryGuildByName(info,success)
end
--全部忽略
function GuildModel:guildAllignor()
	local function success(data)
		printTable(8,"全部忽略",data)
	end
	local info = {
		type  =1        --#类型, 1全部忽略, 2全部同意
	}
	RPCReq.Guild_ApplyOperateQuickly(info,success)
end

--全部同意
function GuildModel:guildAllagreed()
	local function success(data)
		printTable(12,"全部同意",data)
	end
	local info = {
		type  =2        --#类型, 1全部忽略, 2全部同意
	}
	printTable(8,"全部同意")
	RPCReq.Guild_ApplyOperateQuickly(info,success)
end

--#开启公会限时boss
function GuildModel:openGuildBoss(gamePlayType)
	local function success(data)
		printTable(22,"开启公会限时boss返回成功",data)
		RollTips.show(Desc.CohesionReward_str53) 
		local info={}
		 info[data.gamePlayType]=data
		 self.guildList.boss=info;
		 MaterialCopyModel:guildBossRed()
		Dispatcher.dispatchEvent(EventType.guild_up_guildOpenBossSuc);
	end
	local info = {
		gamePlayType = gamePlayType      --1:integer     #玩法
	}
	printTable(8,"开启公会限时boss",info)
	RPCReq.Guild_OpenGuildBoss(info,success)
end

--#挑战公会boss
function GuildModel:challengeGuildBoss(gamePlayType)
	local function success(data)
		printTable(9,"挑战公会boss返回成功",data)
		self.guildBossReward=data;
		--Dispatcher.dispatchEvent(EventType.cardView_levelUpSuc,data);
	end
	local info = {
		gamePlayType= gamePlayType      -- 1:integer       #玩法
	}
	printTable(9,"挑战公会boss",info)
	RPCReq.Guild_ChallengeGuildBoss(info,success)
end

--#公会技能升级
function GuildModel:skillLevelUp(id)
	local function success(data)
		printTable(25,"公会技能升级返回成功",data)
		self.guildGuildSkillLevel[id]=data.level
		local fight = ModelManager.CardLibModel:getFightVal() or 0
		local addNum=data.addCombat or 0
		printTable(25,"公会技能升级返回成功1",addNum,fight)
		if addNum>0 then
			RollTips.showAddFightPoint(addNum)
		end
		self:showActivateSkillView(id,data.level)
		self:setGuildSkillRed()
		Dispatcher.dispatchEvent(EventType.guild_up_guildSkillupLv,data);
	end
	local info = {
		id=id--1:integer       #技能id
	}
	printTable(9,"公会技能升级",info)
	RPCReq.Guild_SkillLevelUp(info,success)
end

--#公会技能重置
function GuildModel:skillReset(id)
	local function success(data)
		printTable(9,"公会技能重置返回成功",data)
		RollTips.show(Desc.CohesionReward_str52)
		self.guildGuildSkillLevel[id]=data.level
		self:showActivateSkillView(id,data.level)
		self:setGuildSkillRed()
		Dispatcher.dispatchEvent(EventType.guild_up_guildSkillResetLv,data);
	end
	local info = {
		id=id--1:integer       #技能id
	}
	printTable(9,"公会技能重置",info)
	RPCReq.Guild_SkillReset(info,success)
end

--#公会占卜请求
function GuildModel:divinationReq()
	local function success(data)
		printTable(18,"公会占卜请求成功",data)
		if data then
			self.guildGuildDivunation=data.divinationInfo;
			Dispatcher.dispatchEvent(EventType.guild_up_guildDivinationPlayTexiao,data);	
		end
	end
	local info = {
	}
	printTable(9,"公会占卜请求",info)
	RPCReq.Guild_DivinationReq(info,success)
end

--#领取公会占卜奖励请求
function GuildModel:divinationRewardReq()
	local function success(data)
		printTable(18,"领取公会占卜奖励请求成功",data)
		if data then
			self.guildGuildDivunation=data.divinationInfo;
			Dispatcher.dispatchEvent(EventType.show_gameReward)
			Dispatcher.dispatchEvent(EventType.guild_up_guildDivination,data);	
		end
	end
	local info = {
	}
	printTable(9,"领取公会占卜奖励请求",info)
	RPCReq.Guild_DivinationRewardReq(info,success)
end

--#公会占卜改运请求
function GuildModel:divinationRetryReq()
	local function success(data)
		printTable(20,"公会占卜改运请求成功",data)
		if data then
			local oldNum=self.guildGuildDivunation.cellNum or 1
			self.guildGuildDivunation=data.divinationInfo;
			if self.guildGuildDivunation and oldNum~=data.divinationInfo.cellNum then
				Dispatcher.dispatchEvent(EventType.guild_up_guildDivinationXiaoGuo,{old=oldNum,curNum=data.divinationInfo.cellNum,result=true});		
			else
				Dispatcher.dispatchEvent(EventType.guild_up_guildDivinationXiaoGuo,{old=oldNum,curNum=data.divinationInfo.cellNum,result=false});		
			end
			
		end
	end
	local info = {
	}
	printTable(9,"公会占卜改运请求",info)
	RPCReq.Guild_DivinationRetryReq(info,success)
end

--#帮助提升公会占卜手气请求
function GuildModel:divinationHelpReq(playerId)
	local function success(data)
		printTable(153,"帮助提升公会占卜手气请求成功",data)
		if data and data.mineVal then
			RollTips.show(string.format(Desc.CohesionReward_str50,data.mineVal))
		end
		-- if self.guildGuildDivunation and  self.guildGuildDivunation.luckyVal then
		-- 	self.guildGuildDivunation.luckyVal=data.value;
		-- end
		Dispatcher.dispatchEvent(EventType.guild_up_guildDivination,data);	
	end
	local info = {
		playerId =playerId       --1:integer       #目标玩家id
	}
	printTable(9,"帮助提升公会占卜手气请求",info)
	RPCReq.Guild_DivinationHelpReq(info,success)
end

--#占卜提升手气帮助请求
function GuildModel:divinationLuckyReq()
	local function success(data)
		printTable(9,"占卜提升手气帮助请求",data)
	end
	printTable(9,"帮助提升公会占卜手气请求") 
	RPCReq.Guild_DivinationLuckyReq({},success)
end

--#扫荡工会boss
function GuildModel:QuickChallengeGuildBoss(copyCode)
	local function success(data)
		printTable(9,"占卜提升手气帮助请求",data)
	end
	printTable(9,"帮助提升公会占卜手气请求")
	RPCReq.Guild_QuickChallengeGuildBoss({gamePlayType=copyCode},success)
end

--#上报公会操作
function GuildModel:reportGuildOper(operId)
	local function success(data)
		printTable(159,"上报公会操作请求",data)
	end
	local info={
		operId = operId        --1:integer       #操作编号
	}
	printTable(159,"上报公会操作请求操作")
	RPCReq.Guild_ReportGuildOper(info,success)
end

--#获取公会在线玩家公会操作内容
function GuildModel:GetGuildMemberOperInfoReq()
	local function success(data)
		if data and data.operInfo then
			self.moduleOperInfo={}
			for key, value in pairs(data.operInfo) do
				local map=	self.moduleOperInfo[value.operId]
					if not map then
						map={}
					end	 
				map[key]=value
				self.moduleOperInfo[value.operId]=map
			end
			Dispatcher.dispatchEvent(EventType.guild_moduleshow_upData);		
		end
		printTable(159,"获取公会在线玩家公会操作内容返回",data)
	end
	local info={
	}
	printTable(159,"获取公会在线玩家公会操作内容")
	RPCReq.Guild_GetGuildMemberOperInfoReq(info,success)
end

function GuildModel:isBossArrayType(arrayType)
   return arrayType == GameDef.BattleArrayType.GuildWorldBossNumOne
	or arrayType == GameDef.BattleArrayType.GuildWorldBossNumTwo
	or arrayType == GameDef.BattleArrayType.GuildWorldBossNumThree
	or arrayType==GameDef.BattleArrayType.GuildDailyBoss 
	or arrayType==GameDef.BattleArrayType.GuildLimitBoss
end


return GuildModel
