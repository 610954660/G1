local  BaseState = class("BaseState") 
local CameraController=require "Game.Modules.Battle.Effect.CameraController"

function BaseState:ctor(stateData)
	
	
	self.statusType =
	{
		onDie=1,
		stack=2,
		freeze=3,
		hit=4,
		stun=5,
		stand=6,
	}
	
	self._STAND="Stand"
	self._STACK="Stack"
	self._HTI="Hit"
	self._ONDIE="Die"
	self._STUN="stun"
	self._FREEZE="freeze"
	self._Win="Win"
	self._onLeved="onLeved"

end

-- 进入状态
function BaseState:OnEnter()
	
end

--角色进入攻击状态
function BaseState:OnStack(stackName)
	self.barController:hideAllBar()
	self.buffList:setVisible(false)
	--self.statusQuese[self.statusType.stack]==self.statusType.stack

	SkillManager.setBuffVisible(self.index,false)
end

--角色进入攻击状态
function BaseState:OnDie()
	SkillManager.setBuffVisible(self.index,false,true)
end

function BaseState:OnWin()
	self.barController:hideAllBar()
	self.buffList:setVisible(false)
	SkillManager.setBuffVisible(self.index,false)
end


function BaseState:OnAllStateEnd()
	if self.status~=self._ONDIE then	
		self.barController:showAllBar()
		self.buffList:setVisible(true)
		SkillManager.setBuffVisible(self.index,not __LJJ_BattleTest__)
	end
end


function BaseState:OnNextState()
	
end


--防止攻击被打断的操作
function BaseState:toStand()
    if self.status~=self._ONDIE and self.status~=self._STACK then
		self.status=self._STAND
		if tolua.isnull(self.skeletonNode) then
			return 
		end
		self.skeletonNode:setOpacity(255)
		self.skeletonNode:setAnimation(0,"stand",true)
	end
end


-- 更新状态
function BaseState:OnUpdate()
	
end

-- 离开状态
function BaseState:OnLeave()
	
end

return BaseState