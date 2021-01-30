--游戏常用Utils接口
local ModuleUtil = {}
local ModuleConfiger = require "Game.ConfigReaders.ModuleConfiger"
local _minOpenInfo = {}         --存储当前最小数据，后续可以用来检测模块开启条件，简化处理逻辑
local _hasOpen = {}             --已经开启的模块列表
local _needCheckDic        --尚且需要检测的模块数据
local _needHintDic = {}        --未提示的新开放模块

local _closeModuleId = {}
ModuleUtil._closeModuleId = _closeModuleId
local ModuleConfig = {}
local ActivityMap = require "Game.Modules.Activity.ActivityMap"
--检测模块是否已经开启
--@params  mid ：模块Id ， needTips : 模块未开启时是否弹出提示信息（true， false）
function ModuleUtil.moduleOpen(mid,needTips)
	
	if _hasOpen[ mid ] and not _closeModuleId[mid] then print(333 , "_hasOpen true: "  , mid) return true end
	
	local mInfo = DynamicConfigData.t_module[mid]
	if mid == ModuleId.GrowthFund.id  then
		local growData=LoginAwardModel:getGrowthData()
		if  not growData or growData.isFinish then
			return
		end
	end
	
    if mInfo then
        local tips,type= ModuleUtil.getConditionTip(mInfo)
		if not tips and _closeModuleId[mid] then
			if needTips then
				RollTips.show(Desc.moduleOpen_tips10..Desc.moduleOpen_tips0)
			end
			return
		end
		if mid == ModuleId.Recharge.id and needTips then
			--tips = "本次测试不开放充值功能"
			--RollTips.show(tips)
			return true
		end
		--if mid == ModuleId.GrowthFund.id  then
			--local growData=LoginAwardModel:getGrowthData()
			--if ( growData) and ( growData.isFinish) then 
				--return 
			--end
		--end
    --    print(2233 , "moduleOpen : " , type(tips) , mid)
        if tips ~= nil then
            if needTips==true then
                --提示语提示
				if type==-1 then
					RollTips.show(tips)
				else
					RollTips.show(tips..Desc.moduleOpen_tips0..mInfo.name)
				end
   
            end
			return nil
			else
			return true
        end
	else
		return  true
    end
	_hasOpen[ mid ] = mid 

    return true
end

--检测战斗跳过功能是否开启
function ModuleUtil.skipOpen(mid)
	if EndlessTrialModel:judgType(mid) then
		mid = 17 	-- 无尽跳过条件
	elseif HigherPvPModel:judgType(mid) then
		mid = 19
	elseif GuildModel:judgcylfType(mid) then
		mid = 20
	elseif VoidlandModel:isVoidlandMode(mid) then
		return VoidlandModel:skipOpen(mid); -- 虚空幻境
	elseif CrossPVPModel:isCrossPVPType(mid) then
		mid = 25
	elseif ExtraordinarylevelPvPModel:isCrossPVPType(mid) then
		mid = 5147
	end
	local mInfo = DynamicConfigData.t_skip[mid]
	local tips =nil
	if mInfo then
		local tips = ModuleUtil.getSkipTip(mInfo)
		if mid == 12 and tips then
			tips = tips ..Desc.moduleOpen_tips11
		end
		return true,tips

	else
		return  mid == GameDef.BattleArrayType.FriendPK,tips
	end
end



--获取功能模块开启提示语
--exParam一般不用传
function ModuleUtil.getModuleOpenTips(mid, exParam)
	
    local tips = nil
    local mInfo = DynamicConfigData.t_module[mid]
	
    local tips =  ModuleUtil.getConditionTip(mInfo, exParam)
	if not tips and _closeModuleId[mid] then
		tips = Desc.moduleOpen_tips10
	end
	return tips
end

