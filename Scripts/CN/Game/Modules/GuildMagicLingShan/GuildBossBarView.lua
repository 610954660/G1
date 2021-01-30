-- added by wyz 
-- 公会boss进度条界面

local GuildBossBarView = class("GuildBossBarView",Window)

function GuildBossBarView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildBossBarView"
	self.bossHurLevel=0
	self.myAllHurtval = 0
end

function GuildBossBarView:_initUI()
    self.bossBar = self.view:getChildAutoType("bossBar")
    self.hpBarYellowRTL = self.bossBar:getChildAutoType("hpBarYellowRTL")
    self.hpBarRTL   = self.bossBar:getChildAutoType("hpBarRTL")
    self.valueText  = self.bossBar:getChildAutoType("valueText")
    self.iconFrame  = self.bossBar:getChildAutoType("iconFrame")
    self.icon       = self.bossBar:getChildAutoType("icon")
    self.hpBarYellow = self.bossBar:getChildAutoType("hpBarYellow")
    self.hpBar   = self.bossBar:getChildAutoType("hpBar")
	self.sliderFlipCtrl = self.bossBar:getController("sliderFlipCtrl")  -- 进度条填充方向 0 从左往右 1 从右往左
	self.barRageMLS = self.bossBar:getChildAutoType("barRageMLS") 	-- 魔灵山玩法添加boss怒气值
	self.playTypeCtrl = self.bossBar:getController("playTypeCtrl") 	-- 0 其它玩法 1 魔灵山玩法
	self.playTypeCtrl:setSelectedIndex(0)
end

function GuildBossBarView:_initEvent()

end

--设置boss血条 (狩猎场 从左往右填充)
function GuildBossBarView:setBossBar(myAllHurt)
    self.sliderFlipCtrl:setSelectedIndex(0)
	local boosRewards= DynamicConfigData.t_bossReward[500]
	local maxValue=0
	local minValue=0
	local newLevel=0
	for k, rewards in pairs(boosRewards) do
		newLevel=newLevel+1
		minValue=rewards.damageMin
		if k<#boosRewards then
			maxValue=rewards.damageMax
		end
		if  rewards.damageMin<myAllHurt and myAllHurt<rewards.damageMax then
			break
		end

	end
	if self.bossHurLevel~=newLevel then
		self.bossBar:getChildAutoType("hpBar"):setValue(0)
		self.bossBar:getChildAutoType("hpBarYellow"):setValue(0)
		self.bossHurLevel=newLevel
		self.bossBar:getChildAutoType("icon"):setURL(PathConfiger.getItemIcon(boosRewards[self.bossHurLevel].rewardIcon))
	end
	local barLength=maxValue-minValue
	local barValue=false
	
	
	if barLength<0 then
		barLength=maxValue
		barValue=myAllHurt
	else
		barValue=(myAllHurt-minValue)/barLength
	end
	self.bossBar:getChildAutoType("valueText"):setText(myAllHurt.."/"..maxValue)
	self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarYellow"),barValue*100,0.15)
    BattleManager:schedule(function()
			local bar =self.bossBar:getChildAutoType("hpBar")	
			self:tweenToBarVaue(bar,barValue*100,0.15)
	end,0.3,1)
end




-- 血荆之渊boss进度条 从左往右填充
function GuildBossBarView:setBossBar4(myAllHurt,hpMax)

	self.sliderFlipCtrl:setSelectedIndex(0)
	--self.playTypeCtrl:setSelectedIndex(1)
	local barValue=myAllHurt/hpMax
	print(33,"myAllHurt",myAllHurt)
	self.bossBar:getChildAutoType("valueText"):setText(myAllHurt)
	self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarYellow"),barValue*100,0.15)
	BattleManager:schedule(function()
			local bar =self.bossBar:getChildAutoType("hpBar")
			self:tweenToBarVaue(bar,barValue*100,0.15)
		end,0.3,1)
end

-- 次元裂缝boss进度条 从左往右填充
function GuildBossBarView:setBossBar2(myAllHurt,hpMax)
    self.sliderFlipCtrl:setSelectedIndex(0)
	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local hpGroup=viewInfo.window.ctlView["BattleSecnesView"].hpGroup or {3000,5000,8000,11000,20000,50000}
	local topValue=viewInfo.window.ctlView["BattleSecnesView"].topValue or 999999
	local maxValue=0
	local minValue=0
	local newLevel=0
	self.icon:setAutoSize(true)
	
	for k, damage in pairs(hpGroup) do
		if myAllHurt>damage then
			minValue=damage
		end
		if myAllHurt<damage then
			maxValue=damage
			break;
		end
		
	end
	if maxValue==0 then
		maxValue=topValue
	end
	
	local barLength=maxValue-minValue
	local barValue=false

	if barLength<0 then
		barLength=maxValue
		barValue=myAllHurt
	else
		barValue=(myAllHurt-minValue)/barLength
	end
	
	--
	self.bossBar:getChildAutoType("valueText"):setText(myAllHurt)
	self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarYellow"),barValue*100,0.15)
	BattleManager:schedule(function()
			local bar =self.bossBar:getChildAutoType("hpBar")
			self:tweenToBarVaue(bar,barValue*100,0.15)
		end,0.3,1)
end


