--added by xhd
--符文背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local CrownTitlePackModel = class("CrownTitlePackModel", PackBaseModel)

function CrownTitlePackModel:init()
	-- RuneSystemModel:checkRuneRedDot()
	self.inited = false
end

function CrownTitlePackModel:initRedMap()
	local redMap = {}
	for _,v in pairs(DynamicConfigData.t_HeadFrame) do
		table.insert(redMap, "V_CROWN_TITLE_"..v.code)
	end
	RedManager.addMap("V_CROWN_TITLE", redMap)
	self.inited = true
end

function CrownTitlePackModel:redCheck(itemData, curAmount)
	if self.inited then
		--RedManager.updateValue("V_CROWN_TITLE_"..itemData.__data.code, curAmount ~= 0)
	end
end

return CrownTitlePackModel
