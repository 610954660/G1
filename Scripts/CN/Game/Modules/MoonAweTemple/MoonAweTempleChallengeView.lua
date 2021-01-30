--Date :2020-12-01
--Author : wyz
--Desc : 月慑神殿 挑战界面

local MoonAweTempleChallengeView,Super = class("MoonAweTempleChallengeView", Window)

function MoonAweTempleChallengeView:ctor()
	--LuaLog("MoonAweTempleChallengeView ctor")
	self._packName = "MoonAweTemple"
	self._compName = "MoonAweTempleChallengeView"
	self._rootDepth = LayerDepth.PopWindow
	self.godId 		= self._args.godId
	self.crownId 	= self._args.crownId
	self.curGodInfo = {}
	self.timer  	= false
	self.stageNum = false
	self.strongIndex = 0
end

function MoonAweTempleChallengeView:_initEvent( )
	
end

function MoonAweTempleChallengeView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:MoonAweTemple.MoonAweTempleChallengeView
	self.CrownTitleCell = viewNode:getChildAutoType('CrownTitleCell')--GComponent
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_challenge = viewNode:getChildAutoType('btn_challenge')--GButton
	self.btn_challengeCD = viewNode:getChildAutoType('btn_challengeCD')--btn_CD
		self.btn_challengeCD.img_red = viewNode:getChildAutoType('btn_challengeCD/img_red')--GImage
	self.btn_challengeRecord = viewNode:getChildAutoType('btn_challengeRecord')--GButton
	self.btn_strong1 = viewNode:getChildAutoType('btn_strong1')--btn_strong
		self.btn_strong1.txt_tips = viewNode:getChildAutoType('btn_strong1/txt_tips')--GTextField
		self.btn_strong1.txt_title = viewNode:getChildAutoType('btn_strong1/txt_title')--GTextField
	self.btn_strong2 = viewNode:getChildAutoType('btn_strong2')--btn_strong
		self.btn_strong2.txt_tips = viewNode:getChildAutoType('btn_strong2/txt_tips')--GTextField
		self.btn_strong2.txt_title = viewNode:getChildAutoType('btn_strong2/txt_title')--GTextField
	self.btn_strong3 = viewNode:getChildAutoType('btn_strong3')--btn_strong
		self.btn_strong3.txt_tips = viewNode:getChildAutoType('btn_strong3/txt_tips')--GTextField
		self.btn_strong3.txt_title = viewNode:getChildAutoType('btn_strong3/txt_title')--GTextField
	self.btn_travel = viewNode:getChildAutoType('btn_travel')--GButton
	self.cdtimerCtrl = viewNode:getController('cdtimerCtrl')--Controller
	self.checkPossessor = viewNode:getController('checkPossessor')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.heroCell = viewNode:getChildAutoType('heroCell')--GButton
	self.line = viewNode:getChildAutoType('line')--GGraph
	self.modelNode = viewNode:getChildAutoType('modelNode')--GComponent
	self.selectStrong = viewNode:getController('selectStrong')--Controller
	self.txt_bossLv = viewNode:getChildAutoType('txt_bossLv')--GRichTextField
	self.txt_challengeCondition = viewNode:getChildAutoType('txt_challengeCondition')--GRichTextField
	self.txt_crownName = viewNode:getChildAutoType('txt_crownName')--GTextField
	self.txt_godAttr = viewNode:getChildAutoType('txt_godAttr')--GRichTextField
	self.txt_nobody = viewNode:getChildAutoType('txt_nobody')--GTextField
	self.txt_playerName = viewNode:getChildAutoType('txt_playerName')--GTextField
	self.txt_possessorTitle = viewNode:getChildAutoType('txt_possessorTitle')--GTextField
	--{autoFieldsEnd}:MoonAweTemple.MoonAweTempleChallengeView
	--Do not modify above code-------------
end

function MoonAweTempleChallengeView:_initUI( )
	self:_initVM()
	MoonAweTempleModel:reqCurGodPosInfo(self.godId)
	-- self:MoonAweTempleChallengeView_refreshPanal()
end

function MoonAweTempleChallengeView:MoonAweTempleChallengeView_refreshPanal(_,params) 
	self:refreshPanal()
end

function MoonAweTempleChallengeView:refreshPanal()
	MoonAweTempleModel.godId = self.godId
	self.curGodInfo = MoonAweTempleModel.curGodInfo 	-- 当前神位信息
	self.checkPossessor:setSelectedIndex((self.curGodInfo.playerId and self.curGodInfo.playerId ~= 0 )  and 0 or 1) 	-- 0 有占有者  1 没有占有者
	self:setPossessorInfo() 
	self:setGodInfo()
	self:setBossInfo()
	self:setCondition()
	self:setChallengeRecord()
	self:setStrongBtn()
	self:setFight()
	self:updateCDCountTime()
end

