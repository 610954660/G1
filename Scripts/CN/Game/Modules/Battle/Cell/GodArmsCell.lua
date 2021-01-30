---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-17 21:01:31
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class godArmsCell
local GodArmsCell =class("GodArmsCell")
local BarController= require "Game.Modules.Battle.Effect.BarController"
function GodArmsCell:ctor(view,posData)
	self.view=view
	self.heroPos=posData
	self.index=false
	self.seatId=posData.seatId
	self.index=posData.pos+posData.seatId
	self.godArms=false
	self.spelCaster=true
	self.baseData=false
	local barGroup={
		shidBar=self.shieldBar,
		hpProgressBar=self.hpProgressBar,
		hpBarYellow=self.hpBarYellow,
		bossBar=self.bossBar,
		angerBar=self.angerBar,
		barParent=self.barGroup,
		heroType=self.heroType,

	}

	self.barController=BarController.new()
	self.barController.index=self.index
    self:setData()
end


function GodArmsCell:setData()
	SkillManager.addSkillAciton({id=self.index,isGodArms=true,view=self.view, heroPos=self.heroPos})
end

function GodArmsCell:setAttackPos(finished)
    if finished then
		finished()
	end
end


function GodArmsCell:magicAttack(finished,skillType,bulletType)
	print(086,"特效道具的 magicAttack",self.index)
	local fightInfo= BattleManager:getInstance():getFightObjData()
	local info = {
		id = self.index,
		state = true,
	}
	for k, SkillEffectData in pairs(fightInfo.skillEffectSeq) do
		--local beAttacker=ModelManager.BattleModel:getHeroItemById(SkillEffectData.id)
		if SkillEffectData.skill then
			local skillData={skillType=skillType,skill=SkillEffectData.skill,id=SkillEffectData.id,bulletType=bulletType}
			SkillManager.boomEffect(skillData)
		end
	end
	BattleManager:schedule(function()
			if finished then
				finished()
				Dispatcher.dispatchEvent(EventType.SecretWeaponBattleView_fightFresh,info)
			end
	end,0.3,1)
end

--秘武的施法特效
function GodArmsCell:standByAttack(finished)
    print(086,"GodArmsCell standByAttack",self.view)
	
	local fightInfo= BattleManager:getInstance():getFightObjData()
--	printTable(086,fightInfo,self.index)
	
	local function effectEnd()
		if finished then
			finished()
		end
	end 
	SkillManager.normalEffect(self.index,fightInfo.skill,function (attackCount,index)
			SkillManager.hitEvent(attackCount)
	end,effectEnd)
	--BattleManager:schedule(function()
			--if finished then
				--finished()
			--end
	--end,1.5,1)
end


function GodArmsCell:showAllHurtTips(allHurt)
	self.barController:createAllHurt(allHurt)
end


function GodArmsCell:resetData()
	
end

return GodArmsCell