-- 魔灵山boss进度条 从右往左填充
function GuildBossBarView:setBossBar3(myAllHurt,hpMax)
	self.playTypeCtrl:setSelectedIndex(1)
	self.sliderFlipCtrl:setSelectedIndex(1)
	self.bossBar:getChildAutoType("icon"):setURL("Icon/guild/gulidMLSBoss.png")
	self.bossBar:getChildAutoType("icon"):setScale(3,3)
	local maxValue = hpMax or ModelManager.GuildMLSModel.bossMaxHp   -- 最大血量
	local barValue = maxValue - myAllHurt
	barValue = barValue < 0 and 0 or barValue
	self.bossBar:getChildAutoType("hpBarYellowRTL"):setMax(maxValue)
	self.bossBar:getChildAutoType("hpBarRTL"):setMax(maxValue)
	self.bossBar:getChildAutoType("valueText"):setText(barValue)
	self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarRTL"),barValue,0.15)
    BattleManager:schedule(function()
			local bar =self.bossBar:getChildAutoType("hpBarYellowRTL")	
			self:tweenToBarVaue(bar,barValue,0.15)
	end,0.3,1)
end

--节日boss 从右到左
function GuildBossBarView:setBossBar5(myAllHurt,hpMax)
	self.playTypeCtrl:setSelectedIndex(0)
	self.sliderFlipCtrl:setSelectedIndex(1)
	local config = DynamicConfigData.t_HolidayBOSS[1]
	local url = ItemConfiger.getItemIconByCode(config.item[1].code)
	self.bossBar:getChildAutoType("icon"):setURL(url)
	self.bossBar:getChildAutoType("icon"):setScale(1.5,1.5)
	local everyHp = hpMax/DynamicConfigData.t_HolidayBOSS[1].HpNum
	self.bossBar:getChildAutoType("num"):setText(math.floor(myAllHurt/everyHp))

	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local hpGroup=viewInfo.window.ctlView["BattleSecnesView"].hpGroup or {3000,5000,8000,11000,20000,50000}
	local topValue=viewInfo.window.ctlView["BattleSecnesView"].topValue or 999999
	self.bossBar:getChildAutoType("hpBarRTL"):setMax(hpGroup[1])
	self.bossBar:getChildAutoType("hpBarRTL"):setValue(hpGroup[1])
	self.bossBar:getChildAutoType("hpBarRTL"):setMin(0)
	self.bossBar:getChildAutoType("hpBarYellowRTL"):setMax(hpGroup[1])
	self.bossBar:getChildAutoType("hpBarYellowRTL"):setValue(hpGroup[1])
	self.bossBar:getChildAutoType("hpBarYellowRTL"):setMin(0)

	local maxValue = hpMax
	local barValue = maxValue - myAllHurt
	barValue = barValue < 0 and 0 or barValue
	local maxFunc = function ( ... )
		if barValue<= 0 then
			return 
		end
		if tolua.isnull(self.bossBar) then
			return
		end
		self.bossBar:getChildAutoType("hpBarRTL"):setValue(hpGroup[1])
		self.bossBar:getChildAutoType("hpBarYellowRTL"):setValue(hpGroup[1])
	end

	if myAllHurt/hpGroup[1]>1 then
		local lastVal = myAllHurt%hpGroup[1]
		local roundNum = math.floor( myAllHurt/hpGroup[1] )
		if roundNum>= 5 then
			roundNum = 5
		end
		self.bossBar:getChildAutoType("valueText"):setText(barValue)
		local count = 0
		local function func1()
			count = count + 1
			if tolua.isnull(self.bossBar) then
				return
			end
			self.bossBar:getChildAutoType("hpBarRTL"):setValue(hpGroup[1])
			self.bossBar:getChildAutoType("hpBarYellowRTL"):setValue(hpGroup[1])
			print(1,"开始动作 次数",count)
			if count>roundNum then
				return
			end
			if tolua.isnull(self.bossBar) then
				print(1,"被return")
				return
			end
			self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarRTL"),0,0.3)
			BattleManager:schedule(function()
					local bar =self.bossBar:getChildAutoType("hpBarYellowRTL")
					self:tweenToBarVaue(bar,0,0.3,maxFunc)
				end,0.15,1)
		end
		-- GuildBossBarView.func = func1
		-- func1()
		BattleManager:schedule(function()
			func1()
		end,0.5,roundNum-1)
		func1()
	else
		local showValue = hpGroup[1] - myAllHurt
		showValue = showValue < 0 and 0 or showValue
		self.bossBar:getChildAutoType("valueText"):setText(barValue)
		self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarRTL"),showValue,0.3)
		BattleManager:schedule(function()
				if tolua.isnull(self.bossBar) then
					return
				end 
				local bar =self.bossBar:getChildAutoType("hpBarYellowRTL")
				self:tweenToBarVaue(bar,showValue,0.3)
			end,0.15,1)
	end
end

--设置boss怒气值
function GuildBossBarView:setRageBar(value)
	self.barRageMLS:setMax(10000)
	local ll = (value/10000)*100
	self:tweenToBarVaue(self.barRageMLS,value,0.15)
end

--血条缓动效果
function GuildBossBarView:tweenToBarVaue(bar,value,time,onComplete)
	local function onUpdate(value)
		bar:setValue(value)
	end	
	if not onComplete then
		onComplete = function()
		end
	end
	TweenUtil.toDouble(bar, {onUpdate = onUpdate,onComplete=onComplete,from = bar:getValue(), to = value, time = time, ease = EaseType.SineOut})
end

return GuildBossBarView