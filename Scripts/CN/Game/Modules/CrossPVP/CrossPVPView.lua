local CrossPVPView,Super = class("CrossPVPView", Window)
local HorizonPvpType = require"Configs.GameDef.HorizonPvpType"
function CrossPVPView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPView"
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossPVPView:_initEvent()
	
end

function CrossPVPView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPView
	self.awardList = viewNode:getChildAutoType('$awardList')--GList
	self.awardList1 = viewNode:getChildAutoType('$awardList1')--GList
	self.list = viewNode:getChildAutoType('$list')--GList
	self.Menulist = viewNode:getChildAutoType('Menulist')--GGroup
	self.begin = viewNode:getChildAutoType('begin')--GButton
	self.bg = viewNode:getChildAutoType('bg')--GLoader
	self.btn_help = viewNode:getChildAutoType('btn_help')--GButton
	self.defand = viewNode:getChildAutoType('defand')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.leaveAward = viewNode:getChildAutoType('leaveAward')--GRichTextField
	self.list_rank = viewNode:getChildAutoType('list_rank')--GList
	self.nextReward = viewNode:getController('nextReward')--Controller
	self.openCross = viewNode:getController('openCross')--Controller
	self.rank = viewNode:getChildAutoType('rank')--GTextField
	self.record = viewNode:getChildAutoType('record')--com_btn_nil
		self.record.img_red = viewNode:getChildAutoType('record/img_red')--GImage
	self.reward = viewNode:getChildAutoType('reward')--com_btn_nil
		self.reward.img_red = viewNode:getChildAutoType('reward/img_red')--GImage
	self.rewardStr1 = viewNode:getChildAutoType('rewardStr1')--GRichTextField
	self.rewardStr2 = viewNode:getChildAutoType('rewardStr2')--GRichTextField
	self.score = viewNode:getChildAutoType('score')--GTextField
	self.seasontime = viewNode:getChildAutoType('seasontime')--GTextField
	self.seasontimet = viewNode:getChildAutoType('seasontimet')--GTextField
	self.severName = viewNode:getChildAutoType('severName')--GTextField
	self.shop = viewNode:getChildAutoType('shop')--com_btn_nil
		self.shop.img_red = viewNode:getChildAutoType('shop/img_red')--GImage
	self.title1 = viewNode:getChildAutoType('title1')--GTextField
	self.upValue = viewNode:getChildAutoType('upValue')--GTextField
	--{autoFieldsEnd}:CrossPVP.CrossPVPView
	--Do not modify above code-------------
end

