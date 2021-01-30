---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-03-11 14:31:00
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File



local BaseState=require "Game.Modules.Battle.Fsm.BaseState"

---@class BattelState
local BattleObjState,Super= class("BattelState",BaseState)
--local  FsmMachine= require "Game.Modules.Battle.Fsm.FsmMachine"

function BattleObjState:ctor(stateData)
	self.currentFight={}
	self.fightId=false   --当前出手玩家

	
	
	
	self.status = false
	self.delayStatus= self._STAND --保存一个状态在符合条件的时候触发

	self.statusQuese={}--根据状态优先级加入
	for k, v in pairs(self.statusType) do
		self.statusQuese[v]=false
	end







	self.skeletonNode=stateData.skeletonNode
	self.index=stateData.index
	self.view=stateData.view
	self.barController=stateData.barController
	self.buffList=stateData.buffList
	self.skillTip=stateData.skillTip

	self.causeDie=false
	self.scheduleID=false
	self.tweenId=false



end


--攻击状态
function BattleObjState:OnStack(stackName,showSkill)
	local atackerId=BattleManager:getInstance():getFightID()
	local stackAnimation=false
	if self.index==atackerId then
		if self.status==self._FREEZE then
			self.skeletonNode:resume()--被冻住解封
		end
		if self.scheduleID then
			Scheduler.unschedule(self.scheduleID)
		end
		self.status=self._STACK
		stackAnimation=self.skeletonNode:setAnimation(0,stackName,false)
		Super.OnStack(self,stackName)
		--self.skeletonNode:setCompleteListener(function (name)
		--if name=="stackName"  then

		--end
		--end)
		self.skillTip:setVisible(showSkill)

		BattleManager:schedule(function()
				self.skillTip:setVisible(false)
			end,1.5,1)

	else
		LuaLogE(atackerId.."位置的角色index设置成了"..self.index.."这是不对的")
	end
	return stackAnimation
end



--胜利状态
function BattleObjState:OnWin()
	if tolua.isnull(self.skeletonNode) then
		return
	end
	self:OnInit()--攻击完成之后需要的操作
	self.status=self._Win
	self.skeletonNode:setAnimation(0,"win",true)
	Super.OnWin(self)
end

--角色说话
function BattleObjState:OnTalking(str)
	self.skillTip:setVisible(true)
	BattleManager:schedule(function()
			self.skillTip:setVisible(false)
		end,2.5,1)
end


--角色本回合出手动作完成
function BattleObjState:OnAllStateEnd()
	if tolua.isnull(self.view) then
		return
	end
	Super.OnAllStateEnd(self)
end

--死亡
function BattleObjState:OnDie()
	if tolua.isnull(self.skeletonNode) then
		return
	end

	if self.status~=self._ONDIE then
		if self.status==self._STACK then
			self.delayStatus=self._ONDIE   --攻击状态优先级高，攻击者动作做完后再死
			return
		end
		self.status=self._ONDIE
		self.skeletonNode:setAnimation(0,"dead",false)
		self:tweenFadeOut(0.8)
		Super.OnDie(self)
	end
end


--复活
function BattleObjState:OnRevived()
	if tolua.isnull(self.skeletonNode) then
		return
	end
	self.status=self._STAND
	self.skeletonNode:resume()
	self.skeletonNode:setOpacity(255)
	self.skeletonNode:setAnimation(0,"stand",true)
	if self.delayStatus==self._STUN then
		self:OnStun()
	end

end

--受击
function BattleObjState:OnHit()
	if tolua.isnull(self.skeletonNode) then
		return
	end
	local atackerId=BattleManager:getInstance():getFightID()
	if  self.index~=atackerId then --自己出手不做受击动作
		if self.status~=self._STUN and self.status~=self._FREEZE and self.status~=self._ONDIE  then
			if self.status~=self._STUN then
				self.status=self._HTI
			end
		end
		self.skeletonNode:setAnimation(0,"hit",false)
		self.skeletonNode:setCompleteListener(function (name)
				if name=="hit" then
					self.skeletonNode:setAnimation(0,"stand",true)
				end
			end)
	end
end


--战立
function BattleObjState:OnStand()
	if  self.status==self._HTI  then
		self.scheduleID=BattleManager:schedule(function()
				self:toStand()
			end,0.5,1)
	end

	if  self.status==self._STUN  then--眩晕
		self.scheduleID=BattleManager:schedule(function()
				self.skeletonNode:setAnimation(0,"stun",true)
			end,0.3,1)
	end
end

--初始转态
function BattleObjState:OnInit(boneStyle)
	if self.index==222 then
		print(5656,"BattleObjState:OnInit  ",self.status)
	end
	if self.status==self._ONDIE or tolua.isnull(self.skeletonNode) then
		return
	end

	if boneStyle==2 then --冰冻恢复
		self.skeletonNode:resume()
	end
	if  self.status~=self._STAND  then
		self:toStand()
		self.status=self._STAND
		self.delayStatus= self._STAND
	end
end


--某些优先级高的状态要在攻击完成之后才生效
function BattleObjState:OnNextState()
	Super.OnNextState(self)
	if self.status==self._FREEZE then
		self.skeletonNode:pause()
	end
	if self.status==self._STACK then
		self.status=self._STAND
		--self.skeletonNode:setAnimation(0,"stand",true)
		self:toStand()
	end
	if self.status==self._HTI then
		self.status=self._STAND
		self.scheduleID=BattleManager:schedule(function()
				self:toStand()
			end,0.5,1)
	end
	if self.delayStatus==self._ONDIE then --延迟死亡状态
		self:OnDie()
	end
end


--眩晕效果
function BattleObjState:OnStun()
	local atackerId=BattleManager:getInstance():getFightID()
	if  self.status~=self._STUN and self.index~=atackerId and self.status~=self._ONDIE then
		self.status=self._STUN
		self.delayStatus=self._STUN
		self.skeletonNode:setAnimation(0,"stun",true)
	end
end


--冰凍等效果
function BattleObjState:OnFreeze()
	local atackerId=BattleManager:getInstance():getFightID()
	if  self.status~=self._FREEZE then
		self.status=self._FREEZE
		self.delayStatus=self._FREEZE
		if self.index~=atackerId then
			BattleManager:schedule(function()
					self.skeletonNode:pause()
				end,0.2,1)
		end
	end
end


--死亡消息动画
function BattleObjState:tweenFadeOut(time)
	local a1= fgui.GTween:toDouble(255,0,time)
	a1:setEase(2)
	local waitData= FsmMachine:getInstance():addWaitQues(120,self.index,"tweenFadeOut")
	a1:onUpdate(function(tweener)
			if tolua.isnull(self.view) then
				return
			end
			self.skeletonNode:setOpacity(tweener:getDeltaValue():getD())
		end)
	a1:onComplete(function ()
			if tolua.isnull(self.view) then
				return
			end
			if waitData then
				waitData.callBack()
			end
			--SkillManager.creatorDieFX(self.index)
			self.tweenId=false
		end)
	self.tweenId=a1
end




-- 更新状态
function BattleObjState:OnUpdate()


end

-- 离开状态
function BattleObjState:OnLeave()

	if self.tweenId then
		--printTable(08666,self.tweenId,"self.tweenId")
		TweenUtil.clearTween(self.tweenId)
		self.tweenId=false
	end
	self.skillTip:setVisible(false)
	--self.skeletonNode:setAnimation(0,"stand",true)
end

return BattleObjState