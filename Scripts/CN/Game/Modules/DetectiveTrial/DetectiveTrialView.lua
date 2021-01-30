--Date :2020-11-24
--Author : wyz
--Desc : 探员试炼活动

local DetectiveTrialView = class("DetectiveTrialView", Window)

function DetectiveTrialView:ctor()
	--LuaLog("DetectiveTrialView ctor")
	self._packName = "DetectiveTrial"
	self._compName = "DetectiveTrialView"
	-- self._rootDepth = LayerDepth.Window
	self.pageIndex 	= 1		-- 顶部页签索引
	self.level 		= 1 	-- 怪物难度默认为1
	self.offset 	= 0 	-- 偏移量 用来锁定立绘
	self.lihuiDisplay = {}
	self.isEnd 		= false
	self.timer 		= false
	self.timer2		= false
	self.rankData   = {}
end

function DetectiveTrialView:_initEvent( )
	DetectiveTrialModel:reqGetBossBeatInfo()
	-- self:DetectiveTrialView_refreshPanal()
end

function DetectiveTrialView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:DetectiveTrial.DetectiveTrialView
	self.bgLoader = viewNode:getChildAutoType('bgLoader')--GLoader
	self.btn_fight = viewNode:getChildAutoType('btn_fight')--GButton
	self.btn_help = viewNode:getChildAutoType('btn_help')--GButton
	self.btn_jump = viewNode:getChildAutoType('btn_jump')--GButton
	self.btn_left = viewNode:getChildAutoType('btn_left')--btn_arrow
		self.btn_left.img_red = viewNode:getChildAutoType('btn_left/img_red')--GImage
		self.btn_left.point = viewNode:getChildAutoType('btn_left/point')--GLoader
	self.btn_right = viewNode:getChildAutoType('btn_right')--btn_arrow
		self.btn_right.img_red = viewNode:getChildAutoType('btn_right/img_red')--GImage
		self.btn_right.point = viewNode:getChildAutoType('btn_right/point')--GLoader
	self.checkEnd = viewNode:getController('checkEnd')--Controller
	self.checkkill = viewNode:getController('checkkill')--Controller
	self.checkpoint = viewNode:getController('checkpoint')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.lihuiDisplay = viewNode:getChildAutoType('lihuiDisplay')--GButton
	self.list_allReward = viewNode:getChildAutoType('list_allReward')--GList
	self.list_day = viewNode:getChildAutoType('list_day')--GList
	self.list_ownerReward = viewNode:getChildAutoType('list_ownerReward')--GList
	self.list_rank = viewNode:getChildAutoType('list_rank')--GList
	self.rank = viewNode:getChildAutoType('rank')--GGroup
	self.txt_accRewardTips = viewNode:getChildAutoType('txt_accRewardTips')--GRichTextField
	self.txt_allFirstTitle = viewNode:getChildAutoType('txt_allFirstTitle')--GTextField
	self.txt_challengeTips = viewNode:getChildAutoType('txt_challengeTips')--GTextField
	self.txt_countTimer = viewNode:getChildAutoType('txt_countTimer')--GTextField
	self.txt_countTimer2 = viewNode:getChildAutoType('txt_countTimer2')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	self.txt_countTitle2 = viewNode:getChildAutoType('txt_countTitle2')--GTextField
	self.txt_difficulty = viewNode:getChildAutoType('txt_difficulty')--GTextField
	self.txt_fightPlayerName = viewNode:getChildAutoType('txt_fightPlayerName')--GRichTextField
	self.txt_personalTitle = viewNode:getChildAutoType('txt_personalTitle')--GTextField
	self.txt_power = viewNode:getChildAutoType('txt_power')--GTextField
	self.txt_quickTitle = viewNode:getChildAutoType('txt_quickTitle')--GTextField
	--{autoFieldsEnd}:DetectiveTrial.DetectiveTrialView
	--Do not modify above code-------------
end

function DetectiveTrialView:_initUI( )
	self:_initVM()
	self.bgLoader:setURL("Bg/detectiveTrialBg.png")
	self.btn_help:removeClickListener()
	self.btn_help:addClickListener(function(...)
		local info={}
		info['title']=Desc["help_StrTitle"..ModuleId.DetectiveTrial.id]
		info['desc']=Desc["help_StrDesc"..ModuleId.DetectiveTrial.id]
		ViewManager.open("GetPublicHelpView",info) 
    end)

	self.txt_challengeTips:setText(Desc.DetectiveTrial_challengeEnd)
	self.txt_quickTitle:setText(Desc.DetectiveTrial_quickTitle)
	local beingDay = DetectiveTrialModel:getActivityBeingDay() 	-- 活动进行天数
	print(8848,">>>>beingDay>>",beingDay)
	self.pageIndex = beingDay > 7 and 7 or beingDay
	self.level = DetectiveTrialModel:getHeroTrialLevel(self.pageIndex)
	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("DetectiveTrialView_isShow"..dayStr, true)
	DetectiveTrialModel:updateRed()