-- 强化按钮
function MoonAweTempleChallengeView:setStrongBtn()
	local MoonTempleFight = DynamicConfigData.t_MoonTempleFight[self.godId]
	local maxLv 	= TableUtil.GetTableLen(MoonTempleFight)
	local curGodInfo = MoonAweTempleModel.curGodInfo 		-- 当前神位数据
	local stageLv 	= curGodInfo.stage or 0 		-- boss当前等级
	local const 	= DynamicConfigData.t_MoonTempleConst[1]
	local strong = const.strengthen


	local checkMaxLvCtrl1 = self.btn_strong1:getController("checkMaxLvCtrl")
	local checkMaxLvCtrl2 = self.btn_strong2:getController("checkMaxLvCtrl")
	local checkMaxLvCtrl3 = self.btn_strong3:getController("checkMaxLvCtrl")
	local check1 = (stageLv + strong[1]) > maxLv
	local check2 = (stageLv + strong[2]) > maxLv
	local check3 = (stageLv + strong[3]) > maxLv
	checkMaxLvCtrl1:setSelectedIndex(check1 and 1 or 0)
	checkMaxLvCtrl2:setSelectedIndex(check2 and 1 or 0)
	checkMaxLvCtrl3:setSelectedIndex(check3 and 1 or 0)

	local index = self.strongIndex
	local checkStage =  function ()
		if check1 and check2 and check3 then
			self.stageNum = 0
			self.btn_strong1:getController("button"):setSelectedIndex(0)
			self.btn_strong2:getController("button"):setSelectedIndex(0)
			self.btn_strong3:getController("button"):setSelectedIndex(0)
		end

		if not check3 and index == 2 then
			self.selectStrong:setSelectedIndex(index)
		elseif not check2 and index == 1 then
			self.selectStrong:setSelectedIndex(index)
		elseif not check1 and index == 0 then
			self.selectStrong:setSelectedIndex(index)
		else
			self.selectStrong:setSelectedIndex(0)
		end
	end
		self.btn_strong1:removeClickListener(11)
		self.btn_strong1:addClickListener(function()
			if check1 then
				-- self.selectStrong:setSelectedIndex(index)
				RollTips.show(Desc.MoonAweTemple_maxLvTips)
				self.stageNum = 0
				checkStage()
				self:refreshPanal()
			else
				self.strongIndex = 0
			end
		end,11)
		self.btn_strong2:removeClickListener(11)
		self.btn_strong2:addClickListener(function()
			if check2 then
				-- self.selectStrong:setSelectedIndex(index)
				RollTips.show(Desc.MoonAweTemple_maxLvTips)
				self.stageNum = 0
				checkStage()
				self:refreshPanal()
			else
				self.strongIndex = 1
			end
		end,11)
		self.btn_strong3:removeClickListener(11)
		self.btn_strong3:addClickListener(function()
			if check3 then
				-- self.selectStrong:setSelectedIndex(index)
				RollTips.show(Desc.MoonAweTemple_maxLvTips)
				self.stageNum = 0
				checkStage()
				self:refreshPanal()
			else
				self.strongIndex = 2
			end
		end,11)
	checkStage()

	self.btn_strong1.txt_title:setText(string.format(Desc.MoonAweTemple_strong,strong[1]))
	self.btn_strong2.txt_title:setText(string.format(Desc.MoonAweTemple_strong,strong[2]))
	self.btn_strong3.txt_title:setText(string.format(Desc.MoonAweTemple_strong,strong[3]))
end

-- 设置占有者信息
function MoonAweTempleChallengeView:setPossessorInfo()
	self.txt_possessorTitle:setText(Desc.MoonAweTemple_possessorTitle)
	local heroCell = BindManager.bindPlayerCell(self.heroCell)
	heroCell:setHead(self.curGodInfo.head, self.curGodInfo.level, self.curGodInfo.playerId,nil,self.curGodInfo.headBorder);
	self.heroCell:removeClickListener(11)
	self.heroCell:addClickListener(function(context)
		context:stopPropagation()--阻止事件冒泡
		ViewManager.open("ViewPlayerView",{playerId = self.curGodInfo.playerId})
	end,11)
	self.txt_playerName:setText(self.curGodInfo.name)
end

-- 设置神位信息
function MoonAweTempleChallengeView:setGodInfo()
	local crownInfo 	= DynamicConfigData.t_CrownTitle[self.crownId] 		-- 称号信息
	self.txt_godAttr:setText(crownInfo.attrType)

	local CrownTitleCell = BindManager.bindCrownTitleCell(self.CrownTitleCell)
	CrownTitleCell:setData(crownInfo.code)

	self.txt_crownName:setText(crownInfo.name)
end 


-- 设置boss信息
function MoonAweTempleChallengeView:setBossInfo()
	local godInfo = DynamicConfigData.t_MoonTempleBasic[self.godId]
	local curGodInfo = MoonAweTempleModel.curGodInfo 		-- 当前神位数据
	local stage = curGodInfo.stage or 0
	local squadInfo =  MoonAweTempleModel:getMonsterSquad(godInfo.sid,self.godId,stage)

	self.txt_bossLv:setText("")
	if curGodInfo.stage and curGodInfo.stage ~= 0  then
		self.txt_bossLv:setText(string.format(Desc.MoonAweTemple_bossLv,curGodInfo.stage))
	end

	-- boss模型
	if self.modelNode then
        self.modelNode:displayObject():removeAllChildren()
    end
    SpineUtil.createModel(self.modelNode, {x = 0, y =0}, "stand",godInfo.modelId,true)
