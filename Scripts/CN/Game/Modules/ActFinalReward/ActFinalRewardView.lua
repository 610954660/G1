-- added by xhd
-- 精灵主题活动  最终赏

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local ActFinalRewardView = class("ActFinalRewardView",Window)

function ActFinalRewardView:ctor()
	self._packName 	= "ActFinalReward"
	self._compName 	= "ActFinalRewardView"

	self.timer 		 = false
	self.list_reward = false
	self.txt_countTimer = false
	-- self.banner 	 = false
	self.__timerId = false
	self.config = false
	self.serverData = false
	self.awardShowFlag = false
	self.lihuiDisplayObjPos = false
end

function ActFinalRewardView:ActFinalRewardView_refresh( ... )
	self:updatePanel()
	self:updateActTimeShow()
end

function ActFinalRewardView:_initUI()
	self.txt_countTitle = self.view:getChildAutoType("txt_countTitle")
	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.awardView = self.view:getChildAutoType("awardView")
	self.awardViewBg = self.awardView:getChildAutoType("n0")
	self.awardViewList = self.awardView:getChildAutoType("list")
	self.awardCloseBtn = self.awardView:getChildAutoType("viewCloseBtn")
	self.lihuiDisplay  		= self.view:getChildAutoType("lihuiDisplay")
	self.lihuiDisplayObj = BindManager.bindLihuiDisplay(self.lihuiDisplay)
	self.lihuiDisplayObjPos = self.lihuiDisplay:getPosition()
	self.awardShowCtrl = self.view:getController("awardShowCtrl")

	self.needNum = self.view:getChildAutoType("needNum")

	-- self.banner  = self.view:getChildAutoType("banner")
	self.btn_go  = self.view:getChildAutoType("btn_go")
	self.progressBar1  = self.view:getChildAutoType("progressBar1")
	self.progressBar2  = self.view:getChildAutoType("progressBar2")
	self.progressBar3  = self.view:getChildAutoType("progressBar3")
	self.progressBar4  = self.view:getChildAutoType("progressBar4")
	self.itemCell  = self.view:getChildAutoType("itemCell")
	self.itemcellObj = BindManager.bindItemCell(self.itemCell)

	self.actiVal  = self.view:getChildAutoType("actiVal")
	self.btn_rule  = self.view:getChildAutoType("btn_rule")

	for i=1,4 do
		self["actBtn"..i] = self.view:getChildAutoType("actBtn"..i)
		self["needactVal"..i] =  self.view:getChildAutoType("needactVal"..i)
	end
	
	--妹子
	-- self.banner:setURL("UI/MonthlyGiftBag/img_meiyue_banner.png")


	--问号
	self.btn_rule:addClickListener(function( ... )
		local info={}
		info['title']=Desc["help_StrTitle1"]
		info['desc']=Desc["help_StrDesc1"]
		ViewManager.open("GetPublicHelpView",info) 
	end)
	
	--前往
	self.btn_go:addClickListener(function( ... )
		ModuleUtil.openModule(ModuleId.ActFinalRewardView.id,true)
	end)

	--奖励控制器
	self.awardCloseBtn:addClickListener(function ( ... )
		if self.awardShowFlag then
			self.awardShowCtrl:setSelectedIndex(0)
			self.awardShowFlag = false
		else
			self.awardShowFlag = true
			self.awardShowCtrl:setSelectedIndex(1)
		end		
	end)

	self.awardViewList:setItemRenderer(function ( index,obj )
		local award = self.awardViewList._dataTemplate[index+1]
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = award})
		itemcell:setItemData(itemData)
	end)
	local num = ActFinalRewardModel:getSuipianNum(  )
    self.needNum:setText(num)
    self:ActFinalRewardView_refresh()
end

