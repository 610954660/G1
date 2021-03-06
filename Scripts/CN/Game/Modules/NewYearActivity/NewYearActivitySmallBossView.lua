--Date :2021-01-22
--Author : generated by FairyGUI
--Desc : 

local NewYearActivitySmallBossView,Super = class("NewYearActivitySmallBossView", Window)

function NewYearActivitySmallBossView:ctor()
	--LuaLog("NewYearActivitySmallBossView ctor")
	self._packName = "NewYearActivity"
	self._compName = "NewYearActivitySmallBossView"
	self._rootDepth = LayerDepth.PopWindow
	self.id = false
	self.bossId = false
	self.flag = false
	self.timerKey = false
	self.bossInfo = {}
	self.bossData = {}
end

function NewYearActivitySmallBossView:_initEvent( )
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
		if self.bossData.status == 2 then
			self:battleBoss()
		else
			RollTips.show(Desc.NewYearActivity_str4)
		end
	end)
end

function NewYearActivitySmallBossView:battleBoss()
	local callBack = function(type)
		if(type == "begin") then
			local params = {}
			params.activityId = GameDef.ActivityType.NewYear
			params.bossId = self.id
			params.onSuccess = function (data)
				printTable(6,"挑战小Boss data",data)
				self.bossData.status = data.status
				ModelManager.NewYearActivityModel:checkSmallBossRed()
				self:setLeftTime()
				self:setBtnState()
			end
			printTable(6,"挑战小Boss",params)
			RPCReq.Activity_NewYear_Challenge(params,params.onSuccess)
		elseif(type == "end") then
			local battleData = FightManager.getBettleData(GameDef.BattleArrayType.NewYear)
			ViewManager.open("ReWardView",{page=0, isWin=battleData.result,showLose=true})
		end
	end
	Dispatcher.dispatchEvent(EventType.battle_requestFunc,callBack, {fightID=self.bossInfo.fightId,configType=GameDef.BattleArrayType.NewYear})
end

function NewYearActivitySmallBossView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:NewYearActivity.NewYearActivitySmallBossView
	self.battleRewardList = viewNode:getChildAutoType('battleRewardList')--GList
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.bossNode = viewNode:getChildAutoType('bossNode')--GLoader
	self.btn_battle = viewNode:getChildAutoType('btn_battle')--GButton
	self.btn_tuijian = viewNode:getChildAutoType('btn_tuijian')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.showTxt = viewNode:getChildAutoType('showTxt')--GTextField
	self.tipComp = viewNode:getChildAutoType('tipComp')--Component1
	self.tipComp.blackbg = viewNode:getChildAutoType('tipComp/blackbg')--GLabel
	self.tipComp.tipList = viewNode:getChildAutoType('tipComp/tipList')--GList
	self.tipComp.title = viewNode:getChildAutoType('tipComp/title')--GRichTextField
	self.tipCtr = viewNode:getController('tipCtr')--Controller
	self.txt_bossName = viewNode:getChildAutoType('txt_bossName')--GTextField
	self.txt_num = viewNode:getChildAutoType('txt_num')--GRichTextField
	--{autoFieldsEnd}:NewYearActivity.NewYearActivitySmallBossView
	--Do not modify above code-------------
end

function NewYearActivitySmallBossView:_initUI( )
	self:_initVM()
	self.id = self._args.id
	self.bossInfo = NewYearActivityModel:getNewYearBossConfig(self.id)
	self.bossData = NewYearActivityModel.bossInfo[self.id] or {}
	printTable(6,"self.bossData",self.bossData)
	self.bossId = self.bossInfo.bossId
	self.showTxt:setText(string.format(Desc.NewYearActivity_str1,self.bossInfo.tip))
	self:setTitle(self.bossInfo.name)
	self:setBossNode()
	self:setRewardList()
	self:setLeftTime()
	self:setBtnState()
end

function NewYearActivitySmallBossView:setBossNode()
	SpineUtil.createModel(self.bossNode, {x = 0, y =0}, "stand", self.bossId, false)
	self.txt_bossName:setText(self.bossInfo.name)
end

function NewYearActivitySmallBossView:setRewardList()
	local reward = self.bossInfo.rewards
	self.battleRewardList:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data = reward[index]
		local itemCell 	= BindManager.bindItemCell(obj)
		itemCell:setData(data.code, data.amount, data.type)
	end)
	self.battleRewardList:setData(reward)
end

function NewYearActivitySmallBossView:showHeroTips()
	local monsterInfo = DynamicConfigData.t_monster[self.bossId]
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

function NewYearActivitySmallBossView:setLeftTime()
	if self.timerKey then 
		TimeLib.clearCountDown(self.timerKey)
	end
	if self.bossData.status == 2 then 
		if self.bossData.expireMs and self.bossData.expireMs > 0 then 
			local expireMs = self.bossData.expireMs
			local timems = math.floor((expireMs - ServerTimeModel:getServerTimeMS()) / 1000)
			local function onCountDown(time)
				if not tolua.isnull(self.txt_num) then
					local str = TimeLib.formatTime(time,true,false)
					self.txt_num:setText(string.format(Desc.NewYearActivity_str3,str))
				end
			end
			local function onEnd(...)
				self.btn_battle:setGrayed(true)
			end
			self.timerKey = TimeLib.newCountDown(timems, onCountDown, onEnd, false, false, false)
		else
			self.txt_num:setText("")
		end	
	else
		self.txt_num:setText("")
	end
end

function NewYearActivitySmallBossView:setBtnState()
	if self.bossData.status == 2 then --可挑战
		self.btn_battle:setGrayed(false)
	else --不可挑战
		self.btn_battle:setGrayed(true)
	end
end

function NewYearActivitySmallBossView:_exit()
    TimeLib.clearCountDown(self.timerKey)
end

return NewYearActivitySmallBossView