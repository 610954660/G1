--added by wyang
--公会控制器
local GuildController = class("GuildController",Controller)

function GuildController:Guild_PlayerGuildInfo(_,data)
	--#个人公会信息通知
	if data.playerGuildInfo.guildId==0 then
		GuildModel.guildHave=false;
		Dispatcher.dispatchEvent(EventType.guild_exit_evet);
		GuildModel.guildQuitTime=data.playerGuildInfo.leaveStamp;
	end
	if data.playerGuildInfo.guildSkillMap then
		for key, value in pairs(data.playerGuildInfo.guildSkillMap) do
			GuildModel.guildGuildSkillLevel[value.id]=value.level
		end
	end
	if data.playerGuildInfo.divination then
		GuildModel.guildGuildDivunation=data.playerGuildInfo.divination;
		GuildModel:getGuildDivinationCount();
		Dispatcher.dispatchEvent(EventType.guild_up_guildDivination);	
	end
	if data.playerGuildInfo.bossMap then--#公会boss数据 如果无此数据, 默认所有boss数据为初始值即伤害值为0
		for key, value in pairs(data.playerGuildInfo.bossMap) do
			GuildModel.guildBossHurt[value.type]=value.maxDamage
		end
	end
	printTable(22,'个人公会信息通知',data.playerGuildInfo.divination)
	GuildModel:setGuildSkillRed()--公会技能红点
	MaterialCopyModel:guildBossRed()
	printTable(30,'个人公会信息通知',data)
end