--获取功能模块开启提示语
function ModuleUtil.getConditionTip(mInfo, exParam)
	--printTable(33,mInfo)
	local tips = nil
	local type=false
	if mInfo then
		printTable(086,mInfo.condition)
		local condition = mInfo.condition
		local checkType = mInfo.openType or 2  --1是同时满足 2是其中一个满足
		tips = ""
		for k,v in pairs(condition) do
			local desc = ""
			if v.type == -1 then -->功能未开启
				  desc = Desc.Module_NoOpen
				  type=-1
			elseif v.type == 1 then -->等级
				if PlayerModel.level < tonumber(v.val) then
					-- tips = tips..Desc.moduleOpen_tips1:format(v.val)
					desc = Desc.moduleOpen_tips1:format(v.val)
					if _minOpenInfo.lv == nil or tonumber(v.val) <= _minOpenInfo.lv then _minOpenInfo.lv = tonumber(v.val) end
				elseif checkType == 2 then
					return nil
				end
			elseif v.type==3 then  --VIP
				local vipLevel = VipModel.level;
				if (vipLevel < v.val) then
					-- tips = tips..Desc.moduleOpen_tips3:format(v.val);
					desc = Desc.moduleOpen_tips3:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==4 then  --开服天数
				local openDay = ServerTimeModel:getOpenDay() + 1
				mInfo.beginTime = nil
				if openDay < v.val then
					-- tips = tips..Desc.moduleOpen_tips4:format(v.val)
					mInfo.beginTime = TimeLib.getDayResidueSecond()+ (v.val - openDay - 1 )*24*60*60
					desc = Desc.moduleOpen_tips4:format(v.val)
					if _minOpenInfo.minOpenDay == nil or  v.val <= _minOpenInfo.minOpenDay then _minOpenInfo.minOpenDay = v.val; end
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==5 then  --爬塔通关N层后可跳过战斗
				local towerLayer = ModelManager.PataModel:getPataFloor(GameDef.GamePlayType.NormalTower)
				--print(086,"towerLayer",towerLayer)
				if towerLayer < v.val then
					-- tips = tips..Desc.moduleOpen_tips5:format(v.val)
					desc = Desc.moduleOpen_tips5:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==6 then  --推图
				local fightId = PushMapModel:getPushMapCurFightId()
				if fightId < v.val then
					-- tips = tips..Desc.moduleOpen_tips6:format(v.val)
					desc = Desc.moduleOpen_tips6:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==7 then  --第N回合后可跳过战斗
				local roundId = BattleModel.roundNum and BattleModel.roundNum or 0
				if roundId < v.val then
					-- tips = tips..Desc.moduleOpen_tips7:format(v.val)
					desc = Desc.moduleOpen_tips7:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==8 then  --爬塔通关N层后可跳过战斗	
				local roundId = PataModel:getFightFloor()
				if roundId < v.val then
					-- tips = tips..Desc.moduleOpen_tips8:format(v.val)
					desc = Desc.moduleOpen_tips8:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif  v.type ==9 then		--推图通关过的关卡可跳过  无尽试炼通关过的关卡可以跳过
				local arrayType=FightManager.frontArrayType()
				local roundId = false
				local endlessType = false
				if EndlessTrialModel:judgType(arrayType) then
					endlessType = 17
				end
				if arrayType == GameDef.BattleArrayType.Chapters then
					roundId = PushMapModel.modulefirstPass
				elseif endlessType == 17 then
					roundId = EndlessTrialModel.modulefirstPass
				end
				if roundId ==false then
					-- tips = tips..Desc.moduleOpen_tips9
					if arrayType == GameDef.BattleArrayType.Chapters then
						local cityId=PushMapModel.city 	--# 当前挑战城市
						local chapterId=PushMapModel.point --# 当前挑战章节
						local pointId=PushMapModel.level	--# 当前挑战关卡
						local isBoss= PushMapModel:guankaIsBoss(cityId, chapterId, pointId)
						if not isBoss then
							desc =""
						else
							desc = Desc.moduleOpen_tips9
						end
					else
						desc = Desc.moduleOpen_tips9
					end
				elseif checkType == 2 then
					return nil
				end
			elseif  v.type ==10 then--推图非boss关可跳过 无尽试炼不是5的倍数的关卡可以跳过
				local arrayType=FightManager.frontArrayType()
				local cityId=PushMapModel.city 	--# 当前挑战城市
				local chapterId=PushMapModel.point --# 当前挑战章节
				local pointId=PushMapModel.level	--# 当前挑战关卡
				local roundId = false
				local endlessType = false
				if EndlessTrialModel:judgType(arrayType) then
					endlessType = 17
				end
				if arrayType == GameDef.BattleArrayType.Chapters then 	-- 推图
					roundId = PushMapModel:getModulePointisPassLimit(cityId,chapterId,pointId,v.val)
				elseif endlessType == 17 then 	-- 无尽试炼
					roundId = EndlessTrialModel.fiveOrZero 
				end
				if roundId ==false then
					-- tips = tips..Desc.moduleOpen_tips2
					if arrayType == GameDef.BattleArrayType.Chapters then
						local isBoss= PushMapModel:guankaIsBoss(cityId, chapterId, pointId)
						if isBoss then
							desc = ""
						else
							local auto=PushMapModel:getTargetRewardGuankaId(cityId,chapterId,pointId)
							desc = Desc.moduleOpen_tips12:format(v.val-auto)
						end
					else
						desc = Desc.moduleOpen_tips2
					end
				elseif checkType == 2 then
					return nil
				end
			elseif  v.type ==11 then 
				local canskip=HigherPvPModel:checkSkip()--  判断是否已经连赢或者连输 还要判断是否是播放第三场战斗 回放不用管不会走这里
				if canskip then
					    return nil
				--    else  -- 提示语不展示
				-- 	   desc = "所以当已经提前赢了or输了2场时，第3场可以跳过战" 
				end
			elseif  v.type ==12 then  --这个是针对单个英雄的，判断的时候需要传入英雄星级
				--if not exParam then return nil end
				if exParam and exParam < v.val then
					desc = Desc.moduleOpen_tips16:format(v.val) --探员达到xx星解锁
				end
			elseif  v.type ==13 then 
				local chargeMoney = ModelManager.PlayerModel:getStatByType(GameDef.StatType.ChargeRmb) or 0
				if chargeMoney < v.val then
					desc = Desc.moduleOpen_tips14:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type == 14 then
				local centerLv = ModelManager.HeroPalaceModel.crystal or 0;
				local level = ModelManager.HeroPalaceModel:getLevel()
				if level < v.val and centerLv < v.val then
					desc = Desc.moduleOpen_tips15:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			end	
			local str = checkType == 2 and Desc.moduleOpen_or or Desc.moduleOpen_and;
			if tips ~= "" and desc ~= "" then
				tips = tips..str..desc;
			else
				tips = tips..desc;
			end
		end
		return (tips ~= "" and tips or nil),type
	end
