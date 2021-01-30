-- added by wyz
-- 无尽试炼主界面
local RankView = require "Game.Modules.Rank.RankView"
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
local EndlessTrialMainView, Super = class("EndlessTrialMainView",RankView)

function EndlessTrialMainView:ctor()
	self._packName = "EndlessTrial"
	self._compName = "EndlessTrialMainView"
	self._rootDepth = LayerDepth.Window
	self._openType 	= self._args.trialType+20

	-- self.btn_synEndless 	= false 	-- 综合试炼按钮
	-- self.btn_otherEndless 	= false 	-- 其它试炼按钮
	self.btn_trial 			= false		
	self.entranceCtrl 		= false 	-- 控制入口显示
	self.startCtrl 			= false 	-- 控制开始按钮显示


	self.btn_rank 		 	= false 	-- 排名按钮
	
	self.txt_titleName 	  	= false 	-- 试炼标题
	-- self.txt_titlePassNum 	= false 	-- 试炼第几关

	self.txt_dailyReward  	= false 	-- 日常奖励文本
	self.list_dailyReward 	= false 	-- 日常奖励列表
	
	self.txt_firstReward  	= false 	-- 首通奖励文本
	self.list_firstReward 	= false 	-- 首通奖励列表
	self.btn_firstInfo 	  	= false 	-- 首通奖励详情按钮

	self.txt_friendHelp   	= false 	-- 好友助阵文本
	self.btn_start 		  	= false 	-- 开始按钮
	self.btn_restart 	  	= false 	-- 重新开始按钮
	self.txt_startTips 	  	= false 	-- 提示文本 提示玩家从多少关开始
	self.btn_friendHelp   	= false 	-- 好友助阵按钮




	self.groupRight 		= false 	-- 右边组
	self.groupLeft 			= false 	-- 左边组
	self.mainItem 			= false


	self.rewardData 		= {} 		-- 奖励列表
	self.trialType 			= 1 		-- 试炼类型

	-- self.viewFlag 			= 1 		-- 标记停留在哪个界面

	-- self.txt_firstLevel 	= false
	-- self.txt_dailyLevel 	= false

end

function EndlessTrialMainView:_initUI()
	self.btn_trial  		= self.view:getChildAutoType("btn_trial")
	-- self.entranceCtrl 		= self.view:getController("entranceCtrl")
	self.startCtrl 			= self.view:getController("startCtrl")

	self.btn_rank			= self.view:getChildAutoType("btn_rank")

	self.txt_titleName 		= self.view:getChildAutoType("txt_titleName")
	self.txt_dailyReward 	= self.view:getChildAutoType("txt_dailyReward")
	self.list_dailyReward 	= self.view:getChildAutoType("list_dailyReward")

	self.txt_firstReward 	= self.view:getChildAutoType("txt_firstReward")
	self.list_firstReward 	= self.view:getChildAutoType("list_firstReward")
	self.btn_firstInfo 		= self.view:getChildAutoType("btn_firstInfo")

	self.txt_friendHelp 	= self.view:getChildAutoType("txt_friendHelp")
	self.btn_friendHelp 	= self.view:getChildAutoType("btn_friendHelp")
	self.btn_start 			= self.view:getChildAutoType("btn_start")
	self.btn_restart 		= self.view:getChildAutoType("btn_restart")
	self.txt_startTips 		= self.view:getChildAutoType("txt_startTips")

	-- self.btn_synEndless 	= self.view:getChildAutoType("btn_synEndless")
	-- self.btn_otherEndless 	= self.view:getChildAutoType("btn_otherEndless")
	-- self.txt_titlePassNum 	= self.view:getChildAutoType("txt_titlePassNum")
	-- self.groupRight 		= self.view:getChildAutoType("groupRight")
	-- self.groupLeft 			= self.view:getChildAutoType("groupLeft")

	-- self.txt_firstLevel 	= self.view:getChildAutoType("txt_firstLevel")
	-- self.txt_dailyLevel 	= self.view:getChildAutoType("txt_dailyLevel")
	self:setBg("endlessTrialBg2.jpg")
	Super._initUI(self)

end

