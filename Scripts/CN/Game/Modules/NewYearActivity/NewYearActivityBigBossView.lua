--Date :2021-01-22
--Author : generated by FairyGUI
--Desc : 

local NewYearActivityBigBossView,Super = class("NewYearActivityBigBossView", Window)

function NewYearActivityBigBossView:ctor()
	--LuaLog("NewYearActivityBigBossView ctor")
	self._packName = "NewYearActivity"
	self._compName = "NewYearActivityBigBossView"
	self._rootDepth = LayerDepth.PopWindow
	self.flag = false
	self.id = false
	self.difficult = 1
	self.timerKey = false
	self.result = false -- 战斗结算结果
	self.score = 0
	self.bossInfo = {}
	self.bossData = {}
	self.recordData = {}
	self.recordIds = {}
	self.rewardListInfo = {}
	self.recordListData = {}
end

function NewYearActivityBigBossView:_initEvent( )
	self.btn_box:addClickListener(function()
		self.rewardPanelCtr:setSelectedIndex(1)
		self:setRewardList()
	end)
	self.mask:addClickListener(function()
		self.rewardPanelCtr:setSelectedIndex(0)
	end)
	self.mask1:addClickListener(function()
		self.recordCtr:setSelectedIndex(0)
		self.arrow:setRotation(90)
	end)
	self.btn_arrow:addClickListener(function()
		self.recordCtr:setSelectedIndex(1)
		self.arrow:setRotation(-90)
	end)
	self.btn_left:addClickListener(function()
		if self.difficult - 1 < 1 then 
			return 
		end
		self.difficult = self.difficult - 1
		self.rewardListInfo = NewYearActivityModel:getNewYearBigBossConfig(NewYearActivityModel.bossTimes, self.difficult)
		self.txt_difficul:setText(self.rewardListInfo.dec)
		self:setBattleRewardList()
	end)
	self.btn_right:addClickListener(function()
		local maxNum = NewYearActivityModel:getNewYearBigBossMaxDifficult(NewYearActivityModel.bossTimes)
		if self.difficult + 1 > maxNum then 
			return 
		end
		self.difficult = self.difficult + 1
		self.rewardListInfo = NewYearActivityModel:getNewYearBigBossConfig(NewYearActivityModel.bossTimes, self.difficult)
		self.txt_difficul:setText(self.rewardListInfo.dec)
		self:setBattleRewardList()
	end)
	self.btn_tuijian:addClickListener(function()
		self.flag = not self.flag
		if self.flag then
			self.tipCtr:setSelectedIndex(1)
		else
			self.tipCtr:setSelectedIndex(0)
		end
		self:showHeroTips()
	end)
	self.tipComp.blackbg:addClickListener(function()
		self.flag = not self.flag
		if self.flag then
			self.tipCtr:setSelectedIndex(1)
		else
			self.tipCtr:setSelectedIndex(0)
		end
	end)

	self.btn_battle:addClickListener(function()
		if NewYearActivityModel.bossTimes > 0 then 
			self:battleBigBoss()
		else
			RollTips.show(Desc.NewYearActivity_str7)
		end
	end)

	self.btn_rank:addClickListener(function ()
		ViewManager.open("NewYearActivityRankView")
	end)
end