end

--获取功能模块开启提示语
function ModuleUtil.getConditionTip2(mInfo)
	local tips = nil
	local type=false
	if mInfo then
		local condition = mInfo.condition
		local checkType = mInfo.openType or 2  --1是同时满足 2是其中一个满足
		tips = ""
		for k,v in pairs(condition) do
			local desc = ""
			if v.type == -1 then -->功能未开启
				  desc = Desc.Module_NoOpen
				  type=-1
			elseif v.type == 1 then -->等级
				desc = Desc.moduleOpen_tips1:format(v.val)
			elseif v.type==3 then  --VIP
				desc = Desc.moduleOpen_tips3:format(v.val)
			elseif v.type ==4 then  --开服天数
				desc = Desc.moduleOpen_tips4:format(v.val)
			elseif v.type ==5 then  --爬塔通关N层后可跳过战斗
				desc = Desc.moduleOpen_tips5:format(v.val)
			elseif v.type ==6 then  --推图
				desc = Desc.moduleOpen_tips6:format(v.val)
			elseif v.type ==7 then  --第N回合后可跳过战斗
				desc = Desc.moduleOpen_tips7:format(v.val)
			elseif v.type ==8 then  --爬塔通关N层后可跳过战斗	
				desc = Desc.moduleOpen_tips8:format(v.val)
			elseif  v.type ==9 then		--推图通关过的关卡可跳过  无尽试炼通关过的关卡可以跳过
				local arrayType=FightManager.frontArrayType()
				local roundId = false
				local endlessType = false
				if EndlessTrialModel:judgType(arrayType) then
					endlessType = 17
				end
				if arrayType == GameDef.BattleArrayType.Chapters then
					roundId = PushMapModel.modulefirstPass
				elseif endlessType == 17 then
					roundId = EndlessTrialModel.modulefirstPass
				end
				if roundId ==false then
					if arrayType == GameDef.BattleArrayType.Chapters then
						local cityId=PushMapModel.city 	--# 当前挑战城市
						local chapterId=PushMapModel.point --# 当前挑战章节
						local pointId=PushMapModel.level	--# 当前挑战关卡
						local isBoss= PushMapModel:guankaIsBoss(cityId, chapterId, pointId)
						if not isBoss then
							desc =""
						else
							desc = Desc.moduleOpen_tips9
						end
					else
						desc = Desc.moduleOpen_tips9
					end
				end
			elseif  v.type ==10 then--推图非boss关可跳过 无尽试炼不是5的倍数的关卡可以跳过
				local arrayType=FightManager.frontArrayType()
				local cityId=PushMapModel.city 	--# 当前挑战城市
				local chapterId=PushMapModel.point --# 当前挑战章节
				local pointId=PushMapModel.level	--# 当前挑战关卡
				if arrayType == GameDef.BattleArrayType.Chapters then
					local isBoss= PushMapModel:guankaIsBoss(cityId, chapterId, pointId)
					if isBoss then
						desc = ""
					else
						local auto=PushMapModel:getTargetRewardGuankaId(cityId,chapterId,pointId)
						desc = Desc.moduleOpen_tips12:format(v.val-auto)
					end
				else
					desc = Desc.moduleOpen_tips2
				end
			elseif  v.type ==13 then 
				desc = Desc.moduleOpen_tips14:format(v.val)
			elseif v.type == 14 then
				desc = Desc.moduleOpen_tips15:format(v.val)
			end	
			local str = checkType == 2 and Desc.moduleOpen_or or Desc.moduleOpen_and;
			if tips ~= "" and desc ~= "" then
				tips = tips..str..desc;
			else
				tips = tips..desc;
			end
		end
		return (tips ~= "" and tips or nil),type
	end