end

function DetectiveTrialView:DetectiveTrialView_refreshPanal()
	self:refreshPanal()
end

function DetectiveTrialView:refreshPanal()
	self:setPageList()
	self:setLihui()
	self:setCheckBtn()
	self:setController()
	self:setOwnerReward()
	self:setWholeReward()
	self:updateCountTimer()
	self:setCheckBtnRedState()
	self:beginChallenge()
	self:setRankInfo()
	self:jumpToHeroInfo()
	self:updateCountTimer2()
end

-- 设置排行信息
function DetectiveTrialView:setRankInfo()
	local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	heroTrialInfo 		= heroTrialInfo[self.level]
	self.list_rank:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data  = self.rankData[index]
		local checkHaveCtrl = obj:getController("checkHaveCtrl") -- 0有人 1每人
		checkHaveCtrl:setSelectedIndex(data and 1 or 0)
		local rankCtrl = obj:getController("rankCtrl")
		rankCtrl:setSelectedIndex(index)
		local headItem = obj:getChildAutoType("headItem")
		local txt_power = obj:getChildAutoType("txt_power")
		local txt_playerName = obj:getChildAutoType("txt_playerName")
		local btn_play 	= obj:getChildAutoType("btn_play")
		local txt_nobody = obj:getChildAutoType("txt_nobody")
		obj:removeClickListener(11)
		btn_play:removeClickListener(11)
		if data then
			headItem = BindManager.bindPlayerCell(headItem)
			headItem:setHead(data.head, data.level, data.id)
			obj:addClickListener(function(context)
				context:stopPropagation()--阻止事件冒泡
				ViewManager.open("ViewPlayerView",{playerId = data.id})
			end,11)
			txt_power:setText(string.format(Desc.DetectiveTrial_power,StringUtil.transValue(data.combat)))
			txt_playerName:setText(data.name)
			btn_play:addClickListener(function(context) 
				context:stopPropagation()--阻止事件冒泡
				ModelManager.BattleModel:requestBattleRecord(data.battleId)
			end,11)
		end
	end)


	local reqInfo = {
        rankType = GameDef.RankType.HeroTrial,
        collectionId = heroTrialInfo.id,
    }
    printTable(8848,">>>>reqInfo>>>",reqInfo)
    RPCReq.Rank_GetRankData(reqInfo,function(params)
        printTable(8848,">>>>>请求排行榜数据>>>>>",params)
        self.rankData = params.rankData or {}
        -- self.myRankData = params.myRankData or {}
        if tolua.isnull(self.view) then return end
		self.list_rank:setNumItems(3)  
		if params.rankData[1] then
			self.checkkill:setSelectedIndex(1)
			self.txt_fightPlayerName:setText(string.format(Desc.DetectiveTrial_playerName,params.rankData[1].name)) -- 首通玩家名字(噩梦)
		else
			self.checkkill:setSelectedIndex(0)
			self.txt_fightPlayerName:setText("")
		end
			-- local inRank = false
        -- local myRank = false
        -- local myId = tonumber(ModelManager.PlayerModel.userid)
        -- for k,v in pairs(self.rankData) do
        --     if myId == v.id then
        --         inRank = true
        --         myRank = k
        --         break
        --     end
        -- end
        -- self.checkInRankCtrl:setSelectedIndex(inRank and 1 or 0)
        -- if inRank then  -- 在榜上
        --     local num = ModelManager.GuildMLSModel:getRankRewardNum(bossLv,myRank)
        --     self.txt_myRank:setText(string.format(Desc.GuildMLSMain_inRank,myRank))
        --     self.txt_boxNum:setText("x" .. num)
        -- else
        --     self.txt_myRank:setText(Desc.GuildMLSMain_noRank)
        -- end
    end)
end


-- 设置控制器
function DetectiveTrialView:setController()
	local beingDay = DetectiveTrialModel:getActivityBeingDay() 	-- 活动进行天数
	print(8848,">>>self.level>>",self.level)
	self.checkpoint:setSelectedIndex(self.level) 	-- 1噩梦 	0普通和困难
	self.checkEnd:setSelectedIndex((self.isEnd or beingDay > self.pageIndex) and 1 or 0) 	-- 1已结束 	0没结束
