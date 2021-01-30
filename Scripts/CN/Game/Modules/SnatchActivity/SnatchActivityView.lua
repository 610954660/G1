local FGUIUtil = require "Game.Utils.FGUIUtil"
local SnatchActivityView,Super = class("SnatchActivityView", Window)
function SnatchActivityView:ctor(data)
    self._packName = "SnatchTreasure"
	self._compName = "SnatchActivityView"
	self._rootDepth = LayerDepth.Window

	self.__data = data
end    

function SnatchActivityView:_initUI()
	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("CollectMapRedFirst_isShow" .. dayStr, true)
	OperatingActivitiesModel:CollectMapRedFirst()

	self.btn_help = self.view:getChildAutoType("btn_help1")
	self.btn_help:addClickListener(function()
		local moduleId = self.__data.actData.showContent.moduleOpen
		local info={}
	    info['title']=Desc["help_StrTitle"..moduleId]
	    info['desc']=Desc["help_StrDesc"..moduleId]
	    ViewManager.open("GetPublicHelpView",info) 
	end)
	self.imgbg = self.view:getChildAutoType("imgbg")
	self.imgbg:setIcon(PathConfiger.getBg("img_jituduobao_bg.jpg"))
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	self.closeBtn:addClickListener(function()
		self:closeView()
	end)
	self.tipsPanel = self.view:getChildAutoType("tipsPanel")
	self.tipsPanel:getChildAutoType("bg"):addClickListener(function()
		self.tipsPanel:setVisible(false)
	end)
	self.tipsPanel:getChildAutoType("closeButton"):addClickListener(function()
		self.tipsPanel:setVisible(false)
	end)
	self.goBtn = self.tipsPanel:getChildAutoType("goBtn")
	self.goBtn:addClickListener(function()
		if self.goBtn.goMuduleId then
			ModuleUtil.openModule(self.goBtn.goMuduleId,true)
--			self:closeView()
		else
			self.tipsPanel:setVisible(false)
		end
	end)
	self.getBtn = self.tipsPanel:getChildAutoType("getBtn")
	self.getBtn:addClickListener(function()
		self.tipsPanel:setVisible(false)
		if self.getBtn.typ == 1 then
			RPCReq.Activity_CollectMap_Reward({id = self.getBtn.index},function()
			end)
		else
			RPCReq.Activity_CollectMap_BoxReward({id = self.getBtn.index},function()
			end)
		end
	end)
	
	self.mapId = 1
	self.curRound = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.CollectMap)
	self.moduleId = actData and actData.showContent.moduleId or 1

	self.bg = self.view:getChildAutoType("imgView/bg")
	self.t_PicActivityTask = DynamicConfigData.t_PicActivityTask[self.moduleId]
	self.t_PicActivityBox = DynamicConfigData.t_PicActivityBox[self.moduleId]
	self.t_PicActivityReward = DynamicConfigData.t_PicActivityReward
	self.t_PicActivityTitle = DynamicConfigData.t_PicActivityTitle
	self.content = self.tipsPanel:getChildAutoType("content")
	self.progress = self.tipsPanel:getChildAutoType("progress")
	self.tipsPanelCont = self.tipsPanel:getController("recardState")
	self.imgView = self.view:getChildAutoType("imgView")
	self.tittle_txt = self.view:getChildAutoType("tittle_txt")
	self.time_txt = self.view:getChildAutoType("time_txt")
	for i = 1,9 do
		self["btn"..i] = self.view:getChildAutoType("imgView/btn"..i)
		local coner = self["btn"..i]:getController("state")
		coner:setSelectedIndex(0)
		self["btn"..i]:addClickListener(function()
			local data = self.t_PicActivityTask[self.curRound][i + self.curRound * 9 - 9]
			local rewardList = data.reward 
			local str = data.dec
			local max = data.count
			local goMuduleId = data.window
			self:openTipsPanel(data,i,1)
		end)
	end

	for i = 1, 6 do 
		self["giftBtn"..i] = self.view:getChildAutoType("giftBtn"..i)
		self["giftBtn"..i]:addClickListener(function()
			if self["giftBtn"..i]:getController("state"):getSelectedIndex() == 2 then
				return
			end
			self:openTipsPanel(self.t_PicActivityBox[self.curRound][i],i,2)
		end)
		self["giftBtn"..i].visibleTab = self.t_PicActivityBox[1][i].needTask
	end

	for i = 1, 4 do
		self["itemCell"..i] = self.view:getChildAutoType("itemCell"..i)
		local itemList = self["itemCell"..i]:getChildAutoType("itemList")
		local rewardList = self.t_PicActivityReward[self.moduleId][i].reward 
		itemList:setItemRenderer(function(index,obj)
			local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = rewardList[index  + 1]})
			itemcell:setItemData(itemData)
		end)
		itemList:setData(rewardList)
		local funcBtn = self["itemCell"..i]:getChildAutoType("funcBtn")
		funcBtn:getController("state"):setSelectedIndex(1)