end



--获取战斗跳过提示语避免和模块ID冲突
function ModuleUtil.getSkipTip(mInfo)
	--printTable(33,mInfo)
	local tips = nil
	local type=false
	if mInfo then
		printTable(086,mInfo.condition)
		local condition = mInfo.condition
		local checkType = mInfo.openType or 2  --1是同时满足 2是其中一个满足
		tips = ""
		for k,v in pairs(condition) do
			local desc = ""
			if v.type == -1 then -->功能未开启
				desc = Desc.Module_NoOpen
				type=-1
			elseif v.type == 1 then -->等级
				if PlayerModel.level < tonumber(v.val) then
					-- tips = tips..Desc.moduleOpen_tips1:format(v.val)
					desc = Desc.moduleOpen_tips1:format(v.val)
					if _minOpenInfo.lv == nil or tonumber(v.val) <= _minOpenInfo.lv then _minOpenInfo.lv = tonumber(v.val) end
				elseif checkType == 2 then
					return nil
				end
			elseif v.type==3 then  --VIP
				local vipLevel = VipModel.level;
				if (vipLevel < v.val) then
					-- tips = tips..Desc.moduleOpen_tips3:format(v.val);
					desc = Desc.moduleOpen_tips3:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==4 then  --开服天数
				local openDay = ServerTimeModel:getOpenDay() + 1
				if openDay < v.val then
					-- tips = tips..Desc.moduleOpen_tips4:format(v.val)
					desc = Desc.moduleOpen_tips4:format(v.val)
					if _minOpenInfo.minOpenDay == nil or  v.val <= _minOpenInfo.minOpenDay then _minOpenInfo.minOpenDay = v.val; end
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==5 then  --爬塔通关N层后可跳过战斗
				local towerLayer = ModelManager.PataModel:getPataFloor(GameDef.GamePlayType.NormalTower)
				--print(086,"towerLayer",towerLayer)
				if towerLayer < v.val then
					-- tips = tips..Desc.moduleOpen_tips5:format(v.val)
					desc = Desc.moduleOpen_tips5:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==6 then  --推图
				local fightId = PushMapModel:getPushMapCurFightId()
				if fightId < v.val then
					-- tips = tips..Desc.moduleOpen_tips6:format(v.val)
					desc = Desc.moduleOpen_tips6:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==7 then  --第N回合后可跳过战斗
				local roundId = BattleModel.roundNum and BattleModel.roundNum or 0
				if roundId < v.val then
					-- tips = tips..Desc.moduleOpen_tips7:format(v.val)
					desc = Desc.moduleOpen_tips7:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif v.type ==8 then  --爬塔通关N层后可跳过战斗
				local roundId = PataModel:getFightFloor()
				if roundId < v.val then
					-- tips = tips..Desc.moduleOpen_tips8:format(v.val)
					desc = Desc.moduleOpen_tips8:format(v.val)
				elseif checkType == 2 then
					return nil
				end
			elseif  v.type ==9 then		--推图通关过的关卡可跳过  无尽试炼通关过的关卡可以跳过
				local arrayType=FightManager.frontArrayType()
				local roundId = false
				local endlessType = false
				if EndlessTrialModel:judgType(arrayType) then
					endlessType = 17
				end
				if arrayType == GameDef.BattleArrayType.Chapters then
					roundId = PushMapModel.modulefirstPass
				elseif endlessType == 17 then
					roundId = EndlessTrialModel.modulefirstPass
				end
				if roundId ==false then
					-- tips = tips..Desc.moduleOpen_tips9
					if arrayType == GameDef.BattleArrayType.Chapters then
						local cityId=PushMapModel.city 	--# 当前挑战城市
						local chapterId=PushMapModel.point --# 当前挑战章节
						local pointId=PushMapModel.level	--# 当前挑战关卡
						local isBoss= PushMapModel:guankaIsBoss(cityId, chapterId, pointId)
						if not isBoss then
							desc =""
						else
							desc = Desc.moduleOpen_tips9
						end
					else
						desc = Desc.moduleOpen_tips9
					end
				elseif checkType == 2 then
					return nil
				end
			elseif  v.type ==10 then--推图非boss关可跳过 无尽试炼不是5的倍数的关卡可以跳过
				local arrayType=FightManager.frontArrayType()
				local cityId=PushMapModel.city 	--# 当前挑战城市
				local chapterId=PushMapModel.point --# 当前挑战章节
				local pointId=PushMapModel.level	--# 当前挑战关卡
				local roundId = false
				local endlessType = false
				if EndlessTrialModel:judgType(arrayType) then
					endlessType = 17
				end
				if arrayType == GameDef.BattleArrayType.Chapters then 	-- 推图
					roundId = PushMapModel:getModulePointisPassLimit(cityId,chapterId,pointId,v.val)
				elseif endlessType == 17 then 	-- 无尽试炼
					roundId = EndlessTrialModel.fiveOrZero
				end
				if roundId ==false then
					-- tips = tips..Desc.moduleOpen_tips2
					if arrayType == GameDef.BattleArrayType.Chapters then
						local isBoss= PushMapModel:guankaIsBoss(cityId, chapterId, pointId)
						if isBoss then
							desc = ""
						else
							local auto=PushMapModel:getTargetRewardGuankaId(cityId,chapterId,pointId)
							desc = Desc.moduleOpen_tips12:format(v.val-auto)
						end
					else
						desc = Desc.moduleOpen_tips2
					end
				elseif checkType == 2 then
					return nil
				end
			elseif  v.type ==11 then

				local canskip=HigherPvPModel:checkSkip()--  判断是否已经连赢或者连输 还要判断是否是播放第三场战斗 回放不用管不会走这里
				if canskip then
					return nil
					--    else  -- 提示语不展示
					-- 	   desc = "所以当已经提前赢了or输了2场时，第3场可以跳过战"
				end
			elseif  v.type ==13 then --竞技场根据赛季时间判断是否能跳过
				local arenaInfo=ArenaModel:getRankInfo()
				if arenaInfo then
					--local roundId = BattleModel.roundNum and BattleModel.roundNum or 0
					local fightNum=arenaInfo.myInfo.fightNum
				    print(5656,fightNum,"赛季战斗次数")
					local week=ServerTimeModel:getOpenWeek()
					local canskipFightNum=30
					if week>1 then
						canskipFightNum=10
					end
					if fightNum>=canskipFightNum then
						return nil
					else
						desc = Desc.moduleOpen_tips13:format(canskipFightNum)
					end
				end
			elseif  v.type ==14 then --跨服竞技次数判断是否能跳过
				local battleNum = CrossArenaPVPModel:getBattleNum()
				if battleNum < v.val then
					desc = Desc.moduleOpen_tips13:format(v.val)
				elseif checkType == 2 then
					return nil
				end
				
			end
			local str = checkType == 2 and Desc.moduleOpen_or or Desc.moduleOpen_and;
			if tips ~= "" and desc ~= "" then
				tips = tips..str..desc;
			else
				tips = tips..desc;
			end
		end
		return (tips ~= "" and tips or nil),type
	end