end

-- 设置顶部页签列表
function DetectiveTrialView:setPageList()
	local beingDay = DetectiveTrialModel:getActivityBeingDay() 	-- 活动进行天数
	self.list_day:setSelectedIndex(self.pageIndex - 1) 	-- 默认选中一个
	self.list_day:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local lockCtrl 	= obj:getController("lock") 	-- 0 未解锁 1 已解锁
		local txt_day 	= obj:getChildAutoType("txt_day") 	-- 第几天
		lockCtrl:setSelectedIndex(beingDay >= index and 1 or 0)
		txt_day:setText(string.format(Desc.DetectiveTrial_day,index))
		local img_red = obj:getChildAutoType("img_red")
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.HeroTrial .. index, img_red)
	end)
	self.list_day:setNumItems(7)
	self.list_day:removeClickListener(111)
	self.list_day:addClickListener(function() 
		local index = self.list_day:getSelectedIndex()
		-- 这里还要判断有没有解锁
		if beingDay >= index+1 then
			self.pageIndex = index + 1
			self.level 	= 1
			self:refreshPanal()
		else
			RollTips.show(Desc.DetectiveTrial_lock)
			self.list_day:setSelectedIndex(self.pageIndex - 1)
		end
	end,111)
end

-- 设置个人首通奖励
function DetectiveTrialView:setOwnerReward()
	self.txt_personalTitle:setText(Desc.DetectiveTrial_personalTitle) 	-- 个人首通标题
	local ownerReward 	= DetectiveTrialModel:getOwnerRewardInfo(self.pageIndex,self.level) 
	local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	heroTrialInfo = heroTrialInfo[self.level]
	local bossMap = DetectiveTrialModel:getBossMap()
	local bossId 	= heroTrialInfo.id

	self.list_ownerReward:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data 	= ownerReward[index]
		local img_red = obj:getChildAutoType("img_red")
		local itemCell = BindManager.bindItemCell(obj)
		itemCell:setData(data.code,data.amount,data.type)

		-- 判断是否已经领取 领取后设置已领取效果
		if bossMap[bossId] and bossMap[bossId].personalReward and bossMap[bossId].personalReward == 2 then
			itemCell:setIsHook(true)
		else
			itemCell:setIsHook(false)
		end

		-- 判断是否可领取 添加领取动效
		if bossMap[bossId] and bossMap[bossId].personalReward and bossMap[bossId].personalReward == 1 then
			obj:setTouchable(false)
			img_red:setVisible(true)
			itemCell:setReceiveFrame(true)
		else
			obj:setTouchable(true)
			img_red:setVisible(false)
			itemCell:setReceiveFrame(false)
		end
	end)
	self.list_ownerReward:setData(ownerReward)
	self.list_ownerReward:resizeToFit(TableUtil.GetTableLen(ownerReward))
	self.list_ownerReward:removeClickListener(11)
	self.list_ownerReward:addClickListener(function(context) 
		-- context:stopPropagation()--阻止事件冒泡
		local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroTrial)
		if not actData then return end
		local actId   = actData.id
		if bossMap[bossId] and bossMap[bossId].personalReward and bossMap[bossId].personalReward == 1 then
			local reqInfo = {
				activityId = actId,
				bossId 	= bossId,
				rewardType = 1,
			}
			RPCReq.Activity_HeroTrial_GetBossRewardReq(reqInfo,function(params)
			end)
		end
	end,11)
end

