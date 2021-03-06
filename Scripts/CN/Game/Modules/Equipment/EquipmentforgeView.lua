--Name : EquipmentforgeView.lua
--Author : generated by FairyGUI
--Date : 2020-4-2
--Desc : 之前的重铸功能挪到脚本 EquipmentRecastView.lua

local EquipmentforgeView,Super = class("EquipmentforgeView", MutiWindow)
local ItemCell = require "Game.UI.Global.ItemCell"

function EquipmentforgeView:ctor()
	self._packName = "Equipment"
	self._compName = "EquipmentforgeView"
	self._rootDepth = LayerDepth.Window
	self.btn_help = false;
	self.btn_help2 = false;
	self.helpStr = "";
	self.helpTitle = "";
	--GButton
	--GTextField
	
	--按钮上的红点数据
	-- self.redTypes = {
	-- -- 	{redType="", moduleId = ModuleId.Forge_starUp.id},
	-- -- 	{redType="", moduleId = ModuleId.Forge_Decompose.id},
	-- 	{redType="", moduleId = ModuleId.Forge.id},
	-- 	{redType="", moduleId = ModuleId.Forge_Compose.id},
	-- 	{redType="", moduleId = ModuleId.Forge_Wash.id},
	-- 	{redType="", moduleId = 0},
	-- 	{redType="", moduleId = 0},
	-- }

	self.showMoneyRebuildType = {
		{type = GameDef.GameResType.Item, code = 10000058, iconType = GameDef.ItemType.Money},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}

	self.showMoneyRecastType = {
		{type = GameDef.GameResType.Item, code = 10000013, iconType = GameDef.ItemType.Normal},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}

	self.showMoneyUpstarType = {
		{type = GameDef.GameResType.Item, code = 10000017, iconType = GameDef.ItemType.Normal},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}

	self.showMoneyDefaultType = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
		}
	if (not self._args) then
		self._args = {};
	end
	self._args.viewData = self:getTabBar();
	if not self._args.page then
		self._args.page = self._args.viewData[1].page
	end
end

function EquipmentforgeView:_initEvent()
	self.btn_help:addClickListener(function ()
		if (self.helpStr and self.helpStr ~= "") then
			RollTips.showHelp(self.helpTitle, self.helpStr);
		end
	end)

	self.btn_help2:addClickListener(function ()
		self:showHelpPanel()
	end)
end

function EquipmentforgeView:getTabBar()
	local tabData = {};
	-- 装备重铸
	if (ModuleUtil.hasModuleOpen(ModuleId.Forge.id, false)) then
		local data = {
			red = "",
			mid = ModuleId.Forge.id,
			page = "EquipmentRecastView",
			btData = {
				title = Desc.equipmentforge_title1,
				icon = "Icon/equipment/tabicon1.png",
			}
		}
		table.insert(tabData, data)
	end
	-- 饰品合成
	if (ModuleUtil.hasModuleOpen(ModuleId.Forge_Compose.id, false)) then
		local data = {
			red = "",
			mid = ModuleId.Forge_Compose.id,
			page = "JewelryMergeView",
			btData = {
				title = Desc.equipmentforge_title2,
				icon = "Icon/equipment/tabicon2.png",
			}
		}
		table.insert(tabData, data)
	end
	-- 饰品洗炼
	if (ModuleUtil.hasModuleOpen(ModuleId.Forge_Wash.id, false)) then
		local data = {
			red = "",
			mid = ModuleId.Forge_Wash.id,
			page = "JewelryRebuildView",
			btData = {
				title = Desc.equipmentforge_title3,
				icon = "Icon/equipment/tabicon3.png",
			}
		}
		table.insert(tabData, data)
	end
	return tabData
end

function EquipmentforgeView:_initUI()
	self.btn_help = self.view:getChildAutoType("btn_help");
	self.btn_help2 = self.view:getChildAutoType("btn_help2");
end

function EquipmentforgeView:showHelpPanel()
	local btnPos = self.btn_help2:getPosition()
	RollTips.showPicHelp("UI/EquipForge/EquipForge_help.png", btnPos)
end


function EquipmentforgeView: onShowPage(page)
	self.btn_help2:setVisible(page == "JewelryMergeView")
	if page == "JewelryMergeView" then
		local isFirstOpen = FileCacheManager.getStringForKey("EquipmentforgeOpen"..(ModelManager.PlayerModel.userid or ""), "0", nil,true)
		if isFirstOpen == "0" then
			Scheduler.scheduleOnce(0.5, function()
				if tolua.isnull(self.view) then return end
				self:showHelpPanel()
				FileCacheManager.setStringForKey("EquipmentforgeOpen"..(ModelManager.PlayerModel.userid or ""), "1", nil,true)
			end)
		end
	end
	
	if (page == "JewelryMergeView" or page == "JewelryRebuildView") then
		self:setBg("Jewelry.jpg");
	else
		self:setBg("equipforgeBg.jpg")
	end

	if (page == "JewelryRebuildView") then
		self:setMoneyType(self.showMoneyRebuildType);
	elseif (page == "EquipmentRecastView") then
		self:setMoneyType(self.showMoneyRecastType);
	elseif (page == "UpgradeStar") then
		self:setMoneyType(self.showMoneyUpstarType);
	else
		self:setMoneyType(self.showMoneyDefaultType);
	end

	if (page == "JewelryRebuildView") then -- 洗炼
		self.helpTitle = Desc.help_StrTitle100;
		self.helpStr = Desc.help_StrDesc100;
		self.btn_help:setVisible(true)
	elseif (page == "JewelryMergeView") then -- 合成
		self.helpTitle = Desc.help_StrTitle99;
		self.helpStr = Desc.help_StrDesc99;
		self.btn_help:setVisible(true)
	else
		self.helpTitle = Desc.help_StrTitle133;
		self.helpStr = Desc.help_StrDesc133;
	end
end

return EquipmentforgeView
