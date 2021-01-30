--Name : SpecialgiftBagTourView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc : 神社祈福特惠礼包
local SpecialgiftBagBaseView = require "Game.Modules.SpecialgiftBag.SpecialgiftBagBaseView"
local SpecialgiftBagTourView, Super = class("SpecialgiftBagTourView", SpecialgiftBagBaseView)
local ItemCell = require "Game.UI.Global.ItemCell"
function SpecialgiftBagTourView:ctor()
    --LuaLog("SpecialgiftBagTourView ctor")
    self._packName = "OperatingActivities"
    self._compName = "SpecialgiftBagView"
	self.activityType = GameDef.ActivityType.TourPreferGift
	self.statFuncType = GameDef.StatFuncType.SFT_TourPreferGift
end


return SpecialgiftBagTourView