-- 设置全服奖励
function DetectiveTrialView:setWholeReward()
	local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	heroTrialInfo 		= heroTrialInfo[self.level]
	local bossMap 		= DetectiveTrialModel:getBossMap()
	local serverData 	= DetectiveTrialModel:getServerData()
	local bossId 		= heroTrialInfo.id
	local wholeReward 	= DetectiveTrialModel:getWholeRewardInfo(self.pageIndex,self.level) 
	local totalBeat 	= 0 
	if serverData and serverData[bossId] and serverData[bossId].totalBeat then
		totalBeat = serverData[bossId].totalBeat
	end
	if self.level == 3 then
		self.txt_allFirstTitle:setText(Desc.DetectiveTrial_allFirstTitle) 	-- 个人首通标题
	else
		self.txt_allFirstTitle:setText(Desc.DetectiveTrial_allFirstTitle2)
	end
	self.txt_accRewardTips:setText(string.format(Desc.DetectiveTrial_accRewardTips1,totalBeat,heroTrialInfo.commonBeat)) -- 全服累计击杀(普通，困难)
	
	self.list_allReward:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data 	= wholeReward[index]
		local itemCell = BindManager.bindItemCell(obj)
		itemCell:setData(data.code,data.amount,data.type)
		local img_red = obj:getChildAutoType("img_red")
		-- 判断是否已经领取 领取后设置已领取效果
		if bossMap[bossId] and bossMap[bossId].commonReward and bossMap[bossId].commonReward == 2 then
			itemCell:setIsHook(true)
		else
			itemCell:setIsHook(false)
		end

		-- 判断是否可领取 添加领取动效
		if totalBeat > 0 and totalBeat >= heroTrialInfo.commonBeat then
			if (not bossMap[bossId])  or (not bossMap[bossId].commonReward) or (bossMap[bossId].commonReward == 0) then
				obj:setTouchable(false)
				img_red:setVisible(true)
				itemCell:setReceiveFrame(true)
			else
				obj:setTouchable(true)
				img_red:setVisible(false)
				itemCell:setReceiveFrame(false)
			end
		else
			obj:setTouchable(true)
			img_red:setVisible(false)
			itemCell:setReceiveFrame(false)
		end
	end)
	self.list_allReward:setData(wholeReward)
	self.list_allReward:resizeToFit(TableUtil.GetTableLen(wholeReward))
	self.list_allReward:removeClickListener(11)
	self.list_allReward:addClickListener(function(context) 
		-- context:stopPropagation()--阻止事件冒泡
		if totalBeat > 0 and totalBeat >= heroTrialInfo.commonBeat then
			if (not bossMap[bossId]) or (not bossMap[bossId].commonReward) or (bossMap[bossId].commonReward == 0) then
				local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroTrial)
				if not actData then return end
				local actId   = actData.id
				local reqInfo = {
					activityId = actId,
					bossId 	= bossId,
					rewardType = 2,
				}
				printTable(8848,">>reqInfo>>",reqInfo)
				RPCReq.Activity_HeroTrial_GetBossRewardReq(reqInfo,function(params)
				end)
			end
		end
	end,11)
end

-- 设置中间的立绘
function DetectiveTrialView:setLihui()
	local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	local data = heroTrialInfo[self.level]

	local heroInfo = DynamicConfigData.t_hero[data.model]
	self.txt_difficulty:setText(heroInfo.heroName) 	-- 英雄名字
	local fightConf = DynamicConfigData.t_fight[data.fightId];
	local power = fightConf.monstercombat
	self.txt_power:setText(power) 	-- 战力

	local lihuiDisplay= self.view:getChildAutoType('lihuiDisplay')
	if self.lihuiDisplay then self.lihuiDisplay = false end
	self.lihuiDisplay = BindManager.bindLihuiDisplay(lihuiDisplay)
	self.lihuiDisplay:setData(data.model)
end

-- 左右切换按钮
function DetectiveTrialView:setCheckBtn()
	local len = DetectiveTrialModel:getLevelLenth(self.pageIndex) 
	-- PathConfiger.getHeroOfMonsterIcon(head)


	self.btn_left:setVisible(self.level ~= 1)
	self.btn_right:setVisible(self.level ~= len)
	self.btn_right:getChildAutoType("point"):setScale(-1,1)
	self.btn_right:getController("checkpoint"):setSelectedIndex(self.level+1)
	self.btn_left:getController("checkpoint"):setSelectedIndex(self.level-1)
	self.btn_left:removeClickListener(11)
	self.btn_left:addClickListener(function() 
		self.level = self.level - 1
		if self.level <= 0 then
			self.level = 1
		end
		self.btn_left:setVisible(self.level ~= 1)
		self.btn_right:setVisible(self.level ~= len)
		self:refreshPanal()
	end,11)



	self.btn_right:removeClickListener(11)
	self.btn_right:addClickListener(function() 
		self.level = self.level + 1
		if self.level >= len then
			self.level = len
		end
		self.btn_left:setVisible(self.level ~= 1)
		self.btn_right:setVisible(self.level ~= len)
		self:refreshPanal()
	end,11)
end

-- 跳转到图鉴界面
function DetectiveTrialView:jumpToHeroInfo()
	local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	local data = heroTrialInfo[self.level]
	self.btn_jump:removeClickListener(11)
	self.btn_jump:addClickListener(function() 
		local conf = DynamicConfigData.t_HeroTotems
		local heroInfo = DynamicConfigData.t_hero[data.model]
        local arr = conf[heroInfo.category]
        local h = false
        for _, d in pairs(arr) do
            if (d.hero == data.model) then
                h = d
                break
            end
        end
        local info = {index = 1,heroId = data.model, heroList = {h}};
        ViewManager.open("HeroInfoView", info);
	end,11)