function NewYearActivityBigBossView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:NewYearActivity.NewYearActivityBigBossView
	self.arrow = viewNode:getChildAutoType('arrow')--GImage
	self.battleRewardList = viewNode:getChildAutoType('battleRewardList')--GList
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.bossNode = viewNode:getChildAutoType('bossNode')--GLoader
	self.btn_arrow = viewNode:getChildAutoType('btn_arrow')--GComponent
	self.btn_battle = viewNode:getChildAutoType('btn_battle')--GButton
	self.btn_box = viewNode:getChildAutoType('btn_box')--btn_box
		self.btn_box.icon = viewNode:getChildAutoType('btn_box/icon')--GLoader
	self.btn_left = viewNode:getChildAutoType('btn_left')--GComponent
	self.btn_rank = viewNode:getChildAutoType('btn_rank')--GComponent
	self.btn_right = viewNode:getChildAutoType('btn_right')--GComponent
	self.btn_tuijian = viewNode:getChildAutoType('btn_tuijian')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.mask = viewNode:getChildAutoType('mask')--GComponent
	self.mask1 = viewNode:getChildAutoType('mask1')--GComponent
	self.progressBar = viewNode:getChildAutoType('progressBar')--ProgressBar1
		self.progressBar.barBg = viewNode:getChildAutoType('progressBar/barBg')--GImage
	self.recordCtr = viewNode:getController('recordCtr')--Controller
	self.recordList = viewNode:getChildAutoType('recordList')--GList
	self.rewardList = viewNode:getChildAutoType('rewardList')--GList
	self.rewardPanel = viewNode:getChildAutoType('rewardPanel')--GGroup
	self.rewardPanelCtr = viewNode:getController('rewardPanelCtr')--Controller
	self.showTxt = viewNode:getChildAutoType('showTxt')--GTextField
	self.tipComp = viewNode:getChildAutoType('tipComp')--Component1
		self.tipComp.blackbg = viewNode:getChildAutoType('tipComp/blackbg')--GLabel
		self.tipComp.tipList = viewNode:getChildAutoType('tipComp/tipList')--GList
		self.tipComp.title = viewNode:getChildAutoType('tipComp/title')--GRichTextField
	self.tipCtr = viewNode:getController('tipCtr')--Controller
	self.txt_bossName = viewNode:getChildAutoType('txt_bossName')--GTextField
	self.txt_difficul = viewNode:getChildAutoType('txt_difficul')--GTextField
	self.txt_num = viewNode:getChildAutoType('txt_num')--GRichTextField
	self.txt_progress = viewNode:getChildAutoType('txt_progress')--GTextField
	--{autoFieldsEnd}:NewYearActivity.NewYearActivityBigBossView
	--Do not modify above code-------------
end

function NewYearActivityBigBossView:_initUI( )
	self:_initVM()
	self.id = self._args.id
	self.bossInfo = NewYearActivityModel:getNewYearBossConfig(self.id)
	local params = {}
	params.activityId = GameDef.ActivityType.NewYear
	params.onSuccess = function (data)
		printTable(6,"获取boss记录",data)
		self.recordData = data.data
		self:setRecordList()
	end
	printTable(6,"获取boss记录",params)
	RPCReq.Activity_NewYear_GetBigBossRecords(params,params.onSuccess)
	self:setTitle(self.bossInfo.name)
	self.rewardListInfo = NewYearActivityModel:getNewYearBigBossConfig(NewYearActivityModel.bossTimes, self.difficult)
	self.txt_difficul:setText(self.rewardListInfo.dec)
	self.showTxt:setText(string.format(Desc.NewYearActivity_str1,self.bossInfo.tip))
	self:setBossNode()
	self:setRewardList()
	self:setBattleRewardList()
	self:setProgressBar()
	self:setBoxIcon()
	-- self:setBtnState()
	self:setLeftTime()
end

function NewYearActivityBigBossView:setBossNode()
	SpineUtil.createModel(self.bossNode, {x = 0, y =0}, "stand", self.bossInfo.bossId, false)
	self.txt_bossName:setText(self.bossInfo.name)
end

function NewYearActivityBigBossView:setProgressBar()
	self.txt_progress:setText(string.format(Desc.NewYearActivity_str9,NewYearActivityModel.totalScore,NewYearActivityModel.maxScore))
	self.progressBar:setValue(NewYearActivityModel.totalScore)
	self.progressBar:setMax(NewYearActivityModel.maxScore)
end

function NewYearActivityBigBossView:setBoxIcon()
	print(6,"BoxIcon",string.format("%s%s.png","UI/NewYearActivity/",self.rewardListInfo.picture))
	self.btn_box.icon:setURL(string.format("%s%s.png","UI/NewYearActivity/",self.rewardListInfo.picture))
