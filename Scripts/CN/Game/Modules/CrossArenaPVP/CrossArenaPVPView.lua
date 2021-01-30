local CrossArenaPVPView,Super = class("CrossArenaPVPView", Window)
local HorizonPvpType = require"Configs.GameDef.HorizonPvpType"
function CrossArenaPVPView:ctor()
	self._packName = "CrossArenaPVP"
	self._compName = "CrossArenaPVPView"
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
--	package.loaded["Game.Modules.CrossArenaPVP.CrossArenaPVPModel"] = nil
--	CrossArenaPVPModel = nil
--	CrossArenaPVPModel = require "Game.Modules.CrossArenaPVP.CrossArenaPVPModel".new()
	self.skeletonNode = {}
	self.calltimer = false
	self.calltimer2 = false
	self._args.moduleId = 222
end

function CrossArenaPVPView:_initEvent()
	
end

function CrossArenaPVPView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossArenaPVP.CrossArenaPVPView
	self.awardList = viewNode:getChildAutoType('$awardList')--GList
	self.begin = viewNode:getChildAutoType('begin')--GButton
	self.boxList = viewNode:getChildAutoType('boxList')--GList
	self.btnRand = viewNode:getChildAutoType('btnRand')--GButton
	self.btnZan1 = viewNode:getChildAutoType('btnZan1')--Button1
		self.btnZan1.red = viewNode:getChildAutoType('btnZan1/red')--GImage
	self.btnZan2 = viewNode:getChildAutoType('btnZan2')--Button1
		self.btnZan2.red = viewNode:getChildAutoType('btnZan2/red')--GImage
	self.btnZan3 = viewNode:getChildAutoType('btnZan3')--Button1
		self.btnZan3.red = viewNode:getChildAutoType('btnZan3/red')--GImage
	self.dayTimeTxt = viewNode:getChildAutoType('dayTimeTxt')--GTextField
	self.defand = viewNode:getChildAutoType('defand')--GButton
	self.endTimeTxt = viewNode:getChildAutoType('endTimeTxt')--GRichTextField
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.heroCell = viewNode:getChildAutoType('heroCell')--GButton
	self.hisRank = viewNode:getChildAutoType('hisRank')--GTextField
	self.leaveAward = viewNode:getChildAutoType('leaveAward')--GRichTextField
	self.nextReward = viewNode:getController('nextReward')--Controller
	self.openCross = viewNode:getController('openCross')--Controller
	self.player1 = viewNode:getChildAutoType('player1')--Component10
		self.player1.com_mode = viewNode:getChildAutoType('player1/com_mode')--GLoader
		self.player1.txt_level = viewNode:getChildAutoType('player1/txt_level')--GTextField
		self.player1.txt_name = viewNode:getChildAutoType('player1/txt_name')--GTextField
	self.player2 = viewNode:getChildAutoType('player2')--Component10
		self.player2.com_mode = viewNode:getChildAutoType('player2/com_mode')--GLoader
		self.player2.txt_level = viewNode:getChildAutoType('player2/txt_level')--GTextField
		self.player2.txt_name = viewNode:getChildAutoType('player2/txt_name')--GTextField
	self.player3 = viewNode:getChildAutoType('player3')--Component10
		self.player3.com_mode = viewNode:getChildAutoType('player3/com_mode')--GLoader
		self.player3.txt_level = viewNode:getChildAutoType('player3/txt_level')--GTextField
		self.player3.txt_name = viewNode:getChildAutoType('player3/txt_name')--GTextField
	self.progress = viewNode:getChildAutoType('progress')--GProgressBar
	self.rank = viewNode:getChildAutoType('rank')--GTextField
	self.record = viewNode:getChildAutoType('record')--com_btn_nil
		self.record.img_red = viewNode:getChildAutoType('record/img_red')--GImage
	self.reward = viewNode:getChildAutoType('reward')--com_btn_nil(1)
		self.reward.img_red = viewNode:getChildAutoType('reward/img_red')--GImage
	self.score = viewNode:getChildAutoType('score')--GTextField
	self.seasontime = viewNode:getChildAutoType('seasontime')--GTextField
	self.seasontimet = viewNode:getChildAutoType('seasontimet')--GTextField
	self.shop = viewNode:getChildAutoType('shop')--com_btn_nil
		self.shop.img_red = viewNode:getChildAutoType('shop/img_red')--GImage
	self.username = viewNode:getChildAutoType('username')--GTextField
	self.zhanliTxt = viewNode:getChildAutoType('zhanliTxt')--GTextField
	--{autoFieldsEnd}:CrossArenaPVP.CrossArenaPVPView
	--Do not modify above code-------------
