--道具配置读取器
--added by xhd
local JewelryConfiger = {}
local Category = GameDef.Category
local addPowerMap 

function JewelryConfiger.getAddPower(type, prame)
	if not addPowerMap then
		addPowerMap = {}
		for _,v in pairs(DynamicConfigData.t_JewelryAttr) do
			addPowerMap[v.attribute[1].type.."_"..v.attribute[1].prame] = v
		end
	end
	local config = addPowerMap[type.."_"..prame] 
	if config then return config.power end
	return 0
end


return JewelryConfiger
