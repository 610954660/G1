--Name : SpecialgiftBagView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc : 特惠礼包
local SpecialgiftBagBaseView = require "Game.Modules.SpecialgiftBag.SpecialgiftBagBaseView"
local SpecialgiftBagView, Super = class("SpecialgiftBagView", SpecialgiftBagBaseView)
local ItemCell = require "Game.UI.Global.ItemCell"
function SpecialgiftBagView:ctor()
    --LuaLog("SpecialgiftBagView ctor")
    self._packName = "OperatingActivities"
    self._compName = "SpecialgiftBagView"
	self.activityType = GameDef.ActivityType.PreferentialkGift
	self.statFuncType = GameDef.StatFuncType.SFT_Preferentialk
end


return SpecialgiftBagView