end

function CrossArenaPVPView:_initUI()
	self:_initVM()
	--self.bg = self.view:getChildAutoType("bg")
	self:setBg("crossArenaPVP_bg.jpg")
	self.headCell = BindManager.bindPlayerCell(self.heroCell);
	self.headCell:setHead(PlayerModel.head, PlayerModel.level, PlayerModel.userid,nil,PlayerModel.headBorder);
	self.username:setText("[S."..LoginModel:getUnitServerId().."]"..PlayerModel.username) 
	self.hisRank = self.view:getChildAutoType("hisRank")

	self.awardList = self.view:getChildAutoType("$awardList")

	self.btnRand:addClickListener(function()
		--ViewManager.open("CrossTeamPVPRankView", {type = GameDef.RankType.CrossArenaScore})
		ViewManager.open("PublicRankView2", {type = GameDef.RankType.CrossArenaScore, icon = {type = 2, code = 22}})
	end)

	self.moneyBar:setData({{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}})
	self.player1:addClickListener(function()
		if CrossArenaPVPModel.rankData[1] then
			ViewManager.open("CrossArenaPVPPlayerInfoView",CrossArenaPVPModel.rankData[1])
		end
	end)
	self.player2:addClickListener(function()
		if CrossArenaPVPModel.rankData[2] then
			ViewManager.open("CrossArenaPVPPlayerInfoView",CrossArenaPVPModel.rankData[2])
		end
	end)
	self.player3:addClickListener(function()
		if CrossArenaPVPModel.rankData[3] then
			ViewManager.open("CrossArenaPVPPlayerInfoView",CrossArenaPVPModel.rankData[3])
		end
	end)

	self.reward = self.view:getChildAutoType("reward")
	self.reward:addClickListener(function()
		--ViewManager.open("CrossArenaPVPRewardView") 
		ViewManager.open("PublicRankRewardView", {rankType = GameDef.RankType.CrossArenaScore,rewardData = DynamicConfigData.t_CrossArenaRankItem})
	end)

	self.record:addClickListener(function()
		ViewManager.open("CrossArenaPVPHistoryView")
		CrossArenaPVPModel:setRecordFightMs()
		RedManager.updateValue("V_CrossArenapvp_record",false)
	end)
	CrossArenaPVPModel:checkRecord()
	
	self.defand:addClickListener(function()
		self:enterDefandView()
	end)
	self.shop:addClickListener(function()
        ModuleUtil.openModule(ModuleId.Shop_crossArean)
    end)

	self.begin:addClickListener(function()
		RPCReq.CrossArena_GetChallengeList({},function(data)
			if tolua.isnull(self.view)then return end
			ViewManager.open("CrossArenaPVPSlectedView",data)
		end)
	end)

	
	RedManager.register("V_CrossArenapvp_record", self.record:getChildAutoType("img_red"))
	RedManager.register("V_CrossArenapvp_begin", self.begin:getChildAutoType("img_red"))
	RedManager.register("V_CrossArenapvp_defand", self.defand:getChildAutoType("img_red"))

	CrossArenaPVPModel:getBaseInfo()
	CrossArenaPVPModel:redCheck()

	self:_refreshView()

	RPCReq.CrossArena_GetInfo({},function(data)
		CrossArenaPVPModel:setNowRank(data.info.rank)
		CrossArenaPVPModel:setBaseMark(data.info.score)
		CrossArenaPVPModel:setHisRank(data.info.highRank or 0)
		if tolua.isnull(self.view)then return end
		self.rank:setText(data.info.rank ~= 0 and data.info.rank or Desc.CrossPVPDesc9)
		self.hisRank:setText(data.info.highRank ~= 0 and data.info.highRank or Desc.CrossPVPDesc9)
		
	end)

	
	CrossArenaPVPModel:hisRedCheck()
	local boxData = DynamicConfigData.t_CrossArenaDailyReward
	local maxTime = 0
	for i=1,#boxData do 
		if maxTime < boxData[i].time then
			maxTime = boxData[i].time
		end
	end
	self.maxTime = maxTime
	self.boxListItem = {}
	self.boxList:setItemRenderer(function(index, obj)
		self.boxListItem[index+1]=obj
		local data = boxData[index + 1]
		local c1 = obj:getController("c1")
		obj:getChildAutoType("itemCell/num"):setVisible(false)
		obj:getChildAutoType("num"):setText(data.reward[1].amount)
		obj:getChildAutoType("time"):setText(data.time)
		local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		local itemData = ItemsUtil.createItemData({data = data.reward[1]})
		itemcell:setItemData(itemData)
		obj:getChildAutoType("itemCell"):removeClickListener()
		local wlist = CrossArenaPVPModel:getDailyReward() or {}
		
		if CrossArenaPVPModel:getBattleNum() >= data.time and not wlist[data.id] then
			obj:getController("status"):setSelectedIndex(1)
			obj:addClickListener(function()
				RPCReq.CrossArena_GetReward({id = index + 1},function(data)
					CrossArenaPVPModel:setDailyReward(data.reward)
					if tolua.isnull(self.view)then return end
					obj:getController("status"):setSelectedIndex(0)
					local boxData = DynamicConfigData.t_CrossArenaDailyReward
					self.boxList:setData(boxData)
				end)
			end,99)
			
		else
			if wlist and wlist[data.id] then
				obj:getController("status"):setSelectedIndex(2)
			else
				obj:getController("status"):setSelectedIndex(0)
			end
			obj:addClickListener(function(context)
				for k,v in pairs(self.boxListItem) do 
					v:getController("c1"):setSelectedIndex(0)
			   end
				context:stopPropagation()
				if c1:getSelectedIndex() ~= 1 then
					c1:setSelectedIndex(1)
					obj:getChildAutoType("list"):setItemRenderer(function(index, ccobj)
							local tdata = obj:getChildAutoType("list")._dataTemplate[index + 1]
							local titemcell = BindManager.bindItemCell(ccobj)
							local titemData = ItemsUtil.createItemData({data = tdata})
							titemcell:setItemData(titemData)
						end)
					obj:getChildAutoType("list"):setData(data.reward)
					obj:getChildAutoType("n10"):setWidth(112*#data.reward)
				end
			end,99)
		end

	
	end)

	self.view:addClickListener(function()
	   for k,v in pairs(self.boxListItem) do 
			v:getController("c1"):setSelectedIndex(0)
	   end
	end)
	
	self.awardList:setItemRenderer(function(index, obj)
		local data = self.awardList._dataTemplate[index +1]
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = data})
		itemcell:setItemData(itemData)
	end)

	self:updateFight()
