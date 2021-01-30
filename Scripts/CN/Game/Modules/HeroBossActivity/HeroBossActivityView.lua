local HeroBossActivityView, Super = class("HeroBossActivityView", Window)
function HeroBossActivityView:ctor(args)
	self._packName = "HeroBossActivity"
	self._compName = "HeroBossActivityView"
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
	self.t_NewHeroBossReward = DynamicConfigData.t_NewHeroBossReward
	self.t_NewHeroActivity = DynamicConfigData.t_NewHeroActivity
	self.t_NewHeroShop = DynamicConfigData.t_NewHeroShop
	self.resultData = false
	self.timer = false
end

function HeroBossActivityView:_initUI()
--	local dayStr = DateUtil.getOppostieDays()--活动出现红点，现在没这个需求
--	FileCacheManager.setBoolForKey("setHeroBossRedFirst_isShow" .. dayStr, true)
--	OperatingActivitiesModel:setHeroBossRedFirst()

	self.act_count = self.view:getChildAutoType("act_count")
	self.act_tittle = self.view:getChildAutoType("act_tittle")
	self.act_time = self.view:getChildAutoType("act_time")

	self.bg = self.view:getChildAutoType("bgImg")
	self.topList = self.view:getChildAutoType("topList")
	self.btn_go = self.view:getChildAutoType("btn_go")
	self.btn_go:addClickListener(function()
		if self.severData.leftTimes <= 0 then 
			RollTips.show(Desc.HeroBossActivityDesc5)
			return
		end
		self:goFight()
	end)
	RedManager.register("V_ACTIVITY_" .. GameDef.ActivityType.NewHeroCopy, self.btn_go:getChild("img_red"))

	self.btn_shop = self.view:getChildAutoType("btn_shop")
	self.btn_shop:addClickListener(function()
		ModuleUtil.openModule(ModuleId.HeroShopView.id)
	end)
	self.btn_rank = self.view:getChildAutoType("btn_rank")
	self.btn_rank:addClickListener(function()
		ViewManager.open("HeroBossRanInfoView")
	end)
	self.awardList1 = self.view:getChildAutoType("$awardList")
	self.awardList1:setItemRenderer(handler(self,self.awardList1Handle))

	self.help_btn = self.view:getChildAutoType("help_btn")
	self.help_btn:addClickListener(function()
		local info={}
	    info['title']=Desc["NewHeroBossTitle"]
	    info['desc']=Desc["NewHeroBossDesc"]
	    ViewManager.open("GetPublicHelpView",info) 
	end)
	self:refushInit()
end
function HeroBossActivityView:goFight()
	local function battleHandler(eventName)
		if eventName == "begin" then
			local params = {}
			params.activityId = GameDef.ActivityType.NewHeroCopy
			RPCReq.Activity_NewHeroCopy_Start(params, function(data)
				self.resultData = data
			end)
		elseif eventName == "end" then
			ViewManager.open("HeroBossResultView",{damage = self.resultData.damage,index = self.resultData.index,view = self})
		end
	end
	Dispatcher.dispatchEvent(
	EventType.battle_requestFunc,
	battleHandler,
	{fightID = self.t_NewHeroActivity[self.moduleId].fightId, configType = GameDef.BattleArrayType.NewHeroCopy})
end
function HeroBossActivityView:awardList1Handle(index, obj)
	local itemcell = BindManager.bindItemCell(obj)
	local itemData = ItemsUtil.createItemData({data = self.showAward[index  + 1]})
	itemcell:setItemData(itemData)
end
function HeroBossActivityView:activity_HeroBossData()
	self:refushInit()
end
function HeroBossActivityView:refushInit()
	self.severData = OperatingActivitiesModel:getHeroBossData()
	self.actData = HeroBossActivityModel:getActData()
	self.moduleId = HeroBossActivityModel:getModuleId()

	self.showAward = self.t_NewHeroActivity[self.moduleId].rewardPre
	self.awardList1:setData(self.showAward)
	self.act_count:setText(string.format(Desc.HeroBossActivityDesc3,self.severData.leftTimes))
	self.bg:setIcon(PathConfiger.getHeroBossActivityBg(self.actData.showContent.activeBg))

	local endMs = self.actData.realStartMs /1000 + self.actData.showContent.days * 24 * 60 * 60
	local lastTime = math.floor(endMs - ServerTimeModel:getServerTimeMS() / 1000)
	if lastTime <= 0 then 
		self.view:getController("activityend"):setSelectedIndex(1)
		RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.NewHeroCopy, false)
	else
		if self.timer then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		end
		local typ = "d"
		local descTyp = Desc.common_TimeDesc
		if lastTime < 60 * 60 * 24 then
			typ = "h"
			descTyp =  Desc.common_TimeDesc2
		end
		self.act_time:setText(StringUtil.formatTime(lastTime,typ,descTyp))
		self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
	end
	RPCReq.Rank_GetRankData({rankType = GameDef.RankType.NewHeroCopy}, function(serverData)
		self.topList:setItemRenderer(function(index,obj)
			local data = serverData.rankData[index + 1]
			if data then
				obj:getChild("name"):setText(data.name)
				local rankIcon = obj:getChild("rankIcon")
				rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",index  + 1))
				obj:getChild("num"):setText("X"..HeroBossActivityModel:getBoxNum(data.value))
				obj:getController("state"):setSelectedIndex(0)
			else
				obj:getController("state"):setSelectedIndex(1)
			end
		end)
		self.topList:setNumItems(3)
	end)
end
function HeroBossActivityView:update()
	if not self.actData then 
		if self.timer then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
			self.timer = false
		end
		return
	end
	local endMs = self.actData.realStartMs /1000 + self.actData.showContent.days * 24 * 60 * 60
	local lastTime = math.floor(endMs - ServerTimeModel:getServerTimeMS() / 1000)
	if lastTime < 0 then lastTime = 0 end
	local typ = "d"
	local descTyp = Desc.common_TimeDesc
	if lastTime < 60 * 60 * 24 then
		typ = "h"
		descTyp =  Desc.common_TimeDesc2
	end
	self.act_time:setText(StringUtil.formatTime(lastTime,typ,descTyp))
end

function HeroBossActivityView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
end
return HeroBossActivityView