end

-- 挑战条件
function MoonAweTempleChallengeView:setCondition()
	local godInfo = DynamicConfigData.t_MoonTempleBasic[self.godId]
	if self.curGodInfo.rank then
		self.txt_challengeCondition:setText(string.format(Desc.MoonAweTemple_challengeCondition,godInfo.lowestRank,self.curGodInfo.rank))
	else
		self.txt_challengeCondition:setText(string.format(Desc.MoonAweTemple_challengeCondition2,godInfo.lowestRank))
	end
	self.btn_travel:removeClickListener(11) 	-- 前往竞技场
	self.btn_travel:addClickListener(function() 
		ModuleUtil.openModule(ModuleId.Arena.id,true)
	end,11)
end

-- 挑战记录
function MoonAweTempleChallengeView:setChallengeRecord()
	self.btn_challengeRecord:removeClickListener(11)
	self.btn_challengeRecord:addClickListener(function() 
		ViewManager.open("MoonAweTempleRecordView",{godId = self.godId})
	end,11)
end

-- 挑战
function MoonAweTempleChallengeView:setFight()
	local godInfo = DynamicConfigData.t_MoonTempleBasic[self.godId]
	local stage = self.curGodInfo.stage or 0 
	local const 	= DynamicConfigData.t_MoonTempleConst[1]
	local strong = const.strengthen
	local MoonTempleFight = DynamicConfigData.t_MoonTempleFight[self.godId]
	local maxLv 	= TableUtil.GetTableLen(MoonTempleFight)

	local myRank = self.curGodInfo.rank or 999999
	local conditionRank = godInfo.lowestRank
	self.btn_challengeCD:removeClickListener(11)
	self.btn_challengeCD:addClickListener(function() 
		RollTips.show(Desc.MoonAweTemple_cdCool)
	end,11)

	self.btn_challenge:removeClickListener(11)
	self.btn_challenge:addClickListener(function() 
		if PlayerModel.userid == self.curGodInfo.playerId then
			RollTips.show(Desc.MoonAweTemple_haveGod)
			return
		end
		if myRank > conditionRank then
			RollTips.show(Desc.MoonAweTemple_noAchieve)
			return
		end
		local fightId   = godInfo.sid
		local gameType  = GameDef.BattleArrayType.StarTemple
		local index 	= stage + strong[self.selectStrong:getSelectedIndex()+1]
		local stageReq = strong[self.selectStrong:getSelectedIndex()+1]
		if index > maxLv then
			stageReq = 0
		end
		print(8848,">>>fightId>>" .. fightId)
		local reqInfo  	= {
			id 	= self.godId,			-- 1:integer			#神位id	
			stage = stageReq,		-- 2:integer			#本次强化次数
		}
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
			if eventName == "begin" then
				RPCReq.StarTemple_Challenge(reqInfo,function(params)
					-- printTable(8848,">>>params>>挑战>>",params)
					MoonAweTempleModel:setSettleEndInfo(params)
					MoonAweTempleModel:reqCurGodPosInfo(self.godId)
					MoonAweTempleModel:reqStarTempleInfo()
				end)
			end

			if eventName == "next" then
			end

			if eventName == "end" then
				local endInfo = MoonAweTempleModel:gettleEndInfo()
				MoonAweTempleModel.resultInfo.godId = self.godId
				if not tolua.isnull(self.view) then
					self.cdtimerCtrl:setSelectedIndex(endInfo.result and 1 or 0)
				end
				ViewManager.open("ReWardView",{page=10, isWin=endInfo.result})
				MoonAweTempleModel:reqStarTempleInfo()
			end
		end,{fightID=fightId,configType=gameType,index = index})
	end,11)
end

-- 冷却倒计时
function MoonAweTempleChallengeView:updateCDCountTime()
	local txt_countTimer = self.btn_challengeCD:getChildAutoType("title")
	local cdEndTime = 0 
	if self.curGodInfo and self.curGodInfo.failTimeMs then
		cdEndTime = math.floor(self.curGodInfo.failTimeMs/1000)
	end
	local serverTime = ServerTimeModel:getServerTime()
	local lastTime = cdEndTime - serverTime
	if lastTime <= 0 then
		self.cdtimerCtrl:setSelectedIndex(1)
	else
		if not tolua.isnull(txt_countTimer) then
			txt_countTimer:setText(TimeLib.formatTime(lastTime))
		end
		local function onCountDown(time)
			if not tolua.isnull(txt_countTimer) then
				txt_countTimer:setText(TimeLib.formatTime(time))
			end
		end
		local function onEnd(...)
			self.cdtimerCtrl:setSelectedIndex(1)
		end
		if self.timer then
			TimeLib.clearCountDown(self.timer)
		end
		self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
	end
end

function MoonAweTempleChallengeView:_exit()
	MoonAweTempleModel.godId = false
	if self.timer then
		TimeLib.clearCountDown(self.timer)
	end
end

return MoonAweTempleChallengeView