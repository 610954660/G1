---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-03-20 15:27:13
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BarController  战斗中所有血条护盾条怒气条等管理类
local BarController =class("BarController")
local CameraController=require "Game.Modules.Battle.Effect.CameraController"

function BarController:ctor(barGroup,baseData,HeroCell)
	self.packName  = "UIPublic"
	self.index=false
	if baseData then
		self.baseData=baseData
		self.maxHp=baseData.hpMax
		self.index=baseData.id
		self.barParent=barGroup.barParent
		self.shidBar=barGroup.shidBar

		local viewInfo=ViewManager.getViewInfo("BattleBeginView")
		self.hpProgressBar=barGroup.hpProgressBar
		self.hpBarYellow=barGroup.hpBarYellow



		self.angerBar=barGroup.angerBar
		self.isBoos=barGroup.heroType==2  --1是英雄 2 是boss

		self.__rage=0
		self.shiedValue=0
		self.scheduleID=false
		self.bossHurLevel=0

		self.maxShied=0
		self.tweenList={}
		self.hpTipList={}
		self.hpTipCount=0
		self.heroCell=HeroCell
	
		--if viewInfo then
			--self.screenView=viewInfo.window.ctlView["BattleSecnesView"].view
		--else
			--self.screenView=CameraController.getScreenView()
		--end
		self.screenView=CameraController.getScreenView()
		
	end
	self.allHurtTip=BattleModel:getMapPoint()["allHurtTip"]
	
	self.curTranSition=false
	
end

--设置护盾  hurt血条真实伤害
function BarController:setShiedBar(value,eventTime)

	if value==0 then
		return 
	end	
    if eventTime then
		local shiedRollTip=self:createHpType(4)
		shiedRollTip:getChildAutoType("add_value"):setText("s"..value)
	end

	
	if value>0 then
		self.maxShied=self.maxShied+value
	end
	
	self.shiedValue=self.shiedValue+value
	self.shidBar:setVisible(self.shiedValue>0)
	if self.shiedValue<=0 then
		self.maxShied=0
		return 
	end
	local function onUpdate(value)
		self.shidBar:setValue(value)
	end
	TweenUtil.toDouble(self.shidBar, {onUpdate = onUpdate,from = self.shidBar:getValue(), to = (self.shiedValue/self.maxShied)*100, time = 0.2, ease = EaseType.SineOut})


end


--设置血条
function BarController:setHpBar(lefthp,notTween)
	if self.baseData.myhurt<0 then
		self.baseData.myhurt=0
	end
	if self.baseData.myhurt>self.baseData.hpMax then
		self.baseData.myhurt=self.baseData.hpMax
	end
	
	if notTween then
		self.hpProgressBar:setValue((lefthp/self.maxHp)*100)
		self.hpBarYellow:setValue((lefthp/self.maxHp)*100)
	else
		self:tweenToBarVaue(self.hpProgressBar,(lefthp/self.maxHp)*100,0.15)
		BattleManager:schedule(function()
		        self:tweenToBarVaue(self.hpBarYellow,self.hpProgressBar:getValue(),1.5)
		end,1,1)
	end
	--print(086,self.hpBarYellow:getValue(),"???!!")

end

--设置血条
function BarController:setYellowBar(lefthp,notTween)
	if self.baseData.myhurt<0 then
		self.baseData.myhurt=0
	end
	if self.baseData.myhurt>self.baseData.hpMax then
		self.baseData.myhurt=self.baseData.hpMax
	end

	if notTween then
		self.hpBarYellow:setValue((lefthp/self.maxHp)*100)
	else
		--BattleManager:schedule(function()
				--self:tweenToBarVaue(self.hpBarYellow,(lefthp/self.maxHp)*100,0.3)
		--end,0.1,1)
		self:tweenToBarVaue(self.hpBarYellow,(lefthp/self.maxHp)*100,0.5)
	end
	--print(086,self.hpBarYellow:getValue(),"???!!")
end

function BarController:setSkillTip()
	local hpPos=self.heroCell.hpPos
end