--		funcBtn:setTouchable(false)
		funcBtn:addClickListener(function(obj)
			if funcBtn:getController("state"):getSelectedIndex() == 1 then
				RPCReq.Activity_CollectMap_BoxTimesReward({id = i},function()
					
				end)
			else
				self:openTipsPanel(self.t_PicActivityReward[self.moduleId][i],i,3)
			end
		end)
	end
--	RPCReq.Activity_CollectMap_NextMap({},function()
--	end)

	self.time_txt:setText(StringUtil.formatTime(self.__data.actData.realEndMs / 1000 - os.time(),"d",DescAuto[286])) -- [286]="%s天%s小时%s分%s秒"
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
	self:update()
	self:refreshpanel()
end
function SnatchActivityView:update()
--	TimeLib.formatTime(self.__data.actData.realEndMs - os.time(),"hh:mm:ss")
	local time = math.floor((self.__data.actData.realEndMs - ServerTimeModel:getServerTimeMS()) / 1000)
	if time <= 0 then time = 0 end
	self.time_txt:setText(StringUtil.formatTime(time,"d",DescAuto[286])) -- [286]="%s天%s小时%s分%s秒"
end
function SnatchActivityView:activity_CollectMap()
	self:refreshpanel()
	if self.mapId ~= self.severData.mapId then
		self.mapId = self.severData.mapId
		local nodeObj = self.imgView:displayObject()
		nodeObj:stopAllActions()
		local arr = {}
		table.insert(arr,cc.DelayTime:create(0.5))
		table.insert(arr,cc.FadeOut:create(0))
		table.insert(arr,cc.FadeIn:create(1))
		local ac = cc.Sequence:create(arr)
		nodeObj:runAction(ac)
	end
end
--#desc:成就同步数据结构
--.PRecord_Info {
--	recordId		0:integer 
--	acc 			1:integer -次数
--	finish 			2:*integer --完成
--	got				3:*integer -- 已经领取
--}
--#集图夺宝
--.PActivity_CollectMap {
--	records 			1:*PRecord_Info(recordId)		# 任务状态表
--	mapId 				2:integer  						# 当前地图id
--	boxReward 			3:*integer 						# 宝箱奖励状态	
--	boxTimesReward 		4:*integer 						# 宝箱激活次数奖励状态
--	boxCountReward  	5:integer 						# 已领宝箱数(进度条)	
--}