function ActFinalRewardView:updatePanel()
	self.config = ActFinalRewardModel:getShowConfig()
	
	--道具显示
	self.itemcellObj:setAmountVisible(false)
	self.itemcellObj:setData(self.config[1].item, 1, 3)

	--模型立绘
	local reource,offsetx,offsety,scane = ActFinalRewardModel:getModelId(  )
	self.lihuiDisplayObj:setMonsterData(reource,"stand")
	-- self.lihuiDisplayObj:setPosition(851,-68)
	self.lihuiDisplayObj:setPosition(self.lihuiDisplayObjPos.x+offsetx,self.lihuiDisplayObjPos.y+offsety)
	self.lihuiDisplayObj:setScale(scane/100,scane/100)
	-- self.lihuiDisplayObj:setScale(1,1)
	--进度 进度数值显示不平均 采用分段来实现
	local score = ActFinalRewardModel:getActiVal(self.config[1].item)
	local scoreArr = ActFinalRewardModel:getAllActVal()
	local maxScoreArr = {}
	-- local maxScore = ActFinalRewardModel:getMaxActVal()
	for i=1,#scoreArr do
		if i == 1 then
			self["progressBar"..i]:setMax(scoreArr[i])
			maxScoreArr[i] = scoreArr[i]
		else
			self["progressBar"..i]:setMax(scoreArr[i]-scoreArr[i-1])
			maxScoreArr[i] = scoreArr[i]-scoreArr[i-1]
		end
	end

	for i=1,#scoreArr do		
		if score>=scoreArr[i] then
			self["progressBar"..i]:setValue(maxScoreArr[i])
		else
			if i == 1 then
				self["progressBar"..i]:setValue(score)
			else
				self["progressBar"..i]:setValue(score-scoreArr[i-1])
			end
			
		end
	end

	if self.actiVal then
    	self.actiVal:setText(score)
	end
	
	--4个宝箱
	for i=1,4 do
		local receive =  ActFinalRewardModel:getDataReceive(  )
		local time = ActFinalRewardModel:getActiVal(self.config[i].item)
		local actid = ActFinalRewardModel:getActivityId( )
		self["needactVal"..i]:setText(self.config[i].time)
		self["actBtn"..i]:removeClickListener(88)
		self["actBtn"..i]:addClickListener(function( ... )
			if (not TableUtil.Exist(receive,self.config[i].id)) and time>=self.config[i].time then --次数达到
				local params = {}
				params.activityId = actid
				params.id = self.config[i].id
				params.onSuccess = function (res )
				end
		 		RPCReq.Activity_ElfFinal_ReceiveBox(params, params.onSuccess)
			else
				if self.awardShowFlag then
					self.awardShowFlag = false
					self.awardShowCtrl:setSelectedIndex(0)
				else
					self.awardShowFlag = true
					self.awardShowCtrl:setSelectedIndex(1)
					-- printTable(1,"测试",self.config[i].reward)
					self.awardViewList:setData(self.config[i].reward)
					local posx = self["actBtn"..i]:getX()
					if i>=1 and i<=3 then
					   self.awardViewList:setPivot(0.5,0.5,true)
					   self.awardViewBg:setPivot(0.5,0.5,true)
					   self.awardViewList:setX(posx+10)
					   self.awardViewBg:setX(posx+10)
					elseif i ==4 then
					--    self.awardViewList:setPivot(1,0.5,true)
					--    self.awardViewBg:setPivot(1,0.5,true)
					--    self.awardViewList:setX(posx+80)
					--    self.awardViewBg:setX(posx+80)
					self.awardViewList:setPivot(0.5,0.5,true)
					self.awardViewBg:setPivot(0.5,0.5,true)
					self.awardViewList:setX(posx+10)
					self.awardViewBg:setX(posx+10)
					end
					self.awardViewList:resizeToFit(#self.config[i].reward)
				end
			end
		end,88)

		--宝箱状态		
		if TableUtil.Exist(receive,self.config[i].id) then --已领
			self["actBtn"..i]:getController("statusCtrl"):setSelectedIndex(2)
		else --未领
			if (not TableUtil.Exist(receive,self.config[i].id)) and time>=self.config[i].time then --次数达到
				self["actBtn"..i]:getController("statusCtrl"):setSelectedIndex(1)
			else
				self["actBtn"..i]:getController("statusCtrl"):setSelectedIndex(0)
			end
			
		end
	end
end

--更新活动时间
function ActFinalRewardView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
    local actid = ActFinalRewardModel:getActivityId( )
	local status,timems = ActivityModel:getActStatusAndLastTime( actid)
	if status == 2 and timems == -1 then
		self.txt_countTimer:setText(Desc.activity_txt5)
		return
	end
	if status ==0 then
		self.txt_countTimer:setText(Desc.activity_txt13)
		return
	end

	if timems==0 then
		self.txt_countTimer:setText(Desc.activity_txt13)
		return
	end
	timems = timems/1000
	
	local function updateCountdownView(time)
		if time > 0 then
			local timeStr = TimeLib.GetTimeFormatDay(time,2)
			self.txt_countTimer:setText(timeStr)
		else
			self.txt_countTimer:setText(Desc.activity_txt18)
		end
	end
	updateCountdownView(timems)
	self.__timerId = TimeLib.newCountDown(timems, function(time)
		updateCountdownView(time)
	end, function()
		self.txt_countTimer:setText(Desc.activity_txt4) -- TODO
	end, false, false, false)
end

function ActFinalRewardView:_exit()
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
end

return ActFinalRewardView