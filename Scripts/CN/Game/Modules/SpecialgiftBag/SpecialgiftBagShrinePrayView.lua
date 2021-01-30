--Name : SpecialgiftBagShrinePrayView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc : 神社祈福特惠礼包
local SpecialgiftBagBaseView = require "Game.Modules.SpecialgiftBag.SpecialgiftBagBaseView"
local SpecialgiftBagShrinePrayView, Super = class("SpecialgiftBagShrinePrayView", SpecialgiftBagBaseView)
local ItemCell = require "Game.UI.Global.ItemCell"
function SpecialgiftBagShrinePrayView:ctor()
    --LuaLog("SpecialgiftBagShrinePrayView ctor")
    self._packName = "OperatingActivities"
    self._compName = "SpecialgiftBagView"
	self.activityType = GameDef.ActivityType.ShrinePrayPreferGift
	self.statFuncType = GameDef.StatFuncType.SFT_ShrinePrayPreferGift
end


return SpecialgiftBagShrinePrayView