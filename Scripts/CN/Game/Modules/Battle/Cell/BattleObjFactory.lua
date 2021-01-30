---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-11-23 17:36:09
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BattleObjFactory
local HeroItem=require "Game.Modules.Battle.Cell.HeroItem"--每个英雄信息的item
local GodArmsCell=require "Game.Modules.Battle.Cell.GodArmsCell"--每个秘武的信息
local SpiritCell=require "Game.Modules.Battle.Cell.SpiritCell"--每个精灵的信息
local SubItem=require "Game.Modules.Battle.Cell.SubItem"

local BattleObjFactory = {}


--根据id创建前排信息和替补信息
function BattleObjFactory.creatItem(seatKey,child,posData)
	local itemCell=false
	if seatKey=="front" then
		itemCell=HeroItem.new(child,posData)--前排信息
		if posData.isTest then
		    itemCell.design:setTouchable(false)
		end
	end
	if seatKey=="replace" then
		itemCell=SubItem.new(child,posData)--替补信息
		itemCell:initUI()
	end
	if seatKey=="godArms" then  --秘武的UI
		itemCell=GodArmsCell.new(child,posData)
		itemCell.godArms=true
	end
	if seatKey=="spirit" then  --照着秘武初始化一下精灵UI 传给战斗
		itemCell = SpiritCell.new(child,posData)
		itemCell.spirit = true
	end
	return  itemCell
end



return BattleObjFactory