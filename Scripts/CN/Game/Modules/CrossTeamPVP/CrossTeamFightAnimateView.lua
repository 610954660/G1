--Date :2020-12-10
--Author : wyz
--Desc : 组队竞技 匹配成功

local CrossTeamFightAnimateView,Super = class("CrossTeamFightAnimateView", Window)

function CrossTeamFightAnimateView:ctor()
	--LuaLog("CrossTeamFightAnimateView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamFightAnimateView"
	self._rootDepth = LayerDepth.PopWindow
	self.timer = false
	self.resetFlag = false -- 标记倒计时是否已经到零
end

function CrossTeamFightAnimateView:_initEvent( )
	
end

function CrossTeamFightAnimateView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamFightAnimateView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_ok = viewNode:getChildAutoType('btn_ok')--GButton
	self.btn_reset = viewNode:getChildAutoType('btn_reset')--GButton
	self.checkAnimate = viewNode:getController('checkAnimate')--Controller
	self.myArrayItem1 = viewNode:getChildAutoType('myArrayItem1')--myArrayItem
		self.myArrayItem1.danIconLoader = viewNode:getChildAutoType('myArrayItem1/danIconLoader')--GLoader
		self.myArrayItem1.heroCell = viewNode:getChildAutoType('myArrayItem1/heroCell')--GButton
		self.myArrayItem1.iconLoader = viewNode:getChildAutoType('myArrayItem1/iconLoader')--GLoader
		self.myArrayItem1.txt_danName = viewNode:getChildAutoType('myArrayItem1/txt_danName')--GRichTextField
		self.myArrayItem1.txt_integral = viewNode:getChildAutoType('myArrayItem1/txt_integral')--GTextField
		self.myArrayItem1.txt_playerName = viewNode:getChildAutoType('myArrayItem1/txt_playerName')--GTextField
		self.myArrayItem1.txt_power = viewNode:getChildAutoType('myArrayItem1/txt_power')--GTextField
	self.myArrayItem2 = viewNode:getChildAutoType('myArrayItem2')--myArrayItem
		self.myArrayItem2.danIconLoader = viewNode:getChildAutoType('myArrayItem2/danIconLoader')--GLoader
		self.myArrayItem2.heroCell = viewNode:getChildAutoType('myArrayItem2/heroCell')--GButton
		self.myArrayItem2.iconLoader = viewNode:getChildAutoType('myArrayItem2/iconLoader')--GLoader
		self.myArrayItem2.txt_danName = viewNode:getChildAutoType('myArrayItem2/txt_danName')--GRichTextField
		self.myArrayItem2.txt_integral = viewNode:getChildAutoType('myArrayItem2/txt_integral')--GTextField
		self.myArrayItem2.txt_playerName = viewNode:getChildAutoType('myArrayItem2/txt_playerName')--GTextField
		self.myArrayItem2.txt_power = viewNode:getChildAutoType('myArrayItem2/txt_power')--GTextField
	self.myArrayItem3 = viewNode:getChildAutoType('myArrayItem3')--myArrayItem
		self.myArrayItem3.danIconLoader = viewNode:getChildAutoType('myArrayItem3/danIconLoader')--GLoader
		self.myArrayItem3.heroCell = viewNode:getChildAutoType('myArrayItem3/heroCell')--GButton
		self.myArrayItem3.iconLoader = viewNode:getChildAutoType('myArrayItem3/iconLoader')--GLoader
		self.myArrayItem3.txt_danName = viewNode:getChildAutoType('myArrayItem3/txt_danName')--GRichTextField
		self.myArrayItem3.txt_integral = viewNode:getChildAutoType('myArrayItem3/txt_integral')--GTextField
		self.myArrayItem3.txt_playerName = viewNode:getChildAutoType('myArrayItem3/txt_playerName')--GTextField
		self.myArrayItem3.txt_power = viewNode:getChildAutoType('myArrayItem3/txt_power')--GTextField
	self.otherArrayItem1 = viewNode:getChildAutoType('otherArrayItem1')--myArrayItem
		self.otherArrayItem1.danIconLoader = viewNode:getChildAutoType('otherArrayItem1/danIconLoader')--GLoader
		self.otherArrayItem1.heroCell = viewNode:getChildAutoType('otherArrayItem1/heroCell')--GButton
		self.otherArrayItem1.iconLoader = viewNode:getChildAutoType('otherArrayItem1/iconLoader')--GLoader
		self.otherArrayItem1.txt_danName = viewNode:getChildAutoType('otherArrayItem1/txt_danName')--GRichTextField
		self.otherArrayItem1.txt_integral = viewNode:getChildAutoType('otherArrayItem1/txt_integral')--GTextField
		self.otherArrayItem1.txt_playerName = viewNode:getChildAutoType('otherArrayItem1/txt_playerName')--GTextField
		self.otherArrayItem1.txt_power = viewNode:getChildAutoType('otherArrayItem1/txt_power')--GTextField
	self.otherArrayItem2 = viewNode:getChildAutoType('otherArrayItem2')--myArrayItem
		self.otherArrayItem2.danIconLoader = viewNode:getChildAutoType('otherArrayItem2/danIconLoader')--GLoader
		self.otherArrayItem2.heroCell = viewNode:getChildAutoType('otherArrayItem2/heroCell')--GButton
		self.otherArrayItem2.iconLoader = viewNode:getChildAutoType('otherArrayItem2/iconLoader')--GLoader
		self.otherArrayItem2.txt_danName = viewNode:getChildAutoType('otherArrayItem2/txt_danName')--GRichTextField
		self.otherArrayItem2.txt_integral = viewNode:getChildAutoType('otherArrayItem2/txt_integral')--GTextField
		self.otherArrayItem2.txt_playerName = viewNode:getChildAutoType('otherArrayItem2/txt_playerName')--GTextField
		self.otherArrayItem2.txt_power = viewNode:getChildAutoType('otherArrayItem2/txt_power')--GTextField
	self.otherArrayItem3 = viewNode:getChildAutoType('otherArrayItem3')--myArrayItem
		self.otherArrayItem3.danIconLoader = viewNode:getChildAutoType('otherArrayItem3/danIconLoader')--GLoader
		self.otherArrayItem3.heroCell = viewNode:getChildAutoType('otherArrayItem3/heroCell')--GButton
		self.otherArrayItem3.iconLoader = viewNode:getChildAutoType('otherArrayItem3/iconLoader')--GLoader
		self.otherArrayItem3.txt_danName = viewNode:getChildAutoType('otherArrayItem3/txt_danName')--GRichTextField
		self.otherArrayItem3.txt_integral = viewNode:getChildAutoType('otherArrayItem3/txt_integral')--GTextField
		self.otherArrayItem3.txt_playerName = viewNode:getChildAutoType('otherArrayItem3/txt_playerName')--GTextField
		self.otherArrayItem3.txt_power = viewNode:getChildAutoType('otherArrayItem3/txt_power')--GTextField
	self.txt_countTimes = viewNode:getChildAutoType('txt_countTimes')--GRichTextField
	self.txt_countTimesTitle = viewNode:getChildAutoType('txt_countTimesTitle')--GTextField
	self.txt_timer = viewNode:getChildAutoType('txt_timer')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamFightAnimateView
	--Do not modify above code-------------
end

function CrossTeamFightAnimateView:_initUI( )
	CrossTeamPVPModel:reqMatch()
	CrossTeamPVPModel.interfaceTypeFlag = true
	self:_initVM()
	self:initClickListener()
	-- self:CrossTeamFightAnimateView_refreshPanel()
end

function CrossTeamFightAnimateView:CrossTeamFightAnimateView_refreshPanel()
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
	self:refreshPanel()
end

function CrossTeamFightAnimateView:refreshPanel()
	-- self:setAnimation()
	self:setMyTeamInfo()
	self:setOtherTeamInfo()
	self:setCountTimes()
	self:updateCountTimer()
end

-- 剩余重新匹配次数
function CrossTeamFightAnimateView:setCountTimes()
	self.txt_countTimes:setText(CrossTeamPVPModel:getResidueNum())
end

-- 设置动画
function CrossTeamFightAnimateView:setAnimation()
	local time 	= 0.3
	local node1 = self.fightLeft:displayObject()
	local initX = self.leftpos:displayObject():getPositionX()
	local arr = {}
	table.insert(arr,cc.DelayTime:create(0.3))
	table.insert(arr,cc.EaseOut:create(
		cc.MoveTo:create(time,cc.p(initX,node1:getPositionY())),
		time
	))
	table.insert(arr,cc.CallFunc:create(function()
		SpineUtil.createSpineObj(self.spineNode, vertex2(3,0), "ty_vs_baozha", "Spine/ui/CrossPVP", "tianyushilian_texiao", "tianyushilian_texiao",false)
		SpineUtil.createSpineObj(self.spineNode, vertex2(0,0), "ty_vs_xunhuan", "Spine/ui/CrossPVP", "tianyushilian_texiao", "tianyushilian_texiao",true)
		SpineUtil.createSpineObj(self.spineNode1, vertex2(0,0), "ty_ppcg", "Spine/ui/CrossPVP", "tianyushilian_texiao", "tianyushilian_texiao",true)
	end))
	node1:runAction(cc.Sequence:create(arr))

	local node2 = self.fightRight:displayObject()
	local initX = self.rightpos:displayObject():getPositionX()
	local arr1 = {}
	table.insert(arr1,cc.DelayTime:create(0.3))
	table.insert(arr1,cc.EaseOut:create(
		cc.MoveTo:create(time,cc.p(initX,node1:getPositionY())),
		time
	))
	table.insert(arr1,cc.DelayTime:create(0.1))
	table.insert(arr1,cc.CallFunc:create(function()
		-- self:closeView()
		-- CrossPVPModel:fightBegin(self._args)
		self.checkAnimate:setSelectedIndex(1)
		self:updateCountTimer()
	end))
	node2:runAction(cc.Sequence:create(arr1))

end

function CrossTeamFightAnimateView:initClickListener()
	-- 重新匹配
	self.btn_reset:removeClickListener()
	self.btn_reset:addClickListener(function()
		if CrossTeamPVPModel:getResidueNum() == 0 then
			RollTips.show(Desc.CrossTeamPVP_refreshTipsTimes)
			return
		end
		if self.resetFlag then
			RollTips.show(Desc.CrossTeamPVP_str4)
			return
		end
		ViewManager.open("CrossTeamPVPMatchView")
		ViewManager.close("CrossTeamFightAnimateView")
	end)

	-- 确定
	self.btn_ok:removeClickListener()
	self.btn_ok:addClickListener(function() 
		CrossTeamPVPModel:reqAdjust()
		ViewManager.open("CrossTeamPVPSquadSortView")
		ViewManager.close("CrossTeamFightAnimateView")
	end)

end

-- 倒计时
function CrossTeamFightAnimateView:updateCountTimer()
	local serverTime = ServerTimeModel:getServerTime()
	local reqTime  	= CrossTeamPVPModel.matchInfo.endMs or 0
	local limitTime  = math.floor(reqTime/1000) - serverTime
	self.txt_timer:setText(limitTime)
	local onCountDown = function(dt) 
		limitTime = limitTime - dt 
		if not tolua.isnull(self.txt_timer) then
			self.txt_timer:setText(math.floor(limitTime))
		end
		if limitTime <= 0 then
			self.resetFlag = true
			if not tolua.isnull(self.txt_timer) then
				self.txt_timer:setText(0)
			end
			Scheduler.unschedule(self.timer)
			self.timer = false
			-- 结束后须直接跳转进入战斗 -- 后续添加
		end
	end

	self.timer = Scheduler.schedule(function(dt)
		onCountDown(dt)
    end,0.1)
end

-- 设置我方队员信息
function CrossTeamFightAnimateView:setMyTeamInfo()
	local obj = self.view
	local myTeamInfo = CrossTeamPVPModel.matchInfo.attacker or {}
	for i =1,3 do
		local data = myTeamInfo[i]
		if data then
			local item = obj:getChildAutoType("myArrayItem" ..i)
			local heroCell = BindManager.bindPlayerCell(item:getChildAutoType("heroCell"))
			local txt_playerName = item:getChildAutoType("txt_playerName")
			local txt_integral = item:getChildAutoType("txt_integral")
			local txt_power = item:getChildAutoType("txt_power")
			local danIconLoader	= item:getChildAutoType("danIconLoader")
			local txt_danName 	= item:getChildAutoType("txt_danName")
			local iconLoader 	= item:getChildAutoType("iconLoader")
			iconLoader:setURL(PathConfiger.getHeroCardex(data.head))

			local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(data.score or 0) 
			-- txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
			txt_danName:setText(danInfo.name)
			danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));
			heroCell:setData(data.head,data.level,data.playerId)
			txt_playerName:setText(data.name)
			txt_integral:setText(data.score or 0)
			txt_power:setText(StringUtil.transValue(data.fight or 0))
		end	
	end