end

--更新排名
function CrossArenaPVPView:updateRank( rankData )
	if not rankData then return end
	for i = 1,3 do 
		local obj = self["btnZan"..i]
		local item=self["player"..i]
		local c1=item:getController("c1")
		obj:getChildAutoType("red"):setVisible(false)
		if rankData[i] then
			
			obj:setTitle(rankData[i].exParam.param1)
			if CrossArenaPVPModel:checkLikeState(rankData[i].id) then
				obj:setSelected(true)
				obj:getChildAutoType("red"):setVisible(false)
				obj:removeClickListener(33)
			else
				obj:setSelected(false)
				obj:setTouchable(true)
				if CrossArenaPVPModel:canZan() then
					obj:getChildAutoType("red"):setVisible(true)
					obj:addClickListener(function()
						if CrossArenaPVPModel:canZan() then
							CrossArenaPVPModel.likeTimes = CrossArenaPVPModel.likeTimes + 1
							RPCReq.CrossArena_Like({playerId = rankData[i].id},function(data)
								CrossArenaPVPModel:setLikeList(data.likeList)
								RedManager.updateValue("V_CrossArenapvp_zan",CrossArenaPVPModel:canZan())
								if tolua.isnull(self.view)then return end
								obj:setTitle(rankData[i].exParam.param1+1)
								obj:setSelected(true)
								obj:setTouchable(false)
								obj:getChildAutoType("red"):setVisible(false)
								
								if not CrossArenaPVPModel:canZan() then
									for i = 1,3 do 
										local ssbj = self["btnZan"..i]
										ssbj:getChildAutoType("red"):setVisible(false)
										ssbj:setTouchable(false)
									end
								end
							end)
						end
					end,33)
				else
					obj:removeClickListener(33)
					obj:getChildAutoType("red"):setVisible(false)
					obj:setTouchable(false)
				end
			end

			local txt_name=item:getChildAutoType("txt_name")--
			local txt_level=item:getChildAutoType("txt_level")
			local com_mode=item:getChildAutoType("com_mode")
			local info= rankData[i]
			c1:setSelectedIndex(1)

			txt_name:setText("[S."..info.serverId.."]"..info.name)
			txt_level:setText(info.value)

			if self.skeletonNode[i] then
				self.skeletonNode[i]:removeFromParent()
			end
			local modeId = info.heroOpertion or info.head
			if modeId and modeId > 0 then
				local skeletonNode = SpineUtil.createModel(com_mode, {x = 0, y =0}, "stand", modeId,true,nil,info.fashionCode)
				self.skeletonNode[i] = skeletonNode
			end
			

			
		else
			c1:setSelectedIndex(0)
			obj:setTouchable(false)
			obj:setTitle(0)
		end
	end

