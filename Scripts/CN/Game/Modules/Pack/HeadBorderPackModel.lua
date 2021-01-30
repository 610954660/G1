--added by xhd
--符文背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local HeadBorderPackModel = class("HeadBorderPackModel", PackBaseModel)

function HeadBorderPackModel:init()
	-- RuneSystemModel:checkRuneRedDot()
	self.inited = false
end

function HeadBorderPackModel:initRedMap()
	local redMap = {}
	for _,v in pairs(DynamicConfigData.t_HeadFrame) do
		table.insert(redMap, "V_HEAD_BORDER_"..v.code)
	end
	RedManager.addMap("V_HEAD_BORDER", redMap)
	self.inited = true
end

function HeadBorderPackModel:redCheck(itemData, curAmount)
	if self.inited then
		RedManager.updateValue("V_HEAD_BORDER_"..itemData.__data.code, curAmount ~= 0)
	end
end

return HeadBorderPackModel