end


--挑战的时候检查是否能直接弹结算
function ModuleUtil.checkNotFight(mid)
	local notFight=true
	local skipId=false
	local jugeType=false
	local desc =false
	if HigherPvPModel:judgType(mid)  then
		skipId = 19 	-- 天津赛
		jugeType=3      -- 判断Vip
	end
	
	
	if jugeType then
		local mInfo = DynamicConfigData.t_skip[skipId]
		local vipLevel = VipModel.level;
		local condition = mInfo.condition
		for k,v in pairs(condition) do
			if v.type==jugeType then
				if vipLevel < v.val then
					desc = Desc.moduleOpen_tips3:format(v.val)
					notFight=false
				end
			end
		end
	end
	if desc then
		desc=Desc.battle_NoFightOpen:format(desc)
	end
	return notFight,desc
	
end



function ModuleUtil.saveOpenedModuleId(hasOpenMap) 
	local ary = {}
	for id,v in pairs(hasOpenMap) do
		table.insert(ary, id)
	end
	FileCacheManager.setStringForKey("saveOpenId"..ModelManager.PlayerModel.userid, json.encode(ary), nil, true)
end

function ModuleUtil.readOpenedModuleId() 
	local saveOpenId = FileCacheManager.getStringForKey("saveOpenId"..ModelManager.PlayerModel.userid, "", nil, true)
	if saveOpenId ~= "" then
		local ary = json.decode(saveOpenId)
		local idList = {}
		for _,v in ipairs(ary) do
			idList[v] = v
		end
		
		return idList
	end