end

--更新战力
function CrossArenaPVPView:updateFight( ... )
    local fight = ModelManager.CardLibModel:getFightVal() or 0
    self.zhanliTxt:setText(StringUtil.transValue(fight))

end


-- function CrossArenaPVPView:timeHandle()
-- 	local data = CrossArenaPVPModel:getSeverData()
-- 	if not data or not next(data) or not data.nextSeasonDt then return end
-- 	local lastTime = (data.nextSeasonDt) / 1000 - ServerTimeModel:getServerTime() - 10
-- 	local typ = "d"
-- 	local descTyp = Desc.common_TimeDesc
-- 	if lastTime < 60 * 60 * 24 then
-- 		typ = "h"
-- 		descTyp =  Desc.common_TimeDesc2
-- 	end
-- 	self.seasontime:setText(StringUtil.formatTime(lastTime,typ,descTyp))
-- 	self.seasontimet:setText(Desc.CrossPVPDesc22)
-- 	if data.state and data.state ~= HorizonPvpType.OPEN then
-- 		self.openCross:setSelectedIndex(1)
-- 		RedManager.updateValue("V_CrossArenapvp_begin",false)
-- 	else
-- 		self.openCross:setSelectedIndex(0)
-- 	end
-- end
function CrossArenaPVPView:timeHandle()
	local data = CrossArenaPVPModel:getSeverData()
	local addtime = (data.nextSeasonDt) / 1000 - ServerTimeModel:getServerTime() - 10
	local dayTime = 24*60*60
	if addtime > 0 then
		self.seasontime:setText(TimeLib.GetTimeFormatDay(addtime, 2))
		local function onCountDown(time)
			if time<dayTime then
				self.seasontime:setText(TimeLib.formatTime(time))
			else
				self.seasontime:setText(TimeLib.GetTimeFormatDay(time))
			end
		end
		local function onEnd(...)
			self.seasontime:setText(Desc.CrossPVPDesc23)
			self.openCross:setSelectedIndex(1)
		end
		if self.calltimer then
			TimeLib.clearCountDown(self.calltimer)
		end
		self.calltimer = TimeLib.newCountDown(addtime, onCountDown, onEnd, false, false, false)
	else
		self.seasontime:setText(Desc.CrossPVPDesc23)
		self.openCross:setSelectedIndex(1)
	end

	if data.isTodayOpen then
		local addtime2 = (data.endTime) / 1000 - ServerTimeModel:getServerTime() +5
		if addtime2 > 0 then
			self.endTimeTxt:setText(TimeLib.GetTimeFormatDay(addtime2, 2))
			local function onCountDown(time)
				if time<dayTime then
					self.endTimeTxt:setText(Desc.CrossArenaPVPDesc5:format(TimeLib.formatTime(time)))
				else
					self.endTimeTxt:setText(Desc.CrossArenaPVPDesc5:format(TimeLib.GetTimeFormatDay1(time)))
				end
			end
			local function onEnd(...)
				self.endTimeTxt:setText(Desc.CrossArenaPVPDesc4)
				self.openCross:setSelectedIndex(1)
				CrossArenaPVPModel:getBaseInfo()
				CrossArenaPVPModel:redCheck()
			end
			if self.calltimer2 then
				TimeLib.clearCountDown(self.calltimer2)
			end
			self.calltimer2 = TimeLib.newCountDown(addtime2, onCountDown, onEnd, false, false, false)
		else
			self.endTimeTxt:setText(Desc.CrossArenaPVPDesc4)
			self.openCross:setSelectedIndex(1)
		end
	else
		local addtime2 = (data.endTime) / 1000 - ServerTimeModel:getServerTime() + 5
		if addtime2 > 0 then
			self.endTimeTxt:setText(Desc.CrossArenaPVPDesc7:format(TimeLib.GetTimeFormatDay(addtime2, 2)))
			local function onCountDown(time)
				if time<dayTime then
					self.endTimeTxt:setText(Desc.CrossArenaPVPDesc7:format(TimeLib.formatTime(time)))
				else
					self.endTimeTxt:setText(Desc.CrossArenaPVPDesc7:format(TimeLib.GetTimeFormatDay1(time)))
				end
			end
			local function onEnd(...)
				CrossArenaPVPModel:getBaseInfo()
				self.endTimeTxt:setText("")
				self.openCross:setSelectedIndex(0)
				CrossArenaPVPModel:redCheck()
			end
			if self.calltimer2 then
				TimeLib.clearCountDown(self.calltimer2)
			end
			self.calltimer2 = TimeLib.newCountDown(addtime2, onCountDown, onEnd, false, false, false)
		else
			self.endTimeTxt:setText("")
		end
		self.openCross:setSelectedIndex(1)
	end
