---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
local RelicCopyViewController = class("RelicCopyViewController",Controller)

function RelicCopyViewController:player_updateRoleInfo()
	RelicCopyModel:relicCopyRed()
end

function RelicCopyViewController:update_cards_fightVal()
	RelicCopyModel:relicCopyRed()
end

function RelicCopyViewController:serverTime_crossDay(...) --跨天
	RelicCopyModel:getCopy()
	RelicCopyModel:clearCountDowm() --清理
end

return RelicCopyViewController