function CrossPVPView:_initUI()
	self:_initVM()
	self.bg = self.view:getChildAutoType("bg")
	self.bg:setIcon(PathConfiger.getBg("crossBg.png"))

	self.btn_help:addClickListener(function()
		local info = {}
	    info['title'] = Desc.CrossPVPTitle
	    info['desc'] = Desc.CrossPVPContent
	    ViewManager.open("GetPublicHelpView",info) 
	end)
	self.record:addClickListener(function()
		ViewManager.open("CrossPVPHistoryView")
		RedManager.updateValue("V_Crosspvp_record",false)
	end)
	self.reward:addClickListener(function()
		ViewManager.open("CrossPVPRewardView")
	end)
	self.defand:addClickListener(function()
		self:enterDefandView()
	end)
	self.shop:addClickListener(function()
        ModuleUtil.openModule(ModuleId.Shop.id,true,{shopType = 16} )
    end)

	self.begin:addClickListener(function()
		local function sendMsg()
			RPCReq.HorizonPvp_Match({},function(data)
				if next(data) == nil then return RollTips.show(Desc["CrossPVPRESETDesc1"]) end
				CrossPVPModel:setMatchingPlayer(data)
				if data.retCode == HorizonPvpType.OPEN or data.retCode == 0 then
					ViewManager.open("CrossPVPMatchView",data)
					self.openCross:setSelectedIndex(0)
				else
					RollTips.show(Desc["CrossPVPRESETDesc"])
					self.openCross:setSelectedIndex(1)
					RedManager.updateValue("V_Crosspvp_begin",false)
				end
			end)
		end
		if CrossPVPModel:getResidueNum() == 0 then
			if CrossPVPModel:getBuyNum() > 0 then
				local info = {
				text = string.format(Desc.CrossPVPDesc5,DynamicConfigData.t_limit[GameDef.GamePlayType.HorizonPvp].topupConsume[1].amount),
				type="yes_no",
				onYes = function()
					sendMsg()
				end,
				}
				Alert.show(info)
			else
				local config = DynamicConfigData.t_VipPriviligeType[20][VipModel.level]
				local curEff = config and config.effect or 0
				for key,value in ipairs(DynamicConfigData.t_VipPriviligeType[20]) do
					if value.effect > curEff then
						curEff = value.vipLv
						return RollTips.show(string.format(Desc.CrossPVPDesc19,curEff))
					end
				end
				RollTips.show(string.format(Desc.CrossPVPDesc20,curEff))
			end
			return 
		end
		sendMsg()
	end)
	self.awardList:setItemRenderer(function(index, obj)
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = self.awardList._dataTemplate[index  + 1]})
		itemcell:setItemData(itemData)
	end)
	self.awardList1:setItemRenderer(function(index, obj)
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = self.awardList1._dataTemplate[index  + 1]})
		itemcell:setItemData(itemData)
	end)
	self.list:setItemRenderer(function(index, obj)
		local data = self.list._dataTemplate[index + 1]
		local lhicon = BindManager.bindLihuiDisplay(obj:getChild("lhicon"))
		lhicon:setData(self.list._dataTemplate[index + 1])
		lhicon:pause()
		local config = DynamicConfigData.t_hero[data]
		obj:getChild("name"):setText(config.heroName)
		obj:getController("index"):setSelectedIndex(index)
	end)
	self.list_rank:setItemRenderer(function(index, obj)
		local data = self.list_rank._dataTemplate[index + 1]
		obj:getChild("txt_name"):setText(data.name)
		obj:getChild("txt_fightCap"):setText(CrossPVPModel:getSeverName(data.serverId))
		obj:getChild("headItem"):addClickListener(function()
			data.rankIndex = index + 1
			ViewManager.open("CrossPVPPlayerInfoView",data)
		end,99)
		local hero = BindManager.bindPlayerCell(obj:getChild("headItem"))
		hero:setHead(data.head, data.level,nil,nil,nil)
		obj:getChild("txt_score"):setText(data.score)
		obj:getChild("txt_rankNum"):setText(index + 1)
		obj:getController("rankIndex"):setSelectedIndex(3)
		if index <= 2 then
			obj:getController("rankIndex"):setSelectedIndex(index)
		end
	end)
	self.list_rank:setVirtual()
	RPCReq.HorizonPvp_GetTotemsHero({},function(data)
		if next(data) then
			self.list:setData(data.totemsHero)
			CrossPVPModel:setSeverData({totemsHero = data.totemsHero or {},state = data.state or HorizonPvpType.RUN,endTtime = data.time or 0})
		end
	end)
	RPCReq.HorizonPvp_Rank({},function(data)
		if next(data) then
			CrossPVPModel:setNowRank(data.myRank)
			CrossPVPModel:setBaseMark(data.myScore)
			CrossPVPModel:setRankData(data)
			self.list_rank:setData(data.rank)
		end
	end)
	
	RedManager.register("V_Crosspvp_record", self.record:getChildAutoType("img_red"))
	RedManager.register("V_Crosspvp_begin", self.begin:getChildAutoType("img_red"))
	RedManager.register("V_Crosspvp_defand", self.defand:getChildAutoType("img_red"))
	
	self.severName:setText(CrossPVPModel:getSeverName(LoginModel:getUnitServerId()))

	self:_refreshView()

	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
	self:timeHandle()
	self.upValue:setText("+"..DynamicConfigData.t_const["HorizonPvpWeekUp"].value.."%")
	CrossPVPModel:hisRedCheck()