end


--当条件变化时，实时检测模块开启处理，处理红点逻辑
--处理逻辑：进入游戏后，统一验证一次，后期验证相关类型，值即可
function ModuleUtil.checkModuleOpen(type , val , isFirst)    
    if isFirst==nil and _needCheckDic==nil then return end
    if _needCheckDic == nil then   --首次需要验证所有模块的开启情况
		local saveOpenId = ModuleUtil.readOpenedModuleId()
		if saveOpenId then 
			_needCheckDic = {}
			local hasNewOpen = false
			local mInfos = ModuleConfiger.getAllConfig()
			if mInfos then 
				for k,v in pairs(mInfos) do
					if v.id == 149 then
						print( 1, "模块开启： " , v.id )
					end
				
					local isOpen = ModuleUtil.moduleOpen( v.id , false )
					-- print( 1, "模块开启： " , v.id , isOpen  )
					if v.id == 223 then
						print( 5656, "223模块开启： " , v.id ,isOpen,saveOpenId[v.id])
					end
					if saveOpenId[v.id] then
						--_hasOpen[ v.id ] = v.id
						if isOpen then
							if v.id == 223 then
								print( 5656, "223模块开启： openModuleTips")
							end
							RedManager.openModuleTips( v.id )
						else
							hasNewOpen = true
							saveOpenId[v.id] = nil
							_needCheckDic[ v.id ] = v 
						end
					else
						if isOpen then
							hasNewOpen = true
							 saveOpenId[ v.id ] = v.id
							_needCheckDic[ v.id ] =  nil
							local info = ModuleUtil.getHintInfo(v.id)
							if info then
								table.insert(_needHintDic, info)
							end
							RedManager.openModuleTips( v.id )
							--可以派发事件，让外部监听相关模块开启， 处理模块开启表现等
							Dispatcher.dispatchEvent(EventType.module_open , v.id )
						else
							_needCheckDic[ v.id ] = v 
						end          
					end
				end
				
				if hasNewOpen then
					ModuleUtil.saveOpenedModuleId(saveOpenId)
				end
			end
			_hasOpen = saveOpenId
		else
			_needCheckDic = {}   
			local mInfos = ModuleConfiger.getAllConfig()
			if mInfos then 
				for k,v in pairs(mInfos) do
					local isOpen = ModuleUtil.moduleOpen( v.id , false )
					-- print( 1, "模块开启： " , v.id , isOpen  )
					if isOpen then
						_hasOpen[ v.id ] = v.id
						RedManager.openModuleTips( v.id )
					else 
						_needCheckDic[ v.id ] = v                
					end
				end
			end
			
			ModuleUtil.saveOpenedModuleId(_hasOpen)
			
		end
    else  --非首次调用，直接判断相关条件是否可以开启
        if _minOpenInfo[type] ~= nil and _minOpenInfo[type] > val then return end      --最小开启条件已经大于当前的类型和值，则不进行验证
		local hasNewOpen = false
        for ki,vi in pairs( _needCheckDic ) do
            if vi then
                local isOpen = ModuleUtil.moduleOpen( vi.id , false )
                -- print( 1, "模块开启： " , v.id , isOpen )
				
                if isOpen then
					hasNewOpen = true
                    _hasOpen[ vi.id ] = vi.id
                    _needCheckDic[ vi.id ] =  nil
					local info = ModuleUtil.getHintInfo(vi.id)
					if info then
						table.insert(_needHintDic, info)
					end
                    --开启处理
                    RedManager.openModuleTips( vi.id )
                    --可以派发事件，让外部监听相关模块开启， 处理模块开启表现等
                    Dispatcher.dispatchEvent(EventType.module_open , vi.id )
                else
                    _needCheckDic[ vi.id ] = vi
                end
            end
        end 
		
		if hasNewOpen then
			ModuleUtil.saveOpenedModuleId(_hasOpen)
		end
		--[[if hasNewOpen then
			Scheduler.scheduleNextFrame(function()
				Dispatcher.dispatchEvent(EventType.module_open_hint)
			end)
		end--]]
    end