--设置boss血条
function BarController:setBossBar(hurt)
	-- local boosRewards= DynamicConfigData.t_bossReward[500]
	-- local maxValue=0
	-- local minValue=0
	-- local newLevel=0
	-- for k, rewards in pairs(boosRewards) do
	-- 	newLevel=newLevel+1
	-- 	minValue=rewards.damageMin
	-- 	if k<#boosRewards then
	-- 		maxValue=rewards.damageMax
	-- 	end
	-- 	if  rewards.damageMin<hurt and hurt<rewards.damageMax then
	-- 		break
	-- 	end

	-- end
	-- if self.bossHurLevel~=newLevel then
	-- 	self.bossBar:getChildAutoType("hpBar"):setValue(0)
	-- 	self.bossBar:getChildAutoType("hpBarYellow"):setValue(0)
	-- 	self.bossHurLevel=newLevel
	-- 	self.bossBar:getChildAutoType("icon"):setURL(PathConfiger.getItemIcon(boosRewards[self.bossHurLevel].rewardIcon))
	-- end
	-- local barLength=maxValue-minValue
	-- local barValue=false
	
	
	-- if barLength<0 then
	-- 	barLength=maxValue
	-- 	barValue=hurt
	-- else
	-- 	barValue=(hurt-minValue)/barLength
	-- end
	-- self.bossBar:getChildAutoType("valueText"):setText(hurt.."/"..maxValue)
	-- self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarYellow"),barValue*100,0.15)
    -- BattleManager:schedule(function()
	-- 		local bar =self.bossBar:getChildAutoType("hpBar")	
	-- 		self:tweenToBarVaue(bar,barValue*100,0.15)
	-- end,0.3,1)
	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local GuildBossBarView=viewInfo.window.ctlView["GuildBossBarView"]
	GuildBossBarView:setBossBar(hurt)

end


function BarController:setBossBar2(hurt,hpMax)
	-- local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	-- local hpGroup=viewInfo.window.ctlView["BattleSecnesView"].hpGroup or {3000,5000,8000,11000,20000,50000}
	-- local topValue=viewInfo.window.ctlView["BattleSecnesView"].topValue or 999999

	-- local maxValue=0
	-- local minValue=0
	-- local newLevel=0
	
	-- --printTable(086,hpGroup,"hpGroup",hurt)
	-- for k, damage in pairs(hpGroup) do
	-- 	if hurt>damage then
	-- 		minValue=damage
	-- 	end
	-- 	if hurt<damage then
	-- 		maxValue=damage
	-- 		break;
	-- 	end
		
	-- end
	-- if maxValue==0 then
	-- 	maxValue=topValue
	-- end
	
	-- local barLength=maxValue-minValue
	-- local barValue=false

	-- if barLength<0 then
	-- 	barLength=maxValue
	-- 	barValue=hurt
	-- else
	-- 	barValue=(hurt-minValue)/barLength
	-- end
	-- self.bossBar:getChildAutoType("valueText"):setText(hurt)
	-- self:tweenToBarVaue(self.bossBar:getChildAutoType("hpBarYellow"),barValue*100,0.15)
	-- BattleManager:schedule(function()
	-- 		local bar =self.bossBar:getChildAutoType("hpBar")
	-- 		self:tweenToBarVaue(bar,barValue*100,0.15)
	-- 	end,0.3,1)
	-- --self.bossBar:getChildAutoType("icon"):setURL("UI/Guild/boss1.png")

	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local GuildBossBarView=viewInfo.window.ctlView["GuildBossBarView"]
	GuildBossBarView:setBossBar2(hurt,hpMax)
end


function BarController:setBossBar3(hurt,hpMax)
	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local GuildBossBarView=viewInfo.window.ctlView["GuildBossBarView"]
	GuildBossBarView:setBossBar3(hurt,hpMax)
	--local bossBarGroup = viewInfo.window.ctlView["GuildBossBarView"]
	--self.bossBar=bossBarGroup.bossBar
end

function BarController:setBossBar4(hurt,hpMax)
	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local GuildBossBarView=viewInfo.window.ctlView["GuildBossBarView"]
	GuildBossBarView:setBossBar4(hurt,hpMax)
end


function BarController:setBossBar5(hurt,hpMax)
	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	local GuildBossBarView=viewInfo.window.ctlView["GuildBossBarView"]
	GuildBossBarView:setBossBar5(hurt,hpMax)
end


--设置怒气值
function BarController:setRageBar(value)

	--if self.index==112 then
		--print(5656,value,"112 加")
	--end
	self.__rage=self.__rage+value
	if self.__rage<0 then
		self.__rage=0
	end
	-- 设置boss怒气值
	if self.isBoos then
		local viewInfo = ViewManager.getViewInfo("BattleBeginView")
		local GuildBossBarView=viewInfo.window.ctlView["GuildBossBarView"]
		GuildBossBarView:setRageBar(self.__rage)
	end
	if self.index==112 then
       --print(5656,self.__rage,value,"======>self.__rage")
	end
	self:tweenToBarVaue(self.angerBar,(self.__rage/10000)*100,0.15)
	
	
end


--血条缓动效果
function BarController:tweenToBarVaue(bar,value,time)
	
	local function onUpdate(value)
		bar:setValue(value)
	end	
	TweenUtil.toDouble(bar, {onUpdate = onUpdate,from = bar:getValue(), to = value, time = time, ease = EaseType.SineOut})