end

-- 设置敌方队员信息
function CrossTeamFightAnimateView:setOtherTeamInfo()
	local obj = self.view
	local otherTeamInfo = CrossTeamPVPModel.matchInfo.defender or {}
	for i =1,3 do
		local data = otherTeamInfo[i]
		if data then
			local item = obj:getChildAutoType("otherArrayItem" ..i)
			local heroCell = BindManager.bindPlayerCell(item:getChildAutoType("heroCell"))
			local txt_playerName = item:getChildAutoType("txt_playerName")
			local txt_integral = item:getChildAutoType("txt_integral")
			local txt_power = item:getChildAutoType("txt_power")
			local danIconLoader	= item:getChildAutoType("danIconLoader")
			local txt_danName 	= item:getChildAutoType("txt_danName")
			local iconLoader 	= item:getChildAutoType("iconLoader")
			iconLoader:setURL(PathConfiger.getHeroCardex(data.head))
			local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(data.score or 0) 
			-- txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
			txt_danName:setText(danInfo.name)
			danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));

			heroCell:setData(data.head,data.level,data.playerId)
			txt_playerName:setText(data.name)
			txt_integral:setText(data.score or 0)
			txt_power:setText(StringUtil.transValue(data.fight or 0))
		end
	end
end


function CrossTeamFightAnimateView:_exit()
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
end


return CrossTeamFightAnimateView