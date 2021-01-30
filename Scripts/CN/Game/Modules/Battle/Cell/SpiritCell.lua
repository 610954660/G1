---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-09-22 11:18:06
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SpiritCell

local GodArmsCell=require "Game.Modules.Battle.Cell.GodArmsCell"

local SpiritCell,Super = class("SpiritCell",GodArmsCell)

function SpiritCell:ctor(view,posData)
	self.view = view
	self.posData = posData
	self.spirit=true
end


-- --精灵法术攻击
-- function SpiritCell:magicAttack(finished,skillType,bulletType)
-- 	local fightInfo= BattleManager:getInstance():getFightObjData()
-- 	fightInfo.skillState = true 	-- 技能已释放
-- 	local function elvesAttack( ... )
-- 		if finished then
-- 			printTable(086,">>>>>精灵释放技能>>>>>")
-- 			finished()
-- 			Dispatcher.dispatchEvent(EventType.ElvesAddTopView_fightFresh,fightInfo)
-- 		end
-- 	end
-- 	Super.magicAttack(self,elvesAttack,skillType,bulletType)
-- end

--精灵物理攻击
-- function SpiritCell:standByAttack(finished)
-- 	local fightInfo= BattleManager:getInstance():getFightObjData()
-- 	fightInfo.skillState = true 	-- 技能已释放
-- 	local function elvesAttack( ... )
-- 		if finished then
-- 			printTable(8848,">>>>>精灵释放技能>>>>>")
-- 			finished()
-- 			Dispatcher.dispatchEvent(EventType.ElvesAddTopView_fightFresh,fightInfo)
-- 		end
-- 	end
-- 	Super.standByAttack(self,elvesAttack)
-- end

--精灵法术攻击
function SpiritCell:magicAttack(finished,skillType,bulletType)
	local fightInfo= BattleManager:getInstance():getFightObjData()
	fightInfo.skillState = true 	-- 技能已释放
	for k, SkillEffectData in pairs(fightInfo.skillEffectSeq) do
		if SkillEffectData.skill then
			local skillData={skillType=skillType,skill=SkillEffectData.skill,id=SkillEffectData.id,bulletType=bulletType}
			SkillManager.boomEffect(skillData)
		end
	end
	BattleManager:schedule(function()
			if finished then
				finished()
				printTable(086,">>>>> 精灵法术攻击 >>>>>")
				Dispatcher.dispatchEvent(EventType.ElvesAddTopView_fightFresh,fightInfo)
			end
	end,0.3,1)
end

--精灵物理攻击
function SpiritCell:standByAttack(finished)
	local fightInfo	= BattleManager:getInstance():getFightObjData()
	local elfId 	= fightInfo.code 	-- 精灵id
	local skinId  	= ElvesSystemModel:getBattleElvesSkin(fightInfo.id) 	-- 精灵皮肤id
	if skinId == 0 or (not skinId) then skinId = 1 end

	fightInfo.skillState = true 	-- 技能已释放
	local function elvesAttack( ... )
		if finished then
			printTable(8848,">>>>>精灵释放技能>>>>>")
			finished()
			Dispatcher.dispatchEvent(EventType.ElvesAddTopView_fightFresh,fightInfo)
		end
	end

	SkillManager.normalEffect3(self.index,fightInfo.skill,function (attackCount,index)
			SkillManager.hitEvent(attackCount)
	end,elvesAttack,elfId,skinId)
end

return SpiritCell