end


function BarController:hideAllBar()
	if not tolua.isnull(self.barParent) then
		self.barParent:setVisible(false)
	end
end  

function BarController:showAllBar()
	if not tolua.isnull(self.barParent) then
		self.barParent:setVisible(not self.isBoos)
	end
end

--创建总伤害特效
function BarController:createAllHurt(value,finished)
	local valueStr=tostring(math.abs(value))
	
	if not self.allHurtTip then	
        return
		--self.allHurtTip=FGUIUtil.createObjectFromURL(self.packName,'allHurHp')--总伤害特效
		--self.allHurtTip.Skeleton=SpineUtil.createSpineObj(self.allHurtTip,Vector2(130,15),nil,PathConfiger.getSettlementRoot(),"Ef_zongshanghai")
		--CameraController.getScreenView():addChild(self.allHurtTip)
	end
	
	
	self.allHurtTip:setVisible(value<0)
	local allValue= self.allHurtTip:getChildAutoType("allValue")
	local add_valus_list= self.allHurtTip:getChildAutoType("add_valus_list")

	self.allHurtTip:setTitle("z"..valueStr)
	allValue:setText("z"..valueStr)
	add_valus_list:setText(valueStr)
	BattleManager:schedule(function()
			self.allHurtTip.Skeleton:setAnimation(0, "animation", false)
	end,0.25,1)
	self.allHurtTip:getTransition("t_hp"):play(function(context)
			if finished then
				finished();
			end
	end)
end


--根据类型创建对应飘雪动效
function BarController:createHpType(type,finished)
	local hpTip=false
	self.hpTipCount=self.hpTipCount+1
	local hpPos=self.heroCell:getModelHungPos()
    hpPos={x=hpPos.x-50,y=hpPos.y-50}
	local zIndex=self.heroCell.zIndex
	local eventTime=self.hpTipCount
	local offsetX=0
	if eventTime%2==0 then
		offsetX=-1.2
	else
		offsetX=1.2
	end
	local pos_x=hpPos.x+0*(eventTime-1)+math.random(15,30)*offsetX

	if type==1 then
		hpTip= FGUIUtil.createObjectFromURL(self.packName,'subHp')--普通伤害
		self.screenView:addChild(hpTip)
		--local pos_x=hpPos.x+0*(eventTime-1)+math.random(30,50)*offsetX
		hpTip:setPosition(pos_x,hpPos.y-10*(eventTime-1))
		
	end
	if type==2 then
		hpTip= FGUIUtil.createObjectFromURL(self.packName,'critAnim')--暴击伤害
		self.screenView:addChild(hpTip)
		hpTip:setPosition(hpPos.x+0*(eventTime-1),hpPos.y-0*(eventTime-1))
	end
	if type==3 then
		hpTip= FGUIUtil.createObjectFromURL(self.packName,'cureHp')--回复血量
		self.screenView:addChild(hpTip)
		hpTip:setPosition(hpPos.x+0*(eventTime-1),hpPos.y-40*(eventTime-1))
		--print(0866,eventTime,"hpTipCount",self,self.index)
	end
	if type==4 then
		hpTip= FGUIUtil.createObjectFromURL(self.packName,'sheidAnim')--护盾值
		self.screenView:addChild(hpTip)
		hpTip:setPosition(hpPos.x+0*(eventTime-1),hpPos.y-15*(eventTime-1))
		zIndex=zIndex+1
	end
	if type==5 then
		hpTip= FGUIUtil.createObjectFromURL(self.packName,'critCureHp')--回血暴击
		self.screenView:addChild(hpTip)
		hpTip:setPosition(hpPos.x+0*(eventTime-1),hpPos.y-40*(eventTime-1))
	end
	
	hpTip:setSortingOrder(zIndex)
	hpTip:setVisible(not __LJJ_BattleTest__)
	local c1=hpTip:getTransition("t_hp")
	--local tipIndex=table.getn(self.hpTipList)+1	
	c1:play(function(context)
			--table.remove(self.hpTipList,tipIndex)
			hpTip:removeFromParent()
			if finished and self.heroCell.baseData then
				finished();
			end
			self.hpTipCount=self.hpTipCount-1
	end)
	--table.insert(self.hpTipList,tipIndex,hpTip)
	return hpTip
end



function BarController:clear()

	for k, tween in pairs(self.tweenList) do
		   print(0,"clear",tween)
		   tween:kill()
	end
	self.tweenList={}
	for k, hpTip in pairs(self.hpTipList) do
		 --hpTip:removeFromParent()
	end
	self.hpTipList={}
end


return BarController