function EndlessTrialMainView:_initEvent()
	self:updateView()
end

-- 主界面
function EndlessTrialMainView:updateView()
	local trialType = self._args.trialType
	self.trialType	= trialType
	ModelManager.EndlessTrialModel:getAllCards()
	local trialAllData 		= ModelManager.EndlessTrialModel.trialAllData
	local trialSynthData 	= ModelManager.EndlessTrialModel:getTrialDataByType(1) -- 获取综合试炼数据 
	local rewardData 		= ModelManager.EndlessTrialModel:getRewardDataByType(1)
	local trialTypeCtrl 	= self.btn_trial:getController("typeCtrl") 	-- 控制icon显示
	local viewCtrl 			= self.btn_trial:getController("viewCtrl")  
	local raceIcon 			= self.btn_trial:getChildAutoType("icon") 
	raceIcon:setURL("Icon/endlessTrial/race".. trialType ..".png")
	viewCtrl:setSelectedIndex(1)
	-- trialTypeCtrl:setSelectedIndex(trialType)
	self:upDateByType(trialType)
	self:setOtherTrialTitle(trialType)


	-- 判断综合试炼的通关数是否达到200 达到显示综合试炼和其它试炼入口 否则只显示综合试炼
	-- -- 0 综合试炼 ，1 其它试炼
	-- self.entranceCtrl:setSelectedIndex(trialSynthData.maxLevel >= 200 and 1 or 0)
	-- local ctrIndex = self.entranceCtrl:getSelectedIndex()
	-- -- self.entranceCtrl:setSelectedIndex(1)

	-- -- 综合试炼按钮
	-- local currentMaxLv = trialSynthData.maxLevel >= 200 and #rewardData or 200  -- 当前最大关卡
	-- synTypeCtrl:setSelectedIndex(1)
	-- local txt_synGateNum = self.btn_synEndless:getChildAutoType("txt_gateNum") 	-- 通关数文本显示
	-- txt_synGateNum:setText(string.format("%s[color=#ffc35b]/%s[/color]",trialSynthData.maxLevel,currentMaxLv))
	-- self.btn_synEndless:setTitle(Desc.EndlessTrial_type_1)
	-- self.btn_synEndless:removeClickListener(123)
	-- self.btn_synEndless:addClickListener(function()
	-- 	self.viewFlag = 2
	-- 	self.btn_synEndless:setTouchable(false)
	-- 	self.btn_otherEndless:setVisible(false)
	-- 	self.groupRight:setVisible(true)
	-- 	self.groupLeft:setVisible(true)
	-- 	self.trialType = trialSynthData.type
	-- 	EndlessTrialModel:setTrialType(trialSynthData.type)
	-- 	self:upDateByType(trialSynthData.type)

	-- 	-- 入场动画
	-- 	self.mainItem:getTransition("moveTo_" .. ctrIndex):play(function() 
	-- 	end);
	-- end,123)

	-- --其它试炼按钮
	-- local otherTypeCtrl 		= self.btn_otherEndless:getController("typeCtrl") 	-- 控制icon显示
	-- local txt_otherGateNum 		= self.btn_otherEndless:getChildAutoType("txt_gateNum")
	-- local raceType 				= trialAllData.raceType
	-- local trialOtherData 		= EndlessTrialModel:getTrialDataByType(raceType)
	-- local rewardData 			= EndlessTrialModel:getRewardDataByType(raceType)
	-- otherTypeCtrl:setSelectedIndex(raceType)
	-- self:setOtherTrialTitle(raceType)
	-- txt_otherGateNum:setText(string.format("%s[color=#ffc35b]/%s[/color]",trialOtherData.maxLevel,#rewardData))
	-- self.btn_otherEndless:removeClickListener(123)
	-- self.btn_otherEndless:addClickListener(function()
	-- 	self.viewFlag = 2
	-- 	self.btn_otherEndless:setTouchable(false)
	-- 	self.btn_synEndless:setVisible(false)
	-- 	self.groupRight:setVisible(true)
	-- 	self.groupLeft:setVisible(true)
	-- 	self.trialType = trialOtherData.type
	-- 	EndlessTrialModel:setTrialType(trialOtherData.type)
	-- 	self:upDateByType(trialOtherData.type)
	-- 	self.mainItem:getTransition("moveTo_" .. ctrIndex):play(function() 
	-- 	end);
	-- end,123)

	-- -- 重写返回按钮
	-- self._closeBtn:removeClickListener()
	-- self._closeBtn:addClickListener(function()
	-- 	print(8848,"ctrIndex>>>>>>>>>",ctrIndex)
	-- 	-- 离场动画
	-- 	if self.viewFlag == 2 then
	-- 		self.mainItem:getTransition("moveBack_" .. ctrIndex):play(function() 
	-- 			self.groupRight:setVisible(false)
	-- 			self.groupLeft:setVisible(false)
	-- 			self.btn_otherEndless:setVisible(ctrIndex==1 and true or false)
	-- 			self.btn_synEndless:setVisible(true)
	-- 			self.btn_synEndless:setTouchable(true)
	-- 			self.btn_otherEndless:setTouchable(true)
	-- 		end);
	-- 		self.viewFlag = 1
	-- 	else
	-- 		ViewManager.close("EndlessTrialMainView")
	-- 	end
	-- end)


end

-- 设置试炼按钮标题
function EndlessTrialMainView:setOtherTrialTitle(trialType)
	self.btn_trial:setText(Desc["EndlessTrial_type_" .. trialType])
end


-- 界面内容更新
function EndlessTrialMainView:upDateByType(trialType)
	-- local trialType = trialType --or self.trialType
	-- 试炼标题
	local rankType = false
	rankType = trialType + 20
	self.txt_titleName:setText(Desc["EndlessTrial_type_"..trialType] .. Desc.EndlessTrial_rank)

	-- 排行榜按钮
	local txt_rankTitle = self.view:getChildAutoType("txt_rankTitle")
	local txt_rank 		= self.view:getChildAutoType("txt_rank")

	self.btn_rank:removeClickListener(22)
	self.btn_rank:addClickListener(function()
		ViewManager.open("EndlessRankView", {type = trialType+20})
	end,22)
	local params = {}
	params.rankType = trialType + 20
	params.onSuccess = function (res )
		local rankData = res.rankData
		local rankAllData = {}
		--找出自己的排名数据，找不到的话就是没上榜
		local myRank = 0;
		-- printTable(8848,"rankData",rankData)

		for _,v in ipairs(res.rankData) do
			table.insert(rankAllData, v)
		end
		local myInfo = res.myRankData
		local myRank = myInfo and myInfo.rank or 0
		for k,v in pairs(rankAllData) do
			if(v.id == ModelManager.PlayerModel.userid) then
				myRank = v.rank or k
				myInfo = v
				break
			end
		end

		if tolua.isnull(self.view) then return end
		local rankCtrl = self.view:getController("rankCtrl")
		if myRank > 0 then
			local rankRward = RankConfiger.getTopChallengeReward(trialType, myRank)
			rankCtrl:setSelectedIndex(1)
			txt_rank:setText(myRank)
			local list_rankReward = self.view:getChildAutoType("list_rankReward")
			list_rankReward:setItemRenderer(function(idx,obj)
				local data = rankRward[idx+1]
				local itemCell = BindManager.bindItemCell(obj)
				itemCell:setData(data.code,data.amount,data.type)
			end)
			list_rankReward:setData(rankRward)
		else
			rankCtrl:setSelectedIndex(0)
		end

	end
	RPCReq.Rank_GetRankData(params, params.onSuccess)


	local trialData 	= ModelManager.EndlessTrialModel:getTrialDataByType(trialType)
	local rewardData 	= ModelManager.EndlessTrialModel:getRewardDataByType(trialType)
	if trialType == GameDef.TopChallengeType.Common then
		local txt_synGateNum = self.btn_trial:getChildAutoType("txt_gateNum") 	-- 通关数文本显示
		local currentMaxLv 	= trialData.maxLevel >= 200 and #rewardData or 200  -- 当前最大关卡
		txt_synGateNum:setText(string.format("%s[color=#ffffff]/%s[/color]",trialData.maxLevel,currentMaxLv))
	else
		local txt_otherGateNum = self.btn_trial:getChildAutoType("txt_gateNum")
		txt_otherGateNum:setText(string.format("%s[color=#ffffff]/%s[/color]",trialData.maxLevel,#rewardData))
	end

	-- 第几关
	-- self.txt_titlePassNum:setText(string.format(Desc.EndlessTrial_passNum,trialData.dailyTopLevel+1))


	-- 日常奖励
	local rewardData 	= ModelManager.EndlessTrialModel:getRewardDataByType(trialType)
	local dailyReward 	= rewardData[trialData.beginLevel+1].dailyReward
	self.list_dailyReward:setItemRenderer(function(idx,obj)
		local data 		= dailyReward[idx+1]
		local itemCell 	= BindManager.bindItemCell(obj)
		itemCell:setData(data.code,data.amount,data.type)
	end)
	self.list_dailyReward:setData(dailyReward)
	-- local str = EndlessTrialModel:transText(trialData.dailyTopLevel+1)
	-- self.txt_dailyLevel:setText("︵".. str .."关\n︶")


	-- 首通奖励 列表
	local firstIndex 	= ModelManager.EndlessTrialModel:getCurFirstIndex(trialData.maxLevel == 0 and 1 or trialData.maxLevel )
	local firstReward 	= ModelManager.EndlessTrialModel:getFirstRewardDataByType(trialType)[firstIndex].firstReward
	self.list_firstReward:setItemRenderer(function(idx,obj)
		local data 		= firstReward[idx+1]
		local itemCell 	= BindManager.bindItemCell(obj)
		itemCell:setData(data.code,data.amount,data.type)
		itemCell.view:setTouchable(false)
	end)
	self.list_firstReward:setData(firstReward)
	self.list_firstReward:removeClickListener(111)
	self.list_firstReward:addClickListener(function()
		ViewManager.open("EndlessRewardTipsView")
	end,111)
	local txt_rewardDec = self.view:getChildAutoType("txt_rewardDec")
	local firstRewardData,takeNum = ModelManager.EndlessTrialModel:getTrialFirstRewardDataByType(trialType,true)
	txt_rewardDec:setText(string.format(Desc.EndlessTrial_rewardDec,firstRewardData[1].level))

	-- str = EndlessTrialModel:transText(EndlessTrialModel:getCurFirstIndex(trialData.maxLevel == 0 and 1 or trialData.maxLevel ))
	-- self.txt_firstLevel:setText("︵".. str.."关\n︶")

	-- 首通奖励 按钮
	self.btn_firstInfo:removeClickListener(22)
	self.btn_firstInfo:addClickListener(function()
		ViewManager.open("EndlessFirstRewardView",{type = trialType})
	end,22)
	if trialType == GameDef.TopChallengeType.Common then
		RedManager.register("V_ENDLESSTRIAL_SYN", self.btn_firstInfo:getChildAutoType("img_red"))
	else
		RedManager.register("V_ENDLESSTRIAL_OTH", self.btn_firstInfo:getChildAutoType("img_red"))
	end

	-- 好友助阵
	local haveHelpCtrl = self.btn_friendHelp:getController("haveHelpCtrl")
	local heroCell 	   = BindManager.bindHeroCell(self.btn_friendHelp:getChildAutoType("heroCell"))
	local heroList 	   = ModelManager.EndlessTrialModel:getFriendHelpHero()
	haveHelpCtrl:setSelectedIndex(0)
	if #heroList > 0 then
		haveHelpCtrl:setSelectedIndex(1)
		heroList = ModelManager.EndlessTrialModel:initFriendHelpHero(heroList)
		heroCell:setData(heroList[1].hero)
	end

	self.btn_friendHelp:removeClickListener(888)
	self.btn_friendHelp:addClickListener(function()
		RPCReq.TopChallenge_GetFriendHelperList({},function(params)
			local data = {}
			if params.helperList and #params.helperList > 0 then
				data = params
			else
				data.helperList = {}
			end
			ViewManager.open("EndlessFriendSupportView",data)
		end)
	end,888)


	local trialAllData 		= ModelManager.EndlessTrialModel.trialAllData
	local challengeType 	= trialAllData.challengeType
	-- 开始按钮
	self.txt_startTips:setText(string.format(Desc.EndlessTrial_startNum,trialData.beginLevel+1))
	self.btn_start:removeClickListener(888)
	self.btn_start:addClickListener(function(idx,obj)
		RPCReq.TopChallenge_ResetChallenge({},function()
			if challengeType == 0 or challengeType == trialType then
				self:upDateFight(trialType,trialData)
			else
				RollTips.show(Desc.EndlessTrial_tips2)
			end
		end)
	end,888)

	self.startCtrl:setSelectedIndex(0)
	-- 重新开始
	-- self.startCtrl:setSelectedIndex(trialAllData.challengeType ==  trialType and 1 or 0)
	-- self.btn_restart:removeClickListener(888)
	-- self.btn_restart:addClickListener(function(idx,obj)
			-- #请求重置当前关卡挑战数据
			-- RPCReq.TopChallenge_ResetChallenge({},function()
			-- 	if tolua.isnull(self.view) then return end
			-- 	local info = {}
			-- 	info.text = Desc.EndlessTrial_restartTips
			-- 	info.type = "yes_no"
			-- 	info.onYes = function()
			-- 		if challengeType == 0 or challengeType == trialType then
			-- 			self:upDateFight(trialType,trialData)
			-- 		else
			-- 			RollTips.show("今日已挑战其它类型试炼！")
			-- 		end
			-- 	end
			-- 	info.onClose = function()
			-- 	end
			-- 	Alert.show(info)
			-- end)
	-- end,888)
end

-- 战斗部分
function EndlessTrialMainView:upDateFight(trialType, trialData)
		local categoryData = ModelManager.EndlessTrialModel:getCategoryByType(trialType)
		local gameType = false
		if trialType == 1 then
			gameType = GameDef.BattleArrayType.TopChallengeCommon
		elseif trialType == 2 then
			gameType = GameDef.BattleArrayType.TopChallengeHuman
		elseif trialType == 3 then
			gameType = GameDef.BattleArrayType.TopChallengeOrc
		elseif trialType == 4 then
			gameType = GameDef.BattleArrayType.TopChallengeMachine
		elseif trialType == 5 then
			gameType = GameDef.BattleArrayType.TopChallengeFairy
		end

		local maxCheckPoint = #ModelManager.EndlessTrialModel:getRewardDataByType(trialType)
		ModelManager.EndlessTrialModel:setCurrentLevel(true)
		local beginLevel = ModelManager.EndlessTrialModel:getCurrentLevel()
		local fightID = ModelManager.EndlessTrialModel:getMonsterIdByLevel(trialType, beginLevel)
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
			local figthData = {}
			if eventName == "begin" then
				ModelManager.EndlessTrialModel.isFighting = true
				RPCReq.TopChallenge_GetBuffList({challengeType = trialType},function(params)
					local beginLevel = ModelManager.EndlessTrialModel:getCurrentLevel()
					local reqInfo = {
						type 	= trialType,
						level 	= beginLevel,
						buffSelect = params.buffSelect,
						heroInfoList = params.heroInfoList,
					}
					if params.buffSelect and #params.buffSelect > 0  then
						ViewManager.open("EndlessSelectBuffView",reqInfo)
					else
						RPCReq.TopChallenge_Challenge(reqInfo,function(params)
							ModelManager.EndlessTrialModel:setDailyDataReward(beginLevel,params.result)
							Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshAddTopChallengeView)
							ModelManager.EndlessTrialModel:setCurrentLevel()
						end)
					end
				end)

			end

			if eventName == "next" then
				LuaLogE("")
				ModelManager.EndlessTrialModel.isFighting = true
				RPCReq.TopChallenge_GetBuffList({challengeType = trialType},function(params)
					local beginLevel = ModelManager.EndlessTrialModel:getCurrentLevel()
					local reqInfo = {
						type 	= trialType,
						level 	= beginLevel,
						buffSelect = params.buffSelect,
						heroInfoList = params.heroInfoList,
					}
					if beginLevel > maxCheckPoint then
						Dispatcher.dispatchEvent(EventType.battle_end)
					end
					if params.buffSelect and #params.buffSelect > 0 then
						ViewManager.open("EndlessSelectBuffView",reqInfo)
					else
						RPCReq.TopChallenge_Challenge(reqInfo,function(params)
							ModelManager.EndlessTrialModel:setDailyDataReward(beginLevel,params.result)
							ModelManager.EndlessTrialModel.result = params.result or false
							if params.result then
								local dayStr = DateUtil.getOppostieDays()
								FileCacheManager.setIntForKey("EndlessTrialFirstFight" .. dayStr, ModelManager.EndlessTrialModel:getMaxLevel(trialType))
							end
							Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshAddTopChallengeView)
							ModelManager.EndlessTrialModel:setCurrentLevel()
							if params.isDailyLimit then
								Dispatcher.dispatchEvent(EventType.battle_end)
							end
						end)
					end
				end)
			end

			-- 失败了才会进入
			if eventName == "end" then
				ModelManager.EndlessTrialModel.isFighting = false
				ModelManager.EndlessTrialModel.isFistSkip = true
				ModelManager.EndlessTrialModel.dailyRewardData = {}
				RPCReq.TopChallenge_ExitChallenge({})
				self:EndlessTrial_refreshMainViewPanel()
			end
		end,{fightID=fightID,configType=gameType,categoryData = categoryData})
end


-- 刷新面板
function EndlessTrialMainView:EndlessTrial_refreshMainViewPanel()
	self:updateView()
	print(8848,"self.trialType>>>>>>>>>>>>>>>>>>>",self.trialType)
	self:upDateByType(self.trialType)
end

--这个方法给特殊排行榜继承后加需要特殊处理的内容
function EndlessTrialMainView:updateItemSpec(obj, rank, info, isMine)
	local rewards,lastRank,nextRank = RankConfiger.getTopChallengeReward(self._openType - 20, rank)
	
	local txt_rank = obj:getChild("txt_rank")
	if txt_rank then 
		if (rank <= 20 and self._myRank <= 20 and self._myRank ~= 0) or 
			(rank == nextRank and self._myRank > nextRank and self._myRank ~= 0) or
			(rank == 100 and self._myRank == 0)or isMine then
			txt_rank:setText(rank)
		elseif rank == 101 then
			txt_rank:setText(Desc.EndlessTrial_norank) 
		else
			txt_rank:setText(lastRank.."-"..nextRank) 
		end
	end
end

function EndlessTrialMainView:updateRankData()
	local config = self._groupData[self:getCruRankType()]
	self:setWinTtile(config.name)
	self:updateRankHead(self._openType)
	local params = {}
	params.rankType = self._openType
	params.onSuccess = function (res )
		-- printTable(2233, res);
		printTable(1,"排行榜数据",self._openType,self._openType,res)
		self._rankData = {}
		for _,v in ipairs(res.rankData) do
			table.insert(self._rankData, v)
		end
		if tolua.isnull(self.view) then return end
		if (self.txt_noData) then
			self.txt_noData:setVisible(#self._rankData == 0)
		end
		if self.myRankItem then
			self.myRankItem:setVisible(#self._rankData ~= 0)
		end
		
		--找出自己的排名数据，找不到的话就是没上榜
		local myInfo = res.myRankData
		self._myRank = myInfo and myInfo.rank or 0
		local myRank = 0;
		for k,v in pairs(self._rankData) do
			if(v.id == ModelManager.PlayerModel.userid) then
				myRank = v.rank or k
				self._myRank = myRank
				myInfo = v
				break
			end
		end
		if self.myRankItem then
			self:updateMyRankItem(self._myRank, myInfo, true)
		end
		self:updateRankInfo(self._openType)
		if #self._rankData >= 3 then
			self.list_rank:setNumItems(3)
		else
			self.list_rank:setNumItems(#self._rankData)
		end
		self.list_rank:scrollToView(0)
	end
	RPCReq.Rank_GetRankData(params, params.onSuccess)
	
end





return EndlessTrialMainView