end
--模块是否已经开启
function ModuleUtil.hasModuleOpen(mid)
    if mid==nil or mid ==0 then return true end
	if _closeModuleId[mid] then return false end
    local mInfo = DynamicConfigData.t_module[mid]
    if mInfo == nil then return true end
    --print(0 , "模块是否已经开启： ", _hasOpen[mid] , mid )
    if _hasOpen[ mid ] then return true end
    return false 
end


--模块开发统一控制
function ModuleUtil.openModule(moduleId, needTips, winData,callfunc)
	if needTips == nil then needTips = true end
	print(086,"openModule",moduleId, needTips, winData)
	if type(moduleId) == "table" then
		moduleId = moduleId.id
	end
	
    local hasOpen = ModuleUtil.moduleOpen( moduleId , needTips )
    print(12,"check ok try open moduleId = ",moduleId,hasOpen)
    if not hasOpen then
        -- if  moduleId==ModuleId.Tower then 
        --     ViewManager.open("PataChooseView")
        -- end
        return
    end
	
	print(12,"check ok try open moduleId = ",moduleId)
	
	winData = winData or {}
	winData.moduleOpen = true

	-- 临界之旅空数据处理
	if moduleId == ModuleId.BoundaryMapView.id then 
		if not BoundaryMapModel:isInitSeverState() then
			return RollTips.show(Desc.Boundary_desc13)
		end
	end

    --公会  特殊处理
    if moduleId == ModuleId.Guild.id then
        local hasGuild=GuildModel.guildHave
		if hasGuild==true then
			local MLSTips = ModuleUtil.moduleOpen(ModuleId.GuildMLS.id,false)
			local mlsKey=tostring(FileDataType.MLS_JUMPENTERFILM..ModelManager.PlayerModel.userid) 
			local mlsEnter =FileCacheManager.getBoolForKey(mlsKey,false)
			if MLSTips==true and mlsEnter==false then
				local function endfunc1(eventName)
					
				end
				ViewManager.doOpen("GuildMallView",winData)
				ViewManager.open("PushMapFilmView",{isShowGuochangyun=false,step = "XML1",_rootDepth=LayerDepth.PopWindow,endfunc=endfunc1})
				local mlsKey1=tostring(FileDataType.MLS_JUMPENTERFILM..ModelManager.PlayerModel.userid) 
				FileCacheManager.setBoolForKey(mlsKey1, true)
			else
				ViewManager.doOpen("GuildMallView",winData)
			end
        else
            GuildModel:getRecommendGuild(1);
            ViewManager.doOpen("GuildListView",winData)
        end
		return
	end
	
	if moduleId == ModuleId.HeroGiftView.id then
		if ModelManager.HandbookModel.heroOpertion ~= 0 then
			ViewManager.open("HeroGiftView", {heroId = ModelManager.HandbookModel.heroOpertion,fashionId = ModelManager.HandbookModel.fashionCode})
			return 
		end
	end

	if moduleId == ModuleId.PveStarTemple.id then
		Dispatcher.dispatchEvent(EventType.PveStarTemple_Start)
		return
	end

	if moduleId == ModuleId.FashionLoginTips.id then --时装登录弹窗
		Dispatcher.dispatchEvent(EventType.FashionLoginTips_Show)
		return
	end

	if moduleId == ModuleId.MainUI.id then
		ViewManager.backToMainView()
		return
	end
	
	--次元裂缝
	if moduleId == ModuleId.GuildFissure.id then
		local hasGuild=GuildModel.guildHave
		if not hasGuild then
			RollTips.show(Desc.GuildMLSMain_noGuild)
			return
		end
	end

	-- 魔灵收容所
	if moduleId == ModuleId.GuildMLS.id then
		local hasGuild=GuildModel.guildHave
		if not hasGuild then
			RollTips.show(Desc.GuildMLSMain_noGuild)
			return
		end
	end

	-- 限时礼包活动
	local hasGift,openId = ModelManager.TimeLimitGiftModel:hasGiftByModuleId(moduleId)
	if openId then
		moduleId = openId
	end
	print(8848,"check ok try open openId hasGift  = ",openId,hasGift)
	if not hasGift and openId then
		RollTips.show(Desc.TimeLimitGift_txt3)
		return
	end
	
	-- 装备目标活动
	local equipTargetOpenId =  EquipTargetModel:getEquipTargetOpenId(moduleId)
	if equipTargetOpenId then
		moduleId = equipTargetOpenId
	end

	--如果是活动
	if ActivityMap.actWinMap[moduleId] then
		local actData = ActivityModel:getActityByModuleId( moduleId )
		
		if not actData then
			RollTips.show(DynamicConfigData.t_module[moduleId].name..Desc.activity_txt1)
			return
		end
		
		if actData.showContent and actData.showContent.activitymark ==2 and actData.showContent.mainActiveId>=2 then
			local flag = ActivityModel:getDataByShowData( actData.showContent.mainActiveId,actData.id)
			if not flag then
				RollTips.show(DynamicConfigData.t_module[moduleId].name..Desc.activity_txt1)
				return
			end
		end
		
		if actData.showContent.activitymark == 2 then
            local mainActiveId = actData.showContent.mainActiveId
			local winData = ActivityModel:marketUIWinData(mainActiveId) 
			local viewName = ActivityMap.ActivityFrame[mainActiveId]
			if  ViewManager.isShow(viewName) then 
				ViewManager.close(viewName)
			end
			ViewManager.open(ActivityMap.ActivityFrame[mainActiveId],{viewData =winData,page = ActivityMap.actWinMap[actData.showContent.moduleOpen]})
			return;
        else
			local hasOpen = ModuleUtil.moduleOpen( actData.showContent.moduleOpen , true )
			if hasOpen then
				--透传参数  actData
				local viewName = ActivityMap.actWinMap[actData.showContent.moduleOpen]
				if  ViewManager.isShow(viewName) then 
					ViewManager.close(viewName)
				end
                ViewManager.open(viewName,{actData=actData})
				return;
			end
        end
	end

	local info = ModuleConfig[moduleId]
	if not info then
		for k,v in pairs(ModuleId) do
			if v.id == moduleId then
				info = v
				ModuleConfig[moduleId] = v
				break
			end
		end
	end
	
	if info then
		local args = info.args or {}
		args.moduleId = info.id
		if winData then
			local temp = TableUtil.DeepCopy(args)
			TableUtil.deepcopyForkeyValue(winData,temp)
			args = temp
			-- printTable(1,"deepcopyForkeyValue",info.args,temp,args)
		end
		ViewManager.doOpen(info.view,args,callfunc)
		return
	end