end

-- 设置切换按钮红点状态
function DetectiveTrialView:setCheckBtnRedState()
	local LRedState,RRedState,Licon,Ricon = DetectiveTrialModel:checkRewardStateById2(self.level,self.pageIndex)
	-- local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	-- local bossDataL = 	heroTrialInfo[self.level-1]
	-- local bossDataR = 	heroTrialInfo[self.level+1]
	-- local state,Licon,Ricon = false
	self.btn_left:getChildAutoType("icon/icon"):setURL("")
	self.btn_right:getChildAutoType("icon/icon"):setURL("")
	if Licon then
		self.btn_left:getChildAutoType("icon/icon"):setURL(PathConfiger.getHeroOfMonsterIcon(Licon))
	end
	self.btn_left.img_red:setVisible(LRedState)
	if Ricon then
		self.btn_right:getChildAutoType("icon/icon"):setURL(PathConfiger.getHeroOfMonsterIcon(Ricon))
	end
	self.btn_right.img_red:setVisible(RRedState)

end

-- 开始挑战
function DetectiveTrialView:beginChallenge()
	local beingDay = DetectiveTrialModel:getActivityBeingDay() 	-- 活动进行天数

	local heroTrialInfo = DetectiveTrialModel:getHeroTrialInfo(self.pageIndex)
	heroTrialInfo 		= heroTrialInfo[self.level]
	self.btn_fight:removeClickListener(11)
	self.btn_fight:addClickListener(function()
		local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroTrial)
		if not actData then return end
		local actId   = actData.id
		local reqInfo = {
			activityId = actId,
			bossId 	= heroTrialInfo.id,
		}
		printTable(8848,">>>reqInfo>>>",reqInfo)
		local fightId   = heroTrialInfo.fightId
		local gameType  = GameDef.BattleArrayType.HeroTrial
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
			if eventName == "begin" then
				RPCReq.Activity_HeroTrial_ChallengeReq(reqInfo,function(params)
					printTable(8848,">>>params>>挑战>>",params)
					DetectiveTrialModel:setSettleEndInfo(params)
					DetectiveTrialModel:reqGetBossBeatInfo()
				end)
			end

			if eventName == "next" then
			end

			if eventName == "end" then
				local endInfo = DetectiveTrialModel:gettleEndInfo()
				ViewManager.open("ReWardView",{page=8, isWin=endInfo.result})
				if endInfo.result then
					FileCacheManager.setBoolForKey(string.format("DetectiveTrialViewRecord_%s_%s",self.pageIndex,self.level), true)
				end
			end
		end,{fightID=fightId,configType=gameType})
	end,11)
end

-- 倒计时
function DetectiveTrialView:updateCountTimer()
	if self.isEnd then return end
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroTrial)
	printTable(8848,">>>actData>>",actData)
	if not actData then return end
	local actId   = actData.id
	local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
	if not addtime then return end

	if status == 2 and addtime == -1 then
		self.isEnd = false
		self.txt_countTimer:setText(Desc.activity_txt5)
	else
		local lastTime = addtime / 1000
		if lastTime == -1 then
			self.txt_countTimer:setText(Desc.activity_txt5)
		else
			if not tolua.isnull(self.txt_countTimer) then
				self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
			end
			local function onCountDown(time)
				if not tolua.isnull(self.txt_countTimer) then
					self.isEnd = false
					self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
				end
			end
			local function onEnd(...)
				self.isEnd = true
				if not tolua.isnull(self.txt_countTimer) then
					self.txt_countTimer:setText(Desc.activity_txt18)
				end
				self:refreshPanal()
			end
			if self.timer then
				TimeLib.clearCountDown(self.timer)
			end
			self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
		end
	end
end

-- 倒计时
function DetectiveTrialView:updateCountTimer2()
	local lastTime = TimeLib.getDayResidueSecond()
	if not tolua.isnull(self.txt_countTimer2) then
		self.txt_countTimer2:setText(TimeLib.formatTime(lastTime))
	end
	local function onCountDown(time)
		if not tolua.isnull(self.txt_countTimer2) then
			self.txt_countTimer2:setText(TimeLib.formatTime(time))
		end
	end
	local function onEnd(...)
	end
	if self.timer2 then
		TimeLib.clearCountDown(self.timer2)
	end
	self.timer2 = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
end

function DetectiveTrialView:_exit()
	if self.timer then
		TimeLib.clearCountDown(self.timer)
	end
	if self.timer2 then
		TimeLib.clearCountDown(self.timer2)
	end
end


return DetectiveTrialView