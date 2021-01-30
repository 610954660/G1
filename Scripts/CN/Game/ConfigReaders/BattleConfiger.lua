---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-13 19:33:33
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BattleConfiger
local BattleConfiger = {}


--根据id获取主动技能
function BattleConfiger.getMapByID(id)
	local map=DynamicConfigData.t_fight[id]
	return map
end

return  BattleConfiger