end

function NewYearActivityBigBossView:setRecordList()
	self.recordList:setItemRenderer(function(idx,obj)
		local data = self.recordData[idx+1]
		local detail = obj:getChildAutoType("detail")
		detail:setText(string.format(Desc.NewYearActivity_str10,data.name,data.score))
		local checkBtn = obj:getChildAutoType("checkBtn")
		checkBtn:removeClickListener(100)
		checkBtn:addClickListener(function ()
			ModelManager.BattleModel:requestBattleRecord(data.recordId)
		end)
	end)
	self.recordList:setData(self.recordData)
end

function NewYearActivityBigBossView:setRewardList()
	local rewards = self.rewardListInfo.rewards
	self.rewardList:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data = rewards[index]
		local itemCell 	= BindManager.bindItemCell(obj)
		itemCell:setData(data.code, data.amount, data.type)
	end)
	self.rewardList:setData(rewards)
end

function NewYearActivityBigBossView:setBattleRewardList()
	local exRwards = self.rewardListInfo.exRwards
	self.battleRewardList:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data = exRwards[index]
		local itemCell 	= BindManager.bindItemCell(obj)
		itemCell:setData(data.code, data.amount, data.type)
	end)
	self.battleRewardList:setData(exRwards)
end

function NewYearActivityBigBossView:showHeroTips()
	local monsterInfo = DynamicConfigData.t_monster[self.bossInfo.bossId]
	self.tipComp.title:setText(string.format(Desc.NewYearActivity_str2,monsterInfo.name,monsterInfo.dec))
	local config = self.bossInfo.hero
	self.tipComp.tipList:setItemRenderer(function(idx, obj)
		local index = idx + 1
		local playerCell = obj:getChildAutoType("heroCell")
		local detail = obj:getChildAutoType("detail")
		local heroCellObj = BindManager.bindHeroCell(playerCell)
		local info = DynamicConfigData.t_HeroRecommend[config[index]]
		local data = {}
		data.star = DynamicConfigData.t_hero[info.heroCard].heroStar
		data.category = DynamicConfigData.t_hero[info.heroCard].category
		data.code = info.heroCard
		data.level = 1
		data.amount = 1
		heroCellObj:setData(data)
		detail:setText(info.dec)
	end)
	self.tipComp.tipList:setData(config)
end

function NewYearActivityBigBossView:setLeftTime()
	self.txt_num:setText(string.format(Desc.NewYearActivity_str8,NewYearActivityModel.bossTimes))
end

function NewYearActivityBigBossView:setBtnState()
	local button = self.btn_battle:getController("button")
	if NewYearActivityModel.bossTimes > 0 then 
		button:setSelectedIndex(1)
	else
		button:setSelectedIndex(3)
	end
end

function NewYearActivityBigBossView:battleBigBoss()
	local callBack = function(type)
		if(type == "begin") then
			local params = {}
			params.activityId = GameDef.ActivityType.NewYear
			params.bossId = self.id
			params.difficult = self.difficult
			params.onSuccess = function (data)
				printTable(6,"挑战大Boss data",data)
				self.score = data.score
				NewYearActivityModel.totalScore = data.score
				NewYearActivityModel.bossTimes = data.times
				ModelManager.NewYearActivityModel:checkBigBossRed()
				-- self:setBtnState()
				self:setProgressBar()
				self:setLeftTime()
			end
			printTable(6,"挑战大Boss",params)
			RPCReq.Activity_NewYear_ChallengeBigBoss(params,params.onSuccess)
		elseif(type == "end") then 
			local battleData = FightManager.getBettleData(GameDef.BattleArrayType.NewYear)
			local params = {}
			params.win = battleData.result
			params.score = self.score
			ViewManager.open("NewYearActivityResultView",params)
		end
	end
	Dispatcher.dispatchEvent(EventType.battle_requestFunc,callBack, {fightID=self.bossInfo.fightId,configType=GameDef.BattleArrayType.NewYear})
end
return NewYearActivityBigBossView