end

function CrossArenaPVPView:enterDefandView()
	CrossArenaPVPModel:setCurPVPType(CrossArenaPVPModel._CrossPVPType._def)
    local battleCall = function (param,data)
        if (param == "cancel") then
			
        elseif (param == "begin") then
			RollTips.show(Desc.HigherPvP_saveDefSuc)
            ViewManager.close("BattlePrepareView")
        end
    end
    local args = {
        fightID = DynamicConfigData.t_CrossArenaConfig[1].fightId,
        configType = GameDef.BattleArrayType.CrossArenaDefOne,
		customPrepare = true,
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args)
end

function CrossArenaPVPView:crossArena_timeUpdate()
	self:timeHandle()
end

function CrossArenaPVPView:refresh_CrossArenaView()
	self.score:setText(CrossArenaPVPModel:getBaseMark())
	local randNum = CrossArenaPVPModel:getNowRank()
	local hisRank = CrossArenaPVPModel:getHisRank()
	self.rank:setText(randNum ~= 0 and randNum or Desc.CrossPVPDesc9)
	self.hisRank:setText(hisRank ~= 0 and hisRank or Desc.CrossPVPDesc9)
	self.leaveAward:setText(string.format(Desc.CrossArenaPVPDesc1,CrossArenaPVPModel:getUsedFreeTimes()))
	self.dayTimeTxt:setText(string.format("(%d/%d)",CrossArenaPVPModel:getBattleNum(),self.maxTime))
	self.progress:setValue(100*CrossArenaPVPModel:getBattleNum()/self.maxTime)
	local boxData = DynamicConfigData.t_CrossArenaDailyReward
	self.boxList:setData(boxData)
	local config = CrossArenaPVPModel:getConfigByMark()
	if config and next(config) then
		self.awardList:setData(config.seasonRewardPre)
	end
	CrossArenaPVPModel:reqGetRanks(function(data)
		if tolua.isnull(self.view)then return end
		self:updateRank(data)
	end)
end

function CrossArenaPVPView:getPersent()
	--奇怪的进度条
	local tMax = {13,47,83,100}
	local boxData = DynamicConfigData.t_CrossArenaDailyReward
	local maxTime = boxData[i].time
	local maxPer = 100
	for i=1,#boxData do 
		if CrossArenaPVPModel:getBattleNum() < boxData[i].time then
			maxTime = tMax[i]
			maxTime = tMax[i]
			break
		end
	end

	local per = 100*CrossArenaPVPModel:getBattleNum()/self.maxTime

end

function CrossArenaPVPView:_refreshView()

end
function CrossArenaPVPView:_exit()
	if self.calltimer then
		TimeLib.clearCountDown(self.calltimer)
	end

	if self.calltimer2 then
		TimeLib.clearCountDown(self.calltimer2)
	end
	if CrossArenaPVPModel.haveBattle then
		Dispatcher.dispatchEvent(EventType.CrossTabView_refresh)
	end
end
return CrossArenaPVPView