function GuildController:Guild_GuildInfoNotify(_,data)
	--完整公会信息  注意这个同步的就是当前公会完整的最新信息
	printTable(22,'完整公会信息注意这个同步的就是当前公会完整的最新信息',data.guildInfo.recordInfo)
	if data==nil then
		return;
	end
	GuildModel.guildList=data.guildInfo;
	local temp={}
	for key, value in pairs(GuildModel.guildList.memberMap) do
		temp[#temp+1]=value.playerId;
		if value.playerId==PlayerModel.userid then
			GuildModel.guildList['myGuildPosition']= value.position;
		end
	end
	GuildModel.guildList['guildPlayer']=temp
	--公会记录
	self:setRecordInfo(GuildModel.guildList.recordInfo) 
	GuildModel.guildHave=true;
	GuildModel:getGuildDivinationCount();
	GuildModel:setGuildSkillRed()--公会技能红点
	MaterialCopyModel:guildBossRed()
	Dispatcher.dispatchEvent(EventType.guild_add_evet);
end

function GuildController:Guild_GuildMemberUpdate(_,data)
	--公会成员变更信息
	printTable(8,'公会成员变更信息',data)
	local playerList= GuildModel.guildList['guildPlayer']
	local memberMap= GuildModel.guildList['memberMap']
	if not memberMap then
		return;
	end
	local updateInfo=data.updateInfo;
	for key, value in pairs(updateInfo) do
		local id=0
		id=value.memberInfo.playerId
		if value.type==1 then
			if memberMap[id]==nil then
				table.insert(playerList,id) 
				memberMap[id]=value.memberInfo;
				GuildModel.guildList.memberNum=GuildModel.guildList.memberNum+1
			end
			 elseif value.type==2 then
				if memberMap[id]~=nil then
					memberMap[id]=value.memberInfo;
					if id==PlayerModel.userid then
						GuildModel.guildList['myGuildPosition']= value.memberInfo.position;
						Dispatcher.dispatchEvent(EventType.guild_up_guildBaseInfoPosTion);
					end
				end
			 elseif value.type==3 then
				id=value.memberInfo.playerId;
				local num=table.indexof(playerList,id)
				table.remove(playerList,num) 
				memberMap[id]=nil;
				GuildModel.guildList.memberNum=GuildModel.guildList.memberNum-1
		end
	end
	 GuildModel.guildList['guildPlayer']=playerList;
	GuildModel.guildList['memberMap']=memberMap;
	Dispatcher.dispatchEvent(EventType.guild_up_guildPlayerList);
	Dispatcher.dispatchEvent(EventType.guild_up_guildBaseInfo);
end

function GuildController:Guild_RecordInfoUpdate(_,data)
	printTable(17,'公会记录变更信息',data)
	self:setRecordInfo(data.recordInfo)
end

function GuildController:setRecordInfo (recordInfo)
	for key, value in pairs(recordInfo) do
		if not value then
			return
		end
		local str=''
		local item={}
		if  value.type==1 then
			if value.playerName then
				str= value.playerName..DescAuto[156] -- [156]='加入了公会'
			end
			 elseif value.type==2 or value.type==3 then
				if value.playerName then
					str= value.playerName..DescAuto[157] -- [157]='退出了公会'
				end
			 elseif value.type==4 then
				local pos=GuildModel:getGuildPosition(value.position)
				if value.playerName then
					str= value.playerName..DescAuto[158]..pos; -- [158]='被任命为'
				end
		end
		item['str']=str
		item['info']=value;
		table.insert( GuildModel.guildRecord, item )
	end
	Dispatcher.dispatchEvent(EventType.guild_up_recordList);
end

function GuildController:Guild_GuildBaseInfoUpdate(_,data)
	--公会其他变更信息
	printTable(8,'公会其他变更信息',data)
	local guidlInfo=GuildModel.guildList;
	local curGuildInfo=data.guildBaseInfo
	if  curGuildInfo.id  then guidlInfo.id  = curGuildInfo.id end
	if  curGuildInfo.serverId  then guidlInfo.serverId  = curGuildInfo.serverId end
	if  curGuildInfo.name  then guidlInfo.name  = curGuildInfo.name end
	if  curGuildInfo.icon  then guidlInfo.icon  = curGuildInfo.icon end
	if  curGuildInfo.level  then guidlInfo.level  = curGuildInfo.level end
	if  curGuildInfo.exp  then guidlInfo.exp  = curGuildInfo.exp end
	if  curGuildInfo.activeScore  then guidlInfo.activeScore  = curGuildInfo.activeScore end
	if  curGuildInfo.memberNum  then guidlInfo.memberNum  = curGuildInfo.memberNum end
	if  curGuildInfo.leaderId  then guidlInfo.leaderId  = curGuildInfo.leaderId end
	if  curGuildInfo.leaderName  then guidlInfo.leaderName  = curGuildInfo.leaderName end
	if  curGuildInfo.notice  then guidlInfo.notice  = curGuildInfo.notice end
	if  curGuildInfo.announcement  then guidlInfo.announcement  = curGuildInfo.announcement end
	if  curGuildInfo.joinLimitInfo  then guidlInfo.joinLimitInfo  = curGuildInfo.joinLimitInfo end
	if  curGuildInfo.applyInfo  then guidlInfo.applyInfo  = curGuildInfo.applyInfo end
	GuildModel.guildList =guidlInfo;
	MaterialCopyModel:guildBossRed()
	Dispatcher.dispatchEvent(EventType.guild_up_guildBaseInfo);		 
end

function GuildController:Guild_LeaveGuildNotify(_,data)
	--公会解散通知
	--type            1:integer       # 1自行离开, 2被移除公会, 3公会解散
	printTable(22,'公会解散通知',data)
	if data.type==1 then
		RollTips.show(DescAuto[159]) -- [159]='您已退出公会'
	elseif data.type==2 then
		RollTips.show(DescAuto[160]) -- [160]='您被移除出本公会'
	elseif data.type==3 then
		RollTips.show(DescAuto[161]) -- [161]='您的公会已被解散'
	end
	--GuildModel.guildList={}
	GuildModel.guildHave=false
	GuildModel:getGuildDivinationCount();
	GuildModel:setGuildSkillRed()--公会技能红点
	MaterialCopyModel:guildBossRed()
	GuildLeagueModel:checkRed()
end

--#入会申请信息更新通知
function GuildController:Guild_ApplyInfoUpdate(_,data)
	printTable(8,'入会申请信息更新通知',data)
	if data==nil or data.updateInfo==nil then
		return;
	end
	for key, value in pairs(data.updateInfo) do
		local id= value.applyInfo.playerId
		local arr=GuildModel.guildApplyList
		local indexInfo=false
		for i = 1, #arr do
		if arr[i].playerId == id then 
				indexInfo=i;
				break;
			end
		end
		if value.type==1 then--新增
			RedManager.updateValue("V_Guild_APPLYRED", true);  
			if indexInfo==false then
				table.insert(GuildModel.guildApplyList ,value.applyInfo ) 
				printTable(8,'入会申请信息更新通知1',GuildModel.guildApplyList)
			end
		elseif value.type==2 then--删除
			if indexInfo~=false then
				table.remove(GuildModel.guildApplyList ,indexInfo) 
				printTable(8,'入会申请信息更新通知2',GuildModel.guildApplyList)
			end
		end
	end
	Dispatcher.dispatchEvent(EventType.guild_up_ApplyList);
end

--#申请信息通知
function GuildController:Guild_ApplyInfoNotify(_,data)
	printTable(8,'申请信息通知',data)
	if data then
		GuildModel.guildApplyList=data.applyInfo;
		if #data.applyInfo>0 then
			local posTion = GuildModel.guildList.myGuildPosition
			if posTion==nil then
				posTion=3;
			end
			local redVisi= GuildModel:getPostionApplyRed(posTion)
			RedManager.updateValue("V_Guild_APPLYRED", redVisi);  
		end
		Dispatcher.dispatchEvent(EventType.guild_up_ApplyList);
	end
end

--#玩家公会BOSS信息通知 #这个更新的就是当前最新的BOSS信息
function GuildController:Guild_GuildBossInfoNotify(_,data)
	printTable(22,'这个更新的就是当前最新的BOSS信息',data)
	if data then
		if next(data.bossInfo) then
		--local info={}
		-- info[data.bossInfo.gamePlayType]=
		 GuildModel.guildList.boss=data.bossInfo;
		 MaterialCopyModel:guildBossRed()
		Dispatcher.dispatchEvent(EventType.guild_up_guildOpenBossSuc);
		end
	end
end

function GuildController:Guild_WorldBossActInfoNotify( _,data )
	printTable(1,"Guild_WorldBossActInfoNotify",data)
	local lastdata = GuildModel:getCylfBossData( )
    if lastdata and lastdata.bossId ~= data.bossId then --服务器时间到达 怪物boss不一致 重新请求刷新
		local params = {}
	    params.onSuccess = function (res )
	        local data = res.worldBossInfo
	        GuildModel:setCylfBossData( data )
	        Dispatcher.dispatchEvent("guild_update_fissure")
	    end
	    RPCReq.Guild_WorldBossInfoReq(params, params.onSuccess)
	end

	GuildModel:setCylfMainData( data.actInfo)
	    --Boss活动开始 自己并没有参与过
    local data = GuildModel:getCylfMainData()
    if not data.isJoin then
    	local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildFissure.id)
    	if tips then
    		RedManager.updateValue("V_Guild_CYLF",true)
    	end
    end
	Dispatcher.dispatchEvent(EventType.guild_cylf_update);
end

function GuildController:player_levelUp( ... )
	local data = GuildModel:getCylfMainData()
    if not data.isJoin then
    	local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildFissure.id)
    	if tips then
    		RedManager.updateValue("V_Guild_CYLF",true)
    	end
    end
end

--#公会boss开启
function GuildController:Guild_PushGuildBossOpen(_,data)
	printTable(22,'公会boss开启》》》》》',data)
	if data then
		local info={}
		 info[data.bossInfo.gamePlayType]=data.bossInfo
		 GuildModel.guildList.boss=info;
		 MaterialCopyModel:guildBossRed()
		Dispatcher.dispatchEvent(EventType.guild_up_guildOpenBossSuc);
	end
end

--#玩家公会跨服BOSS刷新通知
function GuildController:Guild_WorldBossInfoNotify( _,data )
	printTable(1,"Guild_WorldBossInfoNotify",data)
    GuildModel:setCylfBossDataTemp( data.worldBossInfo )
end

function GuildController:money_change(_, data)
	if data then
		--GameDef.MoneyType.GuildContri
		GuildModel:setGuildSkillRed()--公会技能红点
	end
end

function GuildController:serverTime_crossDay(...) --跨天
	MaterialCopyModel:guildBossRed()
end

return GuildController