end
local reqTime = 3
local reqCount = 5
function CrossPVPView:timeHandle()
	local data = CrossPVPModel:getSeverData()
	if not data or not next(data) or not data.endTtime then return end
	local lastTime = (data.endTtime + 1800) - ServerTimeModel:getServerTime() - 10
	if lastTime <= 1800 then 
		if lastTime < 0 then
			lastTime = 0 
			reqTime = reqTime - 1
			if reqTime <= 0 and reqCount > 0 then
				reqTime = 3
				reqCount = reqCount - 1
				RPCReq.HorizonPvp_GetTotemsHero({},function(data)
					if next(data) then
						self.list:setData(data.totemsHero)
						CrossPVPModel:setSeverData({totemsHero = data.totemsHero or {},state = data.state or HorizonPvpType.RUN,endTtime = data.time or 0})
					end
				end)
			end
		end
		self.seasontime:setText(StringUtil.formatTime(lastTime,"h",Desc.common_TimeDesc2))
		self.seasontimet:setText(Desc.CrossPVPDesc21)
		self.openCross:setSelectedIndex(1)
		RedManager.updateValue("V_Crosspvp_begin",false)
		return
	end
	local typ = "d"
	local descTyp = Desc.common_TimeDesc
	if lastTime < 60 * 60 * 24 then
		typ = "h"
		descTyp =  Desc.common_TimeDesc2
	end
	self.seasontime:setText(StringUtil.formatTime(lastTime,typ,descTyp))
	self.seasontimet:setText(Desc.CrossPVPDesc22)
	if data.state and data.state ~= HorizonPvpType.OPEN then
		self.openCross:setSelectedIndex(1)
		RedManager.updateValue("V_Crosspvp_begin",false)
	else
		self.openCross:setSelectedIndex(0)
	end
end
function CrossPVPView:update()
	self:timeHandle()
end
function CrossPVPView:enterDefandView()
	CrossPVPModel:setCurPVPType(CrossPVPModel._CrossPVPType._def)
    local battleCall = function (param)
        if (param == "cancel") then
			
        elseif (param == "begin") then
			RollTips.show(Desc.HigherPvP_saveDefSuc)
            ViewManager.close("BattlePrepareView")
        end
    end
    local const = CrossPVPModel:getConfigByMark()
    local args = {
        fightID = const.fightId,
        configType = GameDef.BattleArrayType.HorizonPvpDefOne,
		customPrepare = true,
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args)
end

function CrossPVPView:refresh_CrossView()
	self.score:setText(CrossPVPModel:getBaseMark())
	local randNum = CrossPVPModel:getNowRank()
	self.rank:setText(randNum ~= 0 and randNum or Desc.CrossPVPDesc9)
	local curConfig,nextConfig = CrossPVPModel:getConfigByMark()
	if curConfig then
		self.awardList:setData(curConfig.reward)
		if nextConfig then
			self.rewardStr1:setText(curConfig.min.."-"..curConfig.max)
		else
			self.rewardStr1:setText(curConfig.min.."+")
		end
		if nextConfig then
			self.awardList1:setData(nextConfig.reward)
			self.rewardStr2:setText(nextConfig.min.."-"..nextConfig.max)
		else
			self.nextReward:setSelectedIndex(1)
		end
	end
	if CrossPVPModel:getResidueNum() <= 0 then
		self.leaveAward:setText(string.format(Desc.CrossPVPDesc7,CrossPVPModel:getBuyNum()))
		RedManager.updateValue("V_Crosspvp_begin",false)
	else
		if self.openCross:getSelectedIndex() == 0 then
			RedManager.updateValue("V_Crosspvp_begin",true)
			self.leaveAward:setText(string.format(Desc.CrossPVPDesc4,CrossPVPModel:getResidueNum()))
		end
	end
end

function CrossPVPView:_refreshView()

end
function CrossPVPView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
	reqTime = 3
	reqCount = 5
end
return CrossPVPView