function SnatchActivityView:refreshpanel()
	self.severData = OperatingActivitiesModel:getCollectMap()
	self.curRound = self.severData.mapId
	if next(self.severData) == nil then return end
	self.bg:setURL(PathConfiger.getSnatchActivityBg(self.severData.mapId))
	self.tittle_txt:setText(self.t_PicActivityTitle[self.severData.mapId].chapters)
	self.tipsPanel:setVisible(false)
	for i = 1, 6 do 
		if self["giftBtn"..i]:isVisible() then
			local state = true
			for key,value in pairs(self["giftBtn"..i].visibleTab) do
				if state and self["giftBtn"..i]:getController("state"):getSelectedIndex() == 0 then
					state = false
				end
			end
			self["giftBtn"..i]:getController("state"):setSelectedIndex(state and "1" or "0")
		end
	end
	for key,value in pairs(self.severData.boxReward) do
		self["giftBtn"..key]:getController("state"):setSelectedIndex(tostring(value))
	end
	for key = 1,9 do
		local value = self.severData.records[key + (self.curRound - 1) * 9]
		local coner = self["btn"..key]:getController("state")
		if value and value.got then
			coner:setSelectedIndex(2)
		elseif value and value.finish then
			coner:setSelectedIndex(1)
		else
			coner:setSelectedIndex(0)
		end
	end
	for i = 1,4 do
		local funcBtn = self["itemCell"..i]:getChildAutoType("funcBtn")
		funcBtn:getController("state"):setSelectedIndex(self.severData.boxTimesReward[i])
		if i== 4 then
			self["itemCell"..i]:getChildAutoType("dajiang"):setVisible(true)
		end
		local str = string.format(Desc.SnatchActivityStr2,self.severData.boxCountReward,self.t_PicActivityReward[self.moduleId][i].needNumber)
		self["itemCell"..i]:getChildAutoType("str"):setText(str)
	end
end
function SnatchActivityView:openTipsPanel(configData,index,typ)
	if not self.severData then return end
	self.tipsPanelCont:setSelectedIndex(0)
	self.tipsPanel:setVisible(true)
	self.content:setText("")
	self.goBtn.goMuduleId = nil
	
	local progressBar = self.tipsPanel:getChildAutoType("progress")
	progressBar:setValue(0)
	local itemList = self.tipsPanel:getChildAutoType("itemList")
	local rewardList = configData.reward
	itemList:setItemRenderer(function(index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = rewardList[index  + 1]})
		itemcell:setItemData(itemData)
	end)
	itemList:setData(rewardList)
	self.getBtn.typ = typ
	self.getBtn.index = index
	if typ == 1 then
		self.getBtn.index = index + (self.curRound - 1) * 9
		local severDataCell = self.severData.records[index + (self.curRound - 1) * 9]
		self.content:setText(configData.dec)
		self.goBtn.goMuduleId = configData.window
		progressBar:setMax(configData.count)
		if severDataCell then
			local str = severDataCell.acc > configData.count and configData.count or severDataCell.acc
			progressBar:setValue(str)
			if severDataCell.got then
				self.tipsPanelCont:setSelectedIndex(2)
			elseif severDataCell.finish then
				self.tipsPanelCont:setSelectedIndex(1)
			else
				self.tipsPanelCont:setSelectedIndex(0)
			end
		end
	elseif typ == 2 then
		local str = string.format(Desc.SnatchActivityStr1,self["giftBtn"..index].visibleTab[1],self["giftBtn"..index].visibleTab[2],self["giftBtn"..index].visibleTab[3])
		self.content:setText(str)
		progressBar:setMax(3)
		local num = 0 
		for key,value in pairs(self["giftBtn"..index].visibleTab) do
			if self.severData.records[value + (self.curRound - 1) * 9] and self.severData.records[value + (self.curRound - 1) * 9].got then
				num = num + 1
			end
		end
		progressBar:setValue(num)
		local severDataCell = self.severData.boxReward[index]
		self.tipsPanelCont:setSelectedIndex(severDataCell)
	elseif typ == 3 then
		progressBar:setValue(self.severData.boxCountReward)
		progressBar:setMax(configData.needNumber)
		local str = string.format(Desc.SnatchActivityStr3,self.t_PicActivityReward[self.moduleId][index].needNumber)
		self.content:setText(str)
		local severDataCell = self.severData.boxTimesReward[index]
		self.tipsPanelCont:setSelectedIndex(severDataCell)
	end
end
function SnatchActivityView:_enter()

end

function SnatchActivityView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

return SnatchActivityView
