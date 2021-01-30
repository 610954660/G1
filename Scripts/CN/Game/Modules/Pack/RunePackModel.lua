--added by xhd
--符文背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local RunePackModel = class("RunePackModel", PackBaseModel)

function RunePackModel:redCheck(itemData, curAmount)
	-- RuneSystemModel:checkRuneRedDot()
end

return RunePackModel