end

--获取提示信息
local _hintMap
function ModuleUtil.getHintInfo(moduleId)
	if not _hintMap then
		_hintMap = {}
		for _,v in ipairs(DynamicConfigData.t_modulePre) do
			_hintMap[v.moduleId] = v
		end
	end
	return _hintMap[moduleId]
end


--获取moduleIdView
local _moduleMap
function ModuleUtil.getModuleIdView(moduleId)
	if not _moduleMap then
		_moduleMap = {}
		for _,v in pairs(ModuleId) do
			_moduleMap[v.id] = v
		end
	end
	return _moduleMap[moduleId]
end

--获取新开放的模块id
function ModuleUtil.getNewOpenModuleInfo()
	if #_needHintDic > 0 then
		local info = _needHintDic[1]
		table.remove(_needHintDic, 1)
		return info
	end
end

--获取新开放的模块id
function ModuleUtil.getNextModuleOpenInfo(curLv)
	local nextOpenLv = 999999
	local nextOpenInfo
	for _,v in ipairs(DynamicConfigData.t_modulePre) do
		if not _hasOpen[v.moduleId] then
			local moduleOpenInfo = DynamicConfigData.t_module[v.moduleId]
			if moduleOpenInfo then
				local condition = moduleOpenInfo.condition
				for _,con in ipairs(condition) do
					if con.type == 1 and con.val > curLv and con.val <= nextOpenLv then
						nextOpenInfo = v
						nextOpenLv = con.val
					end
				end
			end
		end
	end
	return nextOpenInfo,nextOpenLv
end

function ModuleUtil.setCloseModuleId(data)
	if type(data) ~= "table" then return end
	_closeModuleId = {}
	for k,v in pairs(data) do
		_closeModuleId[v]=v
	end
	--_closeModuleId = data
end

function ModuleUtil.clear()
	_hasOpen = {}
	_minOpenInfo = {}
	_needCheckDic = nil
end